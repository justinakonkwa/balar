import 'package:balare/screens/contribution_screen.dart';
import 'package:balare/widget/app_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EpargneListPage extends StatelessWidget {
  const EpargneListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppText(text: "Mes Plans d'Épargne"),
      ),
      body: StreamBuilder<QuerySnapshot>(
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
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }

          final epargnes = snapshot.data!.docs;

          if (epargnes.isEmpty) {
            return Center(child: Text("Aucun plan d'épargne enregistré"));
          }

          return ListView.builder(
            itemCount: epargnes.length,
            itemBuilder: (context, index) {
              final epargne = epargnes[index];
              final selectedEpargneId = epargne.id; // Récupérer l'ID du plan d'épargne

              return ListTile(
                title: AppText(text: epargne['nom']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(text: "Objectif : \$${epargne['objectif']}"),
                    AppText(text: "Date limite : ${epargne['date_limite']}"),
                    AppText(text: "Fréquence : ${epargne['frequence']}"),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    _showEditEpargneModal(context, selectedEpargneId, epargne);
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ContributionListPage(epargneId: selectedEpargneId),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showEditEpargneModal(BuildContext context, String epargneId, QueryDocumentSnapshot epargne) {
    final TextEditingController nomController = TextEditingController(text: epargne['nom']);
    final TextEditingController objectifController = TextEditingController(text: epargne['objectif'].toString());
    final TextEditingController dateLimiteController = TextEditingController(text: epargne['date_limite']);
    final TextEditingController frequenceController = TextEditingController(text: epargne['frequence']);

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
                  await _updateEpargne(epargneId, nomController.text, double.tryParse(objectifController.text) ?? 0, dateLimiteController.text, frequenceController.text,context);
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

  Future<void> _updateEpargne(String epargneId, String nom, double objectif, String dateLimite, String frequence,BuildContext context) async {
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
