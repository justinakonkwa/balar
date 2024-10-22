import 'package:balare/screens/contribution_screen.dart';
import 'package:balare/widget/app_text.dart';
import 'package:balare/widget/app_text_large.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EpargneListPage extends StatelessWidget {
  const EpargneListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Row(
            children: [
              Icon(Icons.arrow_back),
              SizedBox(
                width: 5,
              ),
              AppText(text: 'back')
            ],
          ),
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
            // Liste d'éléments à afficher par défaut, avant que les données ne soient chargées
            List<Widget> content = [];

            // Nombre fixe de conteneurs affichés par défaut (hors ligne ou avant chargement des données)
            for (var i = 0; i < 4; i++) {
              content.add(Container(
                height: 200,
                margin: EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[300], // Couleur grise par défaut
                  borderRadius: BorderRadius.circular(20),
                ),
              ));
            }

            // Si les données sont disponibles, on remplace les conteneurs avec les vraies données
            if (snapshot.hasData) {
              final epargnes = snapshot.data!.docs;

              if (epargnes.isEmpty) {
                content.add(
                    Center(child: Text("Aucun plan d'épargne enregistré")));
              } else {
                content
                    .clear(); // Supprime les conteneurs par défaut pour afficher les vraies données

                for (var epargne in epargnes) {
                  final selectedEpargneId = epargne.id;

                  content.add(StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser?.uid)
                        .collection('epargnes')
                        .doc(selectedEpargneId)
                        .collection('contributions')
                        .snapshots(),
                    builder: (context, contributionSnapshot) {
                      if (contributionSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (contributionSnapshot.hasError) {
                        return Center(
                            child:
                                Text('Erreur : ${contributionSnapshot.error}'));
                      }

                      final contributions =
                          contributionSnapshot.data?.docs ?? [];
                      double totalContributions = contributions.fold(
                          0, (sum, doc) => sum + doc['montant']);

                      double objectif = epargne['objectif'];
                      double progression =
                          (totalContributions / objectif).clamp(0.0, 1.0);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _checkForBadges(context, progression);
                      });
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
                          border: Border.all(
                              color: Theme.of(context).highlightColor),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              title: Padding(
                                padding: EdgeInsets.only(
                                    left: MediaQuery.of(context).size.width *
                                        0.2),
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
                                  AppText(
                                      text: "Fin: ${epargne['date_limite']}"),
                                  AppText(
                                      text:
                                          "Fréquence : ${epargne['frequence']}"),
                                  SizedBox(height: 10),
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
                                            color: Theme.of(context)
                                                .highlightColor),
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    child: IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        _showEditEpargneModal(context,
                                            selectedEpargneId, epargne);
                                      },
                                    ),
                                  ),
                                  Spacer(),
                                  AppText(
                                      text: "Fin: ${epargne['date_limite']}"),
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
                                    left: MediaQuery.of(context).size.width *
                                            0.25 -
                                        8,
                                    top: 0,
                                    child: _buildMarker(),
                                  ),
                                  Positioned(
                                    left: MediaQuery.of(context).size.width *
                                            0.5 -
                                        8,
                                    top: 0,
                                    child: _buildMarker(),
                                  ),
                                  Positioned(
                                    left: MediaQuery.of(context).size.width *
                                            0.72 -
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
                  ));
                }
              }
            }

            return ListView(children: content);
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
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context); // Safely pop after updating
                  }
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

void _checkForBadges(BuildContext context, double progression) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  // Vérifie si le badge 50% a déjà été affiché
  if (progression >= 0.5 &&
      progression < 0.75 &&
      !(prefs.getBool('badge_50_seen') ?? false)) {
    _showBadgeDialog(
        context,
        'Félicitations !',
        'Vous avez atteint 50% de votre objectif !',
        'assets/logo21.png' // Image pour 50%
        );
    // Marquer le badge 50% comme vu
    await prefs.setBool('badge_50_seen', true);
  }
  // Vérifie si le badge 75% a déjà été affiché
  else if (progression >= 0.75 &&
      progression < 1.0 &&
      !(prefs.getBool('badge_75_seen') ?? false)) {
    _showBadgeDialog(
        context,
        'Super !',
        'Vous avez atteint 75% de votre objectif !',
        'assets/images/badge_75.png' // Image pour 75%
        );
    // Marquer le badge 75% comme vu
    await prefs.setBool('badge_75_seen', true);
  }
  // Vérifie si le badge 100% a déjà été affiché
  else if (progression == 1.0 && !(prefs.getBool('badge_100_seen') ?? false)) {
    _showBadgeDialog(
        context,
        'Incroyable !',
        'Vous avez atteint 100% de votre objectif !',
        'assets/images/badge_100.png' // Image pour 100%
        );
    // Marquer le badge 100% comme vu
    await prefs.setBool('badge_100_seen', true);
  }
}

void _showBadgeDialog(
    BuildContext context, String title, String message, String imagePath) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(imagePath, width: 100, height: 100), // Affiche l'image
            SizedBox(height: 10),
            Text(message),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Partager'),
            onPressed: () {
              Share.share(
                  '$message \nRejoignez-moi dans cette aventure d’épargne !');
            },
          ),
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
