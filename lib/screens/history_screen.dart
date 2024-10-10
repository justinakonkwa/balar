import 'package:balare/Adds/add_expenses.dart'; // Page pour ajouter une transaction
import 'package:balare/Modeles/firebase.dart'; // Fonctionnalités Firestore
import 'package:balare/widget/app_text.dart';
import 'package:balare/widget/app_text_large.dart';
import 'package:balare/widget/constantes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Pour le formatage des dates

class HistoriquePage extends StatelessWidget {
  final String
      type; // Le type de transactions à afficher (revenus, dépenses, dettes)

  const HistoriquePage({required this.type, super.key});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy'); // Format de la date

    return Scaffold(
      appBar: AppBar(
        title: AppText(text: "Historique $type"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Icon(
              CupertinoIcons.square_arrow_up,
            ),
          )
        ],
      ),
      body: FutureBuilder<String?>(
        future: AllFunctions().getUserId(), // Récupérer l'ID de l'utilisateur
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: AppText(
                text: 'Erreur lors de la récupération des données',
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(
              child: Text(
                'Aucun utilisateur connecté.',
              ),
            );
          } else {
            String userId = snapshot.data!;
            return StreamBuilder<List<Map<String, dynamic>>>(
              stream: AllFunctions.listenToTransactions(
                  userId, type), // Filtrer les transactions par type
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: AppText(
                      text: 'Erreur lors de la récupération des transactions',
                    ),
                  );
                }

                final transactions = snapshot.data ?? [];
                if (transactions.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(CupertinoIcons.flame,size: 40,),
                            sizedbox,
                            AppTextLarge(
                              text:
                                  "Aucune donnée disponible", // Texte par défaut
                              size: 16,
                            ),
                            sizedbox,
                            AppText(
                              text:
                                  "Lorsque vous ajoutez une nouvelle donnée, Elle apparaîtra ici.", // Texte par défaut
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 8.0, right: 8.0, top: 20, bottom: 20.0),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(),
                          color: Theme.of(context).highlightColor),
                      child: Table(
                        border: TableBorder.all(
                          style: BorderStyle.none,
                        ),
                        columnWidths: const {
                          0: FlexColumnWidth(0.9),
                          1: FlexColumnWidth(2),
                          2: FlexColumnWidth(3),
                          3: FlexColumnWidth(2),
                          4: FlexColumnWidth(1.9),
                        },
                        children: [
                          // Ligne d'en-tête du tableau
                          TableRow(
                            children: [
                              Container(
                                height: 50,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                  ),
                                ),
                                child: TableCell(
                                  child: Text('N°'),
                                ),
                              ),
                              TableCell(
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 50,
                                  color: Theme.of(context).colorScheme.primary,
                                  child: AppTextLarge(
                                    text: 'Catégorie',
                                    size: 14,
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 50,
                                  color: Theme.of(context).colorScheme.primary,
                                  child: AppTextLarge(
                                    text: 'Description',
                                    size: 14,
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 50,
                                  color: Theme.of(context).colorScheme.primary,
                                  child: AppTextLarge(
                                    text: 'Montant',
                                    size: 14,
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(10),
                                      bottomRight: Radius.circular(10),
                                    ),
                                  ),
                                  child: AppTextLarge(
                                    text: 'Date',
                                    size: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Lignes de transactions avec numérotation
                          ...transactions.asMap().entries.map((entry) {
                            int index = entry.key; // L'index de la transaction
                            Map<String, dynamic> transaction = entry.value;

                            DateTime? transactionDate;

                            // Vérifiez si la date est un Timestamp ou une chaîne
                            if (transaction['date'] is Timestamp) {
                              transactionDate =
                                  (transaction['date'] as Timestamp).toDate();
                            } else if (transaction['date'] is String) {
                              transactionDate =
                                  DateTime.tryParse(transaction['date']);
                            }

                            return TableRow(
                              children: [
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Text(
                                      (index + 1).toString(),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Center(
                                      child: AppText(
                                          text: transaction['category'] ?? '',
                                          textAlign: TextAlign.center),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: ConstrainedBox(
                                      constraints:
                                          const BoxConstraints(maxWidth: 150),
                                      child: AppText(
                                        text: transaction['description'] ?? '',
                                      ),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Center(
                                      child: AppText(
                                          text:
                                              '${transaction['price']} ${transaction['currency'] ?? '€'}'),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Center(
                                      child: AppText(
                                        text: transactionDate != null
                                            ? dateFormat.format(transactionDate)
                                            : '',
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
        shape: CircleBorder(),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TransactionFormPage(
                  type: type), // Passer le type de transaction
            ),
          );
        },
        child: const Icon(Icons.add), // Utilisation d'une icône "Add"
      ),
    );
  }
}
