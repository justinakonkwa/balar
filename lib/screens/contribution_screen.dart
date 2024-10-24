import 'package:balare/screens/plan_epargne_screen.dart';
import 'package:balare/widget/app_text.dart';
import 'package:balare/widget/app_text_large.dart';
import 'package:balare/widget/textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ContributionListPage extends StatelessWidget {
  final String epargneId; // ID du plan d'épargne

  ContributionListPage({Key? key, required this.epargneId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => EpargneListPage(),
                    ),
                  );
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
            ],
          ),
          title: AppText(text: "Mes Contributions"),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser?.uid)
              .collection('epargnes')
              .doc(epargneId) // Utiliser l'ID du plan d'épargne
              .collection('contributions')
              .orderBy('date', descending: true) // Trier par date
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Erreur : ${snapshot.error}'));
            }

            final contributions = snapshot.data!.docs;

            if (contributions.isEmpty) {
              return Center(child: Text("Aucune contribution enregistrée"));
            }

            return ListView.builder(
              itemCount: contributions.length,
              itemBuilder: (context, index) {
                final contribution = contributions[index];
                return Container(
                  margin: EdgeInsets.only(
                    left: 15.0,
                    right: 15.0,
                    top: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Theme.of(context).highlightColor),
                  ),
                  child: ListTile(
                    title:
                        AppText(text: "Montant : \$${contribution['montant']}"),
                    subtitle: AppText(
                        text: "Date : ${contribution['date'].toDate()}"),
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).colorScheme.inverseSurface,
          shape: CircleBorder(),
          onPressed: () {
            _showContributionModal(context);
          },
          child: Icon(
            Icons.add,
            color: Theme.of(context).colorScheme.background,
          ),
        ));
  }

  Future<void> _showContributionModal(BuildContext context) async {
    final TextEditingController _montantController = TextEditingController();

    showModalBottomSheet(
      scrollControlDisabledMaxHeightRatio: 200,
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextLarge(text: 'Ajouter une contribution'),
              SizedBox(height: 10),
              textfield(
                context,
                "Montant \$",
                _montantController,
                double.maxFinite,
                Icon(Icons.attach_money),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await _saveContributionToFirebase(
                      _montantController.text, context);
                  Navigator.pop(context);
                },
                child: AppText(
                  text: 'Valider',
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveContributionToFirebase(
      String montant, BuildContext context) async {
    String userId = (await FirebaseAuth.instance.currentUser)?.uid ?? '';

    if (montant.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('epargnes')
            .doc(epargneId) // Utiliser l'ID du plan d'épargne
            .collection('contributions')
            .add({
          'montant': double.parse(montant),
          'date': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Contribution ajoutée avec succès')));
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erreur : $e')));
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Veuillez entrer un montant')));
    }
  }
}
