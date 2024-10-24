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
  final dateFormat = DateFormat('dd/MM/yyyy'); // Format de la date
  DateTime? selectedDate; // Variable pour stocker la date sélectionnée

  Map<DateTime, List<Map<String, dynamic>>> groupedTransactions = {};

  @override
  void initState() {
    super.initState();
    // Chargez vos transactions et organisez-les ici
    // groupTransactionsByDate(transactions);
  }

  void groupTransactionsByDate(List<Map<String, dynamic>> transactions) {
    groupedTransactions = {};

    for (var transaction in transactions) {
      DateTime transactionDate = DateTime.parse(transaction['date']);
      DateTime dateWithoutTime = DateTime(
          transactionDate.year, transactionDate.month, transactionDate.day);

      if (!groupedTransactions.containsKey(dateWithoutTime)) {
        groupedTransactions[dateWithoutTime] = [];
      }

      groupedTransactions[dateWithoutTime]?.add(transaction);
    }
  }

  Future<void> generatePdfAndShare(
      List<Map<String, dynamic>> transactionsForDate, DateTime date) async {
    final pdf = pw.Document();

    // Ajout d'une page au PDF
    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Transactions du ${DateFormat('dd/MM/yyyy').format(date)}",
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: ['N°', 'Catégorie', 'Description', 'Montant'],
                data: transactionsForDate.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, dynamic> transaction = entry.value;
                  return [
                    (index + 1).toString(),
                    transaction['category']?.toString() ?? '',
                    transaction['description']?.toString() ?? '',
                    transaction['price']?.toString() ?? '',
                  ];
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

    // Sauvegarde temporaire du PDF dans le répertoire temporaire de l'appareil
    final output = await getTemporaryDirectory();
    final file = File(
        "${output.path}/transactions_${DateFormat('ddMMyyyy').format(date)}.pdf");
    await file.writeAsBytes(await pdf.save());

    // Créer un XFile à partir du chemin du fichier
    final xFile = XFile(file.path);

    // Partage du fichier PDF
    Share.shareXFiles([xFile],
        text:
            'Voici vos transactions pour le ${DateFormat('dd/MM/yyyy').format(date)}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Historique ${widget.type}"),
        actions: [
          Row(
            children: [
              IconButton(
                icon: Icon(CupertinoIcons.calendar),
                onPressed: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null) {
                    setState(() {
                      selectedDate = picked;
                    });
                  }
                },
              ),
            ],
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

                // Si une date a été sélectionnée, filtrer les transactions
                final filteredTransactions = selectedDate != null
                    ? groupedTransactions.entries
                        .where((entry) =>
                            entry.key ==
                            DateTime(
                              selectedDate!.year,
                              selectedDate!.month,
                              selectedDate!.day,
                            ))
                        .toList()
                    : groupedTransactions.entries.toList();

                // Si aucune transaction n'est trouvée pour la date sélectionnée
                if (filteredTransactions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info, size: 40),
                        SizedBox(height: 10),
                        AppTextLarge(
                          text: "Aucune donnée pour la date sélectionnée",
                          size: 16,
                        ),
                        SizedBox(height: 10),
                        AppText(
                          text:
                              "Sélectionnez une autre date ou ajoutez des transactions pour cette date.",
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                // Affichage du tableau complet
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
                            if (groupedTransactions.isNotEmpty &&
                                selectedDate != null) {
                              final selectedDateWithoutTime = DateTime(
                                  selectedDate!.year,
                                  selectedDate!.month,
                                  selectedDate!.day);
                              final transactionsForSelectedDate =
                                  groupedTransactions[
                                          selectedDateWithoutTime] ??
                                      [];

                              if (transactionsForSelectedDate.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Aucune transaction disponible pour cette date.'),
                                  ),
                                );
                              } else {
                                generatePdfAndShare(transactionsForSelectedDate,
                                    selectedDateWithoutTime);
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Pas de transactions ou date non sélectionnée.'),
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
                              ],
                            ),
                          ],
                        ),

                        // Affichage des transactions filtrées par date ou complètes
                        Column(
                          children: filteredTransactions.map((entry) {
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
                                    text: "Date le ${dateFormat.format(date)}",
                                    textAlign: TextAlign.center,
                                  ),
                                ),

                                // Tableau des transactions pour cette date
                                Container(
                                  padding: EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    border: Border.all(
                                      color: Theme.of(context).highlightColor,
                                    ),
                                  ),
                                  child: Table(
                                    border: TableBorder.all(
                                        style: BorderStyle.none),
                                    columnWidths: const {
                                      0: FlexColumnWidth(0.6),
                                      1: FlexColumnWidth(1.4),
                                      2: FlexColumnWidth(3),
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
                                              child: AppText(
                                                text: (index + 1).toString(),
                                              ),
                                            ),
                                          ),
                                          TableCell(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: AppText(
                                                text: transaction['category']
                                                        ?.toString() ??
                                                    '',
                                              ),
                                            ),
                                          ),
                                          TableCell(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: AppText(
                                                text: transaction['description']
                                                        ?.toString() ??
                                                    '',
                                              ),
                                            ),
                                          ),
                                          TableCell(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: AppText(
                                                text: transaction['price']
                                                        ?.toString() ??
                                                    '',
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
    );
  }
}
