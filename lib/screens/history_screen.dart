import 'package:balare/Adds/add_expenses.dart'; // Page pour ajouter une transaction
import 'package:balare/Modeles/firebase.dart';  // Fonctionnalités Firestore
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HistoriquePage extends StatelessWidget {
  final String type; // Le type de transactions à afficher (revenus, dépenses, dettes)

  const HistoriquePage({required this.type, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Historique - $type"), // Afficher le type dans le titre
      ),
      body: FutureBuilder<String?>(
        future: AllFunctions().getUserId(), // Récupérer l'ID de l'utilisateur
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Erreur lors de la récupération des données'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Aucun utilisateur connecté.'));
          } else {
            String userId = snapshot.data!;
            return StreamBuilder<List<Map<String, dynamic>>>(
              stream: AllFunctions.listenToTransactions(userId, type), // Filtrer les transactions par type
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Erreur lors de la récupération des transactions'));
                }

                final transactions = snapshot.data ?? [];
                return SingleChildScrollView(
                  child: DataTable(
                    dataRowHeight: 50.0,
                    headingRowHeight: 40.0,
                    columnSpacing: 20.0,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.transparent),
                      ),
                    ),
                    columns: const [
                      DataColumn(label: Text('Catégories')),
                      DataColumn(label: Text('Description')),
                      DataColumn(label: Text('Montant')),
                      DataColumn(label: Text('Date d\'ajout')),
                    ],
                    rows: transactions.map((transaction) {
                      DateTime? transactionDate;

                      // Vérifiez si la date est un Timestamp ou une chaîne
                      if (transaction['date'] is Timestamp) {
                        transactionDate = (transaction['date'] as Timestamp).toDate();
                      } else if (transaction['date'] is String) {
                        // Si c'est une chaîne, essayez de la parser
                        transactionDate = DateTime.tryParse(transaction['date']);
                      }

                      return DataRow(
                        cells: [
                          DataCell(Text(transaction['category'] ?? '')),
                          DataCell(
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 150),
                              child: Text(
                                transaction['description'] ?? '',
                                softWrap: true,
                              ),
                            ),
                          ),
                          DataCell(Text(
                              '${transaction['price']} ${transaction['currency'] ?? '€'}')),
                          DataCell(
                            Text(transactionDate != null
                                ? '${transactionDate.toLocal()}'.split(' ')[0]
                                : ''),
                          ), // Affiche la date
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Passer le type à la page de formulaire d'ajout
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TransactionFormPage(type: type), // Passer le type de transaction
            ),
          );
        },
        child: const Icon(Icons.add), // Utilisation d'une icône "Add"
      ),
    );
  }
}
