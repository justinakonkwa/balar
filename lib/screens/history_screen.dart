import 'dart:io';
import 'package:balare/Modeles/firebase.dart';
import 'package:balare/widget/app_text.dart';
import 'package:balare/widget/app_text_large.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class HistoriquePage extends StatefulWidget {
  final String type;

  const HistoriquePage({required this.type, super.key});

  @override
  State<HistoriquePage> createState() => _HistoriquePageState();
}

class _HistoriquePageState extends State<HistoriquePage> {
  final dateFormat = DateFormat('dd/MM/yyyy');
  DateTime? selectedDate;
  String selectedPeriod = 'Jour'; // Période sélectionnée pour le filtre
  Map<DateTime, List<Map<String, dynamic>>> groupedTransactions = {};

  @override
  void initState() {
    super.initState();
  }

  // Fonction pour générer et partager le PDF
  Future<void> generatePdfAndShare(
      List<Map<String, dynamic>> transactions, DateTime? date) async {
    final pdf = pw.Document();
    final title = date != null
        ? "Transactions du ${DateFormat('dd/MM/yyyy').format(date)}"
        : "Historique complet des transactions";

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                title,
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              if (transactions.isNotEmpty)
                pw.Table.fromTextArray(
                  headers: [
                    'N°',
                    'Catégorie',
                    'Description',
                    'Montant',
                    'Date'
                  ],
                  data: transactions.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, dynamic> transaction = entry.value;
                    return [
                      (index + 1).toString(),
                      transaction['category']?.toString() ?? '',
                      transaction['description']?.toString() ?? '',
                      transaction['price']?.toString() ?? '',
                      transaction['date'] != null
                          ? DateFormat('le dd-MM-yyyy')
                              .format(DateTime.parse(transaction['date']))
                          : 'Aucune date disponible',
                    ];
                  }).toList(),
                )
              else
                pw.Text("Aucune transaction disponible"),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File(
        "${output.path}/transactions_${date != null ? DateFormat('ddMMyyyy').format(date) : 'historique_complet'}.pdf");
    await file.writeAsBytes(await pdf.save());

    final xFile = XFile(file.path);
    Share.shareXFiles([xFile], text: title);
  }

  // Fonction pour filtrer les transactions par période sélectionnée
  List<Map<String, dynamic>> filterTransactionsByPeriod(
      List<Map<String, dynamic>> transactions) {
    final now = DateTime.now();
    final filteredTransactions = transactions.where((transaction) {
      DateTime transactionDate;
      if (transaction['date'] is Timestamp) {
        transactionDate = (transaction['date'] as Timestamp).toDate();
      } else if (transaction['date'] is String) {
        transactionDate = DateTime.tryParse(transaction['date'])!;
      } else {
        return false;
      }

      switch (selectedPeriod) {
        case 'Jour':
          return transactionDate.day == now.day &&
              transactionDate.month == now.month &&
              transactionDate.year == now.year;
        case 'Semaine':
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          final endOfWeek = startOfWeek.add(Duration(days: 6));
          return transactionDate.isAfter(startOfWeek) &&
              transactionDate.isBefore(endOfWeek);
        case 'Mois':
          return transactionDate.month == now.month &&
              transactionDate.year == now.year;
        case 'Année':
          return transactionDate.year == now.year;
        default:
          return true;
      }
    }).toList();

    return filteredTransactions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Historique ${widget.type}"),
        actions: [
          DropdownButton<String>(
            value: selectedPeriod,
            onChanged: (String? newValue) {
              setState(() {
                selectedPeriod = newValue!;
              });
            },
            items: <String>['Jour', 'Semaine', 'Mois', 'Année']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
      body: FutureBuilder<String?>(
        future: AllFunctions().getUserId(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child:
                  AppText(text: 'Erreur lors de la récupération des données'),
            );
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Aucun utilisateur connecté.'));
          } else {
            String userId = snapshot.data!;
            return StreamBuilder<List<Map<String, dynamic>>>(
              stream: AllFunctions.listenToTransactions(userId, widget.type),
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

                // Filtrer les transactions par période sélectionnée
                final filteredTransactions =
                    filterTransactionsByPeriod(transactions);

                if (filteredTransactions.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: AppText(
                        text: "Aucune transaction disponible pour ce filtre.",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                } else {
                  return SingleChildScrollView(
                    child: Container(
                      margin: EdgeInsets.all(10.0),
                      padding: EdgeInsets.all(5.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        border: Border.all(
                          color: Theme.of(context).highlightColor,
                        ),
                      ),
                      child: Column(
                        children: [
                          IconButton(
                            icon: Icon(CupertinoIcons.doc_text),
                            onPressed: () {
                              if (filteredTransactions.isNotEmpty) {
                                generatePdfAndShare(
                                    filteredTransactions, selectedDate);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(selectedDate == null
                                        ? "Pas de transactions dans l'historique complet."
                                        : "Aucune transaction pour cette date sélectionnée."),
                                  ),
                                );
                              }
                            },
                          ),
                          // Affichage des titres du tableau (une seule fois)
                          Table(
                            border: TableBorder.all(style: BorderStyle.none),
                            columnWidths: const {
                              0: FlexColumnWidth(0.6),
                              1: FlexColumnWidth(1.4),
                              2: FlexColumnWidth(3),
                              3: FlexColumnWidth(2),
                              4: FlexColumnWidth(2),
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
                                      color: Theme.of(context).highlightColor,
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

                          // Affichage des transactions
                          Column(
                            children: filteredTransactions
                                .asMap()
                                .entries
                                .map((entry) {
                              int index = entry.key;
                              Map<String, dynamic> transaction = entry.value;

                              return Table(
                                border:
                                    TableBorder.all(style: BorderStyle.none),
                                columnWidths: const {
                                  0: FlexColumnWidth(0.6),
                                  1: FlexColumnWidth(1.4),
                                  2: FlexColumnWidth(3),
                                  3: FlexColumnWidth(1.9),
                                  4: FlexColumnWidth(1.5),
                                },
                                children: [
                                  TableRow(
                                    children: [
                                      TableCell(
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: AppText(
                                            text: (index + 1).toString(),
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: AppText(
                                            text: transaction['category']
                                                    ?.toString() ??
                                                '',
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: AppText(
                                            text: transaction['description']
                                                    ?.toString() ??
                                                '',
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: AppText(
                                            text: transaction['price']
                                                    ?.toString() ??
                                                '',
                                          ),
                                        ),
                                      ),
                                      // Exemple de TableCell pour afficher la date
                                      TableCell(
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: AppText(
                                            text: () {
                                              if (transaction['date'] != null) {
                                                DateTime transactionDate =
                                                    DateTime.parse(
                                                        transaction['date']);
                                                return DateFormat('dd-MM-yyyy')
                                                    .format(transactionDate);
                                              }
                                              return '';
                                            }(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
}
