import 'package:balare/Modeles/firebase/add_transaction.dart';
import 'package:balare/Modeles/firebase/transaction_service.dart';
import 'package:balare/screens/history_screen.dart';
import 'package:balare/widget/app_text.dart';
import 'package:balare/widget/app_text_large.dart';
import 'package:balare/widget/bouton_next.dart';
import 'package:balare/widget/constantes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'dart:async';

import 'package:provider/provider.dart';

import '../theme/theme_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Stream<List<Map<String, dynamic>>> transactionsByType(
      String userId, String type, DateTime start, DateTime end) {
    return TransactionsService.listenToTransactionsFiltered(
        userId, type, start, end);
  }

  DateTime getStartDate(String day) {
    switch (day) {
      case "Aujourd'hui":
        return TransactionsService.getTodayStart();
      case "Hier":
        return TransactionsService.getYesterdayStart();
      case "Ce mois-ci":
        return TransactionsService.getThisMonthStart();
      case "Mois passé":
        return TransactionsService.getLastMonthStart();
      default:
        return DateTime.now(); // Valeur par défaut
    }
  }

  DateTime getEndDate(String day) {
    switch (day) {
      case "Aujourd'hui":
        return TransactionsService.getTodayEnd();
      case "Hier":
        return TransactionsService.getYesterdayEnd();
      case "Ce mois-ci":
        return TransactionsService.getThisMonthEnd();
      case "Mois passé":
        return TransactionsService.getLastMonthEnd();
      default:
        return DateTime.now(); // Valeur par défaut
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String?>(
      stream: AllFunctions()
          .getUserIdStream(), // Remplacez par votre méthode qui retourne un Stream<String?>
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Center(
            child: Text(
                'Erreur lors de la récupération de l\'ID de l\'utilisateur'),
          );
        }

        final userId = snapshot.data!;
        print(
            "Utilisateur connecté : $userId"); // Afficher l'ID de l'utilisateur

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          body: CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              _buildButtonsRow(context),
              _buildTransactionSummaryCard(context, userId),
            ],
          ),
        );
      },
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Theme.of(context).colorScheme.background,
      expandedHeight: 160.0,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Align(
          alignment: Alignment.bottomLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // AppTextLarge(
              //   text: "Balar",
              //   size: 30.0,
              //   color: Theme.of(context).colorScheme.inverseSurface,
              // ),
              Icon(
                Icons.notifications_outlined,
                color: Theme.of(context).colorScheme.inverseSurface,
                size: 20,
              )
            ],
          ),
        ),
        titlePadding: const EdgeInsets.only(left: 15, right: 15),
        background: Stack(
          children: [
            Container(
              color: Theme.of(context).colorScheme.background,
            ),
            Consumer<ThemeProvider>(
              builder: (context, provider, child) {
                bool isLightTheme = provider.currentTheme;

                return Padding(
                  padding: const EdgeInsets.only(left: 0.0, top: 50),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Opacity(
                        opacity: 1.0,
                        child: Image.asset(
                          isLightTheme
                              ? 'assets/logo_black.png'
                              : 'assets/logo_white.png', // Change logo based on theme
                          height: 100,
                        ),
                      ),
                      AppTextLarge(
                        text: "Balar",
                        size: 35.0,
                        color: Theme.of(context).colorScheme.inverseSurface,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  SliverList _buildButtonsRow(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNextButton(
                  context,
                  translate("title.title_1"),
                  Icons.money_sharp,
                  'incomes',
                ),
                _buildNextButton(
                  context,
                  translate("title.title_2"),
                  Icons.attach_money,
                  'expenses',
                ),
                _buildNextButton(
                  context,
                  translate("title.title_3"),
                  Icons.account_balance,
                  'debts',
                ),
              ],
            ),
          );
        },
        childCount: 1,
      ),
    );
  }

  NextButton _buildNextButton(
      BuildContext context, String label, IconData icon, String type) {
    return NextButton(
      width: MediaQuery.of(context).size.width * 0.3,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HistoriquePage(type: type),
          ),
        );
      },
      color: Theme.of(context).highlightColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.inverseSurface,
          ),
          Flexible(
            child: AppText(
              text: label,
              color: Theme.of(context).colorScheme.inverseSurface,
            ),
          ),
        ],
      ),
    );
  }

  SliverList _buildTransactionSummaryCard(BuildContext context, String userId) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          List<String> days = [
            translate("homepage.homepage_1"),
            translate("homepage.homepage_2"),
            translate("homepage.homepage_3"),
            translate("homepage.homepage_4"),
          ];
          return _buildTransactionSummaryContainer(
              context, days[index], userId);
        },
        childCount: 4,
      ),
    );
  }

  Widget _buildTransactionSummaryContainer(
      BuildContext context, String day, String userId) {
    // Récupérer les dates de début et de fin
    DateTime start = getStartDate(day);
    DateTime end = getEndDate(day);

    // Flux pour chaque type de transaction
    Stream<List<Map<String, dynamic>>> revenueStream =
        transactionsByType(userId, 'incomes', start, end);
    Stream<List<Map<String, dynamic>>> expenseStream =
        transactionsByType(userId, 'expenses', start, end);
    Stream<List<Map<String, dynamic>>> debtStream =
        transactionsByType(userId, 'debts', start, end);

    return StreamBuilder<List<List<Map<String, dynamic>>>>(
      stream: _zipStreams(revenueStream, expenseStream, debtStream),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(top: 5, bottom: 5, right: 10.0, left: 10.0),
            padding: EdgeInsets.all(5),
            height: 150,
            width: double.maxFinite,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Theme.of(context).highlightColor,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                          top: 5, bottom: 5, right: 10.0, left: 10.0),
                      padding: EdgeInsets.all(5),
                      height: 40.0,
                      width: 40.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Theme.of(context).highlightColor,
                      ),
                    ),
                    sizedbox2,
                    Container(
                      margin: EdgeInsets.only(
                          top: 5, bottom: 5, right: 10.0, left: 10.0),
                      padding: EdgeInsets.all(5),
                      height: 10,
                      width: MediaQuery.of(context).size.width * 0.65,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Theme.of(context).highlightColor,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 15, right: 10.0, left: 10.0),
                      padding: EdgeInsets.all(5),
                      height: 40.0,
                      width: 40.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Theme.of(context).highlightColor,
                      ),
                    ),
                    sizedbox2,
                    Container(
                      margin: EdgeInsets.only(top: 15, right: 10.0, left: 10.0),
                      padding: EdgeInsets.all(5),
                      height: 10,
                      width: MediaQuery.of(context).size.width * 0.65,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Theme.of(context).highlightColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }

        // Calculer les totaux
        double totalRevenue = 0.0;
        double totalExpenses = 0.0;
        double totalDebts = 0.0;

        if (snapshot.hasData) {
          final revenues = snapshot.data![0];
          final expenses = snapshot.data![1];
          final debts = snapshot.data![2];

          totalRevenue = revenues.fold(
              0.0, (sum, item) => sum + (item['price']?.toDouble() ?? 0.0));
          totalExpenses = expenses.fold(
              0.0, (sum, item) => sum + (item['price']?.toDouble() ?? 0.0));
          totalDebts = debts.fold(
              0.0, (sum, item) => sum + (item['price']?.toDouble() ?? 0.0));
        }

        return Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 10.0,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).highlightColor),
            borderRadius: BorderRadius.circular(15.0),
          ),
          height: 150.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTransactionDetail(
                  translate("title.title_1"),
                  '\$${totalRevenue.toStringAsFixed(2)}',
                  Colors.green,
                  Icon(
                    Icons.money_sharp,
                  ),
                  context),
              sizedbox,
              _buildTransactionDetail(
                  translate("title.title_2"),
                  '\$${totalExpenses.toStringAsFixed(2)}',
                  Colors.red,
                  Icon(
                    Icons.attach_money,
                  ),
                  context),
              sizedbox,
              _buildTransactionDetail(
                  translate("title.title_3"),
                  '\$${totalDebts.toStringAsFixed(2)}',
                  Colors.lightBlueAccent,
                  Icon(
                    Icons.account_balance,
                  ),
                  context),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppTextLarge(
                    text: day,
                    color: Theme.of(context).colorScheme.inverseSurface,
                    size: 16.0,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Stream<List<List<Map<String, dynamic>>>> _zipStreams(
      Stream<List<Map<String, dynamic>>> stream1,
      Stream<List<Map<String, dynamic>>> stream2,
      Stream<List<Map<String, dynamic>>> stream3) {
    return Stream<List<List<Map<String, dynamic>>>>.multi((controller) {
      List<Map<String, dynamic>>? latestRevenues;
      List<Map<String, dynamic>>? latestExpenses;
      List<Map<String, dynamic>>? latestDebts;

      late StreamSubscription<List<Map<String, dynamic>>> sub1;
      late StreamSubscription<List<Map<String, dynamic>>> sub2;
      late StreamSubscription<List<Map<String, dynamic>>> sub3;

      sub1 = stream1.listen((data) {
        latestRevenues = data;
        if (latestExpenses != null && latestDebts != null) {
          controller.add([latestRevenues!, latestExpenses!, latestDebts!]);
        }
      });

      sub2 = stream2.listen((data) {
        latestExpenses = data;
        if (latestRevenues != null && latestDebts != null) {
          controller.add([latestRevenues!, latestExpenses!, latestDebts!]);
        }
      });

      sub3 = stream3.listen((data) {
        latestDebts = data;
        if (latestRevenues != null && latestExpenses != null) {
          controller.add([latestRevenues!, latestExpenses!, latestDebts!]);
        }
      });

      controller.onCancel = () {
        sub1.cancel();
        sub2.cancel();
        sub3.cancel();
      };
    });
  }

  Widget _buildTransactionDetail(String title, String amount, Color color,
      Icon icon, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).highlightColor),
                borderRadius: BorderRadius.circular(5),
              ),
              child: icon,
            ),
            sizedbox2,
            AppText(
                text: title,
                color: Theme.of(context).colorScheme.inverseSurface),
          ],
        ),
        AppText(text: amount, color: color),
      ],
    );
  }
}
