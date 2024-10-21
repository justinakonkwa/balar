import 'package:balare/pages/income_page.dart';
import 'package:balare/screens/contribution_screen.dart';
import 'package:balare/widget/app_text.dart';
import 'package:balare/widget/app_text_large.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EpargneListPage extends StatelessWidget {
  const EpargneListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Icon(Icons.arrow_back),
            ),
            SizedBox(
              width: 5,
            ),
            AppText(text: 'back')
          ],
        ),
        title: AppText(text: "Mes Plans d'Épargne"),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 15.0, right: 15.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser?.uid)
              .collection('epargnes')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Erreur : ${snapshot.error}'),
              );
            }

            final epargnes = snapshot.data!.docs;

            if (epargnes.isEmpty) {
              return Center(
                child: Text("Aucun plan d'épargne enregistré"),
              );
            }

            return ListView.builder(
              itemCount: epargnes.length,
              itemBuilder: (context, index) {
                final epargne = epargnes[index];
                final selectedEpargneId = epargne.id;

                return FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser?.uid)
                      .collection('epargnes')
                      .doc(selectedEpargneId)
                      .collection('contributions')
                      .get(),
                  builder: (context, contributionSnapshot) {
                    if (!contributionSnapshot.hasData) {
                      return CircularProgressIndicator();
                    }

                    final contributions = contributionSnapshot.data!.docs;
                    double totalContributions = contributions.fold(
                        0, (sum, doc) => sum + doc['montant']);

                    double objectif = epargne['objectif'];
                    double progression =
                        (totalContributions / objectif).clamp(0.0, 1.0);

                    // Déterminer la couleur de la progression en fonction des intervalles
                    Color progressColor;
                    if (progression <= 0.25) {
                      progressColor = Colors.red;
                    } else if (progression <= 0.45) {
                      progressColor = Colors.orange;
                    } else if (progression <= 0.65) {
                      progressColor = Colors.yellow;
                    } else if (progression <= 0.85) {
                      progressColor = Colors.lightGreen;
                    } else {
                      progressColor = Colors.green;
                    }

                    return Container(
                      margin: EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: Theme.of(context).highlightColor),
                        // boxShadow: [
                        //   BoxShadow(
                        //     color: Theme.of(context)
                        //         .colorScheme
                        //         .inverseSurface
                        //         .withOpacity(0.4),
                        //     spreadRadius: 2,
                        //     blurRadius: 10,
                        //     offset: Offset(0, 5),
                        //   ),
                        // ],
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            title: Padding(
                              padding: EdgeInsets.only(
                                  left:
                                      MediaQuery.of(context).size.width * 0.2),
                              child: Center(
                                child: AppTextLarge(
                                  text: epargne['nom'],
                                  size: 18,
                                ),
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    AppText(text: "Objectif :"),
                                    AppTextLarge(
                                      text: "\$${epargne['objectif']}",
                                      size: 18,
                                    ),
                                  ],
                                ),
                                AppText(text: "Fin: ${epargne['date_limite']}"),

                                AppText(
                                    text:
                                        "Fréquence : ${epargne['frequence']}"),
                                SizedBox(height: 10),

                                // Utilisation de Stack pour afficher les marqueurs et la barre de progression

                                AppText(
                                  text:
                                      "Montant épargné : \$${totalContributions.toStringAsFixed(2)} / \$${objectif.toStringAsFixed(2)}",
                                ),
                              ],
                            ),
                            trailing: Column(
                              children: [
                                Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color:
                                              Theme.of(context).highlightColor),
                                      borderRadius: BorderRadius.circular(12)),
                                  child: IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      _showEditEpargneModal(
                                          context, selectedEpargneId, epargne);
                                    },
                                  ),
                                ),
                                Spacer(),
                                AppText(text: "Fin: ${epargne['date_limite']}"),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ContributionListPage(
                                      epargneId: selectedEpargneId),
                                ),
                              );
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 8.0, right: 8, bottom: 10),
                            child: Stack(
                              children: [
                                LinearProgressIndicator(
                                  borderRadius: BorderRadius.circular(8),
                                  value: progression,
                                  color: progressColor, // Couleur de la barre
                                  backgroundColor: Colors.grey[300],
                                  minHeight: 10,
                                ),
                                Positioned(
                                  left:
                                      MediaQuery.of(context).size.width * 0.25 -
                                          8,
                                  top: 0,
                                  child: _buildMarker(),
                                ),
                                Positioned(
                                  left:
                                      MediaQuery.of(context).size.width * 0.5 -
                                          8,
                                  top: 0,
                                  child: _buildMarker(),
                                ),
                                Positioned(
                                  left:
                                      MediaQuery.of(context).size.width * 0.72 -
                                          8,
                                  top: 0,
                                  child: _buildMarker(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  // Méthode pour créer les marqueurs à 25%, 50%, 75%, et 100%
  Widget _buildMarker() {
    return Container(
      width: 1,
      height: 10,
      color: Colors.black, // Couleur des marqueurs
    );
  }

  void _showEditEpargneModal(
      BuildContext context, String epargneId, QueryDocumentSnapshot epargne) {
    final TextEditingController nomController =
        TextEditingController(text: epargne['nom']);
    final TextEditingController objectifController =
        TextEditingController(text: epargne['objectif'].toString());
    final TextEditingController dateLimiteController =
        TextEditingController(text: epargne['date_limite']);
    final TextEditingController frequenceController =
        TextEditingController(text: epargne['frequence']);

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText(text: 'Modifier le Plan d\'Épargne', size: 20),
              SizedBox(height: 10),
              TextField(
                controller: nomController,
                decoration: InputDecoration(labelText: 'Nom'),
              ),
              TextField(
                controller: objectifController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Objectif \$'),
              ),
              TextField(
                controller: dateLimiteController,
                decoration: InputDecoration(labelText: 'Date Limite'),
              ),
              TextField(
                controller: frequenceController,
                decoration: InputDecoration(labelText: 'Fréquence'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await _updateEpargne(
                      epargneId,
                      nomController.text,
                      double.tryParse(objectifController.text) ?? 0,
                      dateLimiteController.text,
                      frequenceController.text,
                      context);
                  Navigator.pop(context);
                },
                child: Text('Sauvegarder'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _updateEpargne(String epargneId, String nom, double objectif,
      String dateLimite, String frequence, BuildContext context) async {
    String userId = (await FirebaseAuth.instance.currentUser)?.uid ?? '';

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('epargnes')
          .doc(epargneId)
          .update({
        'nom': nom,
        'objectif': objectif,
        'date_limite': dateLimite,
        'frequence': frequence,
      });

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Plan d\'épargne mis à jour avec succès')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur : $e')));
    }
  }
}
