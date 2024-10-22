import 'package:balare/Adds/add_plan_Epargne.dart';
import 'package:balare/screens/plan_epargne_screen.dart';
import 'package:balare/widget/app_text.dart';
import 'package:balare/widget/constantes.dart';
import 'package:flutter/material.dart';

class IncomePage extends StatefulWidget {
  const IncomePage({super.key});

  @override
  State<IncomePage> createState() => _IncomePageState();
}

class _IncomePageState extends State<IncomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: AppText(text: "Epargnes"),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EpargneListPage()),
                );
              },
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .inverseSurface
                          .withOpacity(0.4),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.account_balance,
                      size: 60,
                    ),
                    sizedbox,
                    AppText(text: 'Mes Epargnes'),
                  ],
                ),
              ),
            ),
            sizedbox,
            sizedbox,
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  elevation: 20,
                  context: context,
                  isScrollControlled: true,
                  builder: (BuildContext context) {
                    return AddPlanEpargne();
                  },
                );
              },
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .inverseSurface
                          .withOpacity(0.4),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_business_outlined,
                      size: 60,
                    ),
                    sizedbox,
                    AppText(text: 'Ajout Plan d\'Epargnes'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
