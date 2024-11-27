import 'dart:io';
import 'package:balare/Adds/add_expenses.dart';
import 'package:balare/Modeles/firebase/add_transaction.dart';
import 'package:balare/mainpage.dart';
import 'package:balare/pages/home_page.dart';
import 'package:balare/widget/app_text.dart';
import 'package:balare/widget/app_text_large.dart';
import 'package:balare/widget/constantes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
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
  String selectedPeriod = "Aujourd'hui";
  bool isLoanding = false;
  Map<DateTime, List<Map<String, dynamic>>> groupedTransactions = {};

  @override
  void initState() {
    super.initState();
    title();
  }

  // Fonction pour générer et partager le PDF
  Future<void> generatePdfAndShare(
      List<Map<String, dynamic>> transactions, DateTime? date) async {
    final pdf = pw.Document();
    setState(() {
      isLoanding = true;
    });
    final title = date != null
        ? "Transactions du $selectedPeriod"
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
        "${output.path}/transactions_$selectedPeriod : 'historique_complet'}.pdf");
    await file.writeAsBytes(await pdf.save());

    final xFile = XFile(file.path);
    Share.shareXFiles([xFile], text: title);
    setState(() {
      isLoanding = false;
    });
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
        case "Aujourd'hui":
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

  title() {
    if (widget.type == 'incomes') {
      return AppText(text: translate("title.title_1"));
    } else if (widget.type == 'expenses') {
      return AppText(text: translate("title.title_2"));
    } else {
      return AppText(text: translate("title.title_3"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MainPage(),
              ),
            );
          },
          child: Row(
            children: [
              Icon(Icons.arrow_back),
              AppText(text: 'Back'),
            ],
          ),
        ),
        title: title(),
        centerTitle: true,
        actions: [
          Container(
            child: DropdownButton<String>(
              borderRadius: BorderRadius.circular(20),
              value: selectedPeriod,
              onChanged: (String? newValue) {
                setState(() {
                  selectedPeriod = newValue!;
                });
              },
              items: <String>[
                "Aujourd'hui",
                "Semaine",
                "Mois",
                "Année",
                // translate("homepage.homepage_1"),
                // translate("homepage.homepage_5"),
                // translate("homepage.homepage_6"),
                // translate("homepage.homepage_7"),
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              underline: SizedBox(),
              icon: Container(
                margin: const EdgeInsets.only(
                    right: 10.0), // Espace autour de l'icône
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey), // Bordure
                  borderRadius: BorderRadius.circular(5.0), // Coins arrondis
                ),
                child: Icon(
                  Icons.arrow_drop_down, // L'icône que vous souhaitez afficher
                  // Taille de l'icône (agrandi)
                ),
              ),
            ),
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
            return Center(
              child: AppText(text: 'Aucun utilisateur connecté.'),
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

                // Filtrer les transactions par période sélectionnée
                final filteredTransactions =
                    filterTransactionsByPeriod(transactions);

                if (filteredTransactions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              border: Border.all(),
                              borderRadius: borderRadius,
                            ),
                            child: Icon(Icons.info, size: 40)),
                        SizedBox(height: 10),
                        AppTextLarge(
                          text: translate("no_data.text_1"),
                          size: 16,
                        ),
                        SizedBox(height: 10),
                        AppText(
                          text: translate("no_data.text_2"),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                } else {
                  return Scaffold(
                    body: SingleChildScrollView(
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
                            // Affichage des titres du tableau (une seule fois)
                            Table(
                              border: TableBorder.all(style: BorderStyle.none),
                              columnWidths: const {
                                0: FlexColumnWidth(0.6),
                                1: FlexColumnWidth(2),
                                2: FlexColumnWidth(3),
                                3: FlexColumnWidth(2),
                                4: FlexColumnWidth(1.5),
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
                                      child: AppText(text: 'N°'),
                                    ),
                                    TableCell(
                                      child: Container(
                                        alignment: Alignment.centerLeft,
                                        height: 50,
                                        color: Theme.of(context).highlightColor,
                                        child: AppTextLarge(
                                          text: translate("form.category"),
                                          size: 14,
                                        ),
                                      ),
                                    ),
                                    TableCell(
                                      child: Container(
                                        alignment: Alignment.centerLeft,
                                        height: 50,
                                        color: Theme.of(context).highlightColor,
                                        child: AppTextLarge(
                                          text: translate("form.description"),
                                          size: 14,
                                        ),
                                      ),
                                    ),
                                    TableCell(
                                      child: Container(
                                        alignment: Alignment.centerLeft,
                                        height: 50,
                                        color: Theme.of(context).highlightColor,
                                        child: AppTextLarge(
                                          text: translate("form.montant"),
                                          size: 14,
                                        ),
                                      ),
                                    ),
                                    TableCell(
                                      child: Container(
                                        alignment: Alignment.centerLeft,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color:
                                              Theme.of(context).highlightColor,
                                          borderRadius: BorderRadius.only(
                                            bottomRight: Radius.circular(10),
                                            topRight: Radius.circular(10),
                                          ),
                                        ),
                                        child: AppTextLarge(
                                          text: translate("form.date"),
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
                                    1: FlexColumnWidth(2),
                                    2: FlexColumnWidth(3),
                                    3: FlexColumnWidth(2),
                                    4: FlexColumnWidth(1.5),
                                  },
                                  children: [
                                    TableRow(
                                      children: [
                                        TableCell(
                                          child: Container(
                                            padding: const EdgeInsets.only(
                                                left: 5, top: 5.0, bottom: 5.0),
                                            child: AppText(
                                              text: (index + 1).toString(),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Container(
                                            padding: const EdgeInsets.only(
                                                top: 5.0, bottom: 5.0),
                                            child: AppText(
                                              text: transaction['category']
                                                      ?.toString() ??
                                                  '',
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Container(
                                            alignment: Alignment.centerLeft,
                                            padding: const EdgeInsets.only(
                                                top: 5.0, bottom: 5.0),
                                            child: AppText(
                                              text: transaction['description']
                                                      ?.toString() ??
                                                  '',
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Container(
                                            alignment: Alignment.centerLeft,
                                            padding: const EdgeInsets.only(
                                                top: 5.0, bottom: 5.0),
                                            child: AppText(
                                              text: transaction['price']
                                                      ?.toString() ??
                                                  '',
                                            ),
                                          ),
                                        ),
                                        // Exemple de TableCell pour afficher la date
                                        TableCell(
                                          child: Container(
                                            alignment: Alignment.centerLeft,
                                            padding: const EdgeInsets.only(
                                                top: 5.0, bottom: 5.0),
                                            child: AppText(
                                              text: () {
                                                if (transaction['date'] !=
                                                    null) {
                                                  DateTime transactionDate =
                                                      DateTime.parse(
                                                          transaction['date']);
                                                  return DateFormat(
                                                          'dd-MM-yyyy')
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
                    ),
                    floatingActionButton: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FloatingActionButton(
                          backgroundColor:
                              Theme.of(context).colorScheme.inverseSurface,
                          shape: CircleBorder(),
                          onPressed: () {
                            if (filteredTransactions.isNotEmpty) {
                              generatePdfAndShare(
                                  filteredTransactions, selectedDate);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: AppText(
                                      text: selectedDate == null
                                          ? "Pas de transactions dans l'historique complet."
                                          : "Aucune transaction pour cette date sélectionnée."),
                                ),
                              );
                            }
                          },
                          child: isLoanding
                              ? CupertinoActivityIndicator(
                                  color: Theme.of(context).colorScheme.primary,
                                )
                              : Icon(
                                  CupertinoIcons.share,
                                ),
                        ),
                        SizedBox(
                          height: 80,
                        )
                      ],
                    ),
                  );
                }
              },
            );
          }
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            backgroundColor: Theme.of(context).colorScheme.inverseSurface,
            shape: CircleBorder(),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TransactionFormPage(
                      type: widget.type), // Passer le type de transaction
                ),
              );
            },
            child: Icon(CupertinoIcons.add), // Utilisation d'une icône "Add"
          ),
          sizedbox,
        ],
      ),
    );
  }
}
