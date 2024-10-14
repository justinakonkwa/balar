import 'package:balare/Adds/add_expenses.dart';
import 'package:balare/Modeles/firebase.dart';
import 'package:balare/widget/app_text.dart';
import 'package:balare/widget/app_text_large.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoriquePage extends StatelessWidget {
  final String type;

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
        future: AllFunctions().getUserId(),
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
              child: Text('Aucun utilisateur connecté.'),
            );
          } else {
            String userId = snapshot.data!;
            return StreamBuilder<List<Map<String, dynamic>>>(
              stream: AllFunctions.listenToTransactions(userId, type),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: AppText(
                        text:
                            'Erreur lors de la récupération des transactions'),
                  );
                }

                final transactions = snapshot.data ?? [];

                // Si aucune transaction n'est disponible
                if (transactions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info, size: 40),
                        SizedBox(height: 10),
                        AppTextLarge(
                          text: "Aucune donnée disponible",
                          size: 16,
                        ),
                        SizedBox(height: 10),
                        AppText(
                          text:
                              "Lorsque vous ajoutez une nouvelle donnée, elle apparaîtra ici.",
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                // Regrouper les transactions par date
                final groupedTransactions =
                    <DateTime, List<Map<String, dynamic>>>{};

                for (var transaction in transactions) {
                  DateTime transactionDate;

                  if (transaction['date'] is Timestamp) {
                    transactionDate =
                        (transaction['date'] as Timestamp).toDate();
                  } else if (transaction['date'] is String) {
                    transactionDate = DateTime.tryParse(transaction['date'])!;
                  } else {
                    continue;
                  }

                  DateTime dateOnly = DateTime(
                    transactionDate.year,
                    transactionDate.month,
                    transactionDate.day,
                  ); // Ignorer les heures/minutes/secondes

                  if (!groupedTransactions.containsKey(dateOnly)) {
                    groupedTransactions[dateOnly] = [];
                  }
                  groupedTransactions[dateOnly]!.add(transaction);
                }

                // Affichage du tableau complet
                return SingleChildScrollView(
                  child: Container(
                    margin: EdgeInsets.all(10.0),
                    padding: EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: Theme.of(context).highlightColor,),
                    ),
                    child: Column(
                      children: [
                        // Affichage des titres du tableau (une seule fois)
                        Table(
                          border: TableBorder.all(style: BorderStyle.none),
                          columnWidths: const {
                            0: FlexColumnWidth(0.9),
                            1: FlexColumnWidth(2),
                            2: FlexColumnWidth(3),
                            3: FlexColumnWidth(2),
                            4: FlexColumnWidth(1.9),
                          },
                          children: [
                            TableRow(
                              children: [
                                Container(
                                  height: 50,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).highlightColor,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      bottomLeft: Radius.circular(10),
                                    ),
                                  ),
                                  child: Text('N°'),
                                ),
                                TableCell(
                                  child: Container(
                                    alignment: Alignment.center,
                                    height: 50,
                                    color: Theme.of(context).highlightColor,
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
                                    color: Theme.of(context).highlightColor,
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
                                    color: Theme.of(context).highlightColor,
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
                                      color: Theme.of(context).highlightColor,
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
                          ],
                        ),

                        // Affichage des transactions par groupe de date
                        Column(
                          children: groupedTransactions.entries.map((entry) {
                            DateTime date = entry.key;
                            List<Map<String, dynamic>> transactionsForDate =
                                entry.value;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5.0),
                                  child: AppText(
                                    text:
                                        "Date le ${dateFormat.format(date)}", // Affichage de la date
                                    textAlign: TextAlign.center,
                                  ),
                                ),

                                // Tableau des transactions pour cette date
                                Container(
                                  padding: EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    border: Border.all(color: Theme.of(context).highlightColor,),
                                  ),
                                  child: Table(
                                    border: TableBorder.all(
                                        style: BorderStyle.none),
                                    columnWidths: const {
                                      0: FlexColumnWidth(0.6),
                                      1: FlexColumnWidth(2),
                                      2: FlexColumnWidth(3),
                                      3: FlexColumnWidth(2),
                                    },
                                    children: transactionsForDate
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                      int index = entry.key;
                                      Map<String, dynamic> transaction =
                                          entry.value;

                                      return TableRow(
                                        children: [
                                          TableCell(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child:
                                                  Text((index + 1).toString()),
                                            ),
                                          ),
                                          TableCell(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: Center(
                                                child: AppText(
                                                  text:
                                                      transaction['category'] ??
                                                          '',
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                          ),
                                          TableCell(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: ConstrainedBox(
                                                constraints:
                                                    const BoxConstraints(
                                                        maxWidth: 150),
                                                child: AppText(
                                                  text: transaction[
                                                          'description'] ??
                                                      '',
                                                ),
                                              ),
                                            ),
                                          ),
                                          TableCell(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: Center(
                                                child: AppText(
                                                  text:
                                                      '${transaction['price']} ${transaction['currency'] ?? '€'}',
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ],
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
