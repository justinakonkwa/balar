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
              final selectedEpargneId =
                  epargne.id; // Récupérer l'ID du plan d'épargne
          
              return Card(
                child: ListTile(
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
                      // Vous pouvez ajouter une fonction pour éditer le plan d'épargne
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
                    // Appeler le modal pour ajouter une contribution, en passant l'ID
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
