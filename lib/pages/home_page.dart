import 'package:balare/widget/app_text.dart';
import 'package:balare/widget/app_text_large.dart';
import 'package:balare/widget/bouton_next.dart';
import 'package:balare/widget/constantes.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.black,
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Align(
                alignment: Alignment.bottomLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppTextLarge(
                      text: "Balar",
                      size: 30.0,
                      color: Colors.white,
                    ),
                    const Icon(
                      Icons.circle_notifications_outlined,
                      color: Colors.white,
                    )
                  ],
                ),
              ),
              titlePadding:
                  const EdgeInsets.only(left: 15, bottom: 10, right: 15),
              background: Stack(
                children: [
                  Container(
                    color: Colors.black,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 0.0, top: 50),
                    child: Opacity(
                      opacity: 1.0,
                      child: Image.asset(
                        'assets/logo22.png', // Remplacez par votre chemin d'image
                        height: 100, // Ajustez la hauteur du logo
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate:
                SliverChildBuilderDelegate((BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    NextButton(
                      onTap: () {},
                      color: Theme.of(context).highlightColor,
                      child: Row(
                        children: [
                          Icon(Icons.attach_money, color: Colors.white,),
                          sizedbox2,
                          sizedbox2,
                          AppTextLarge(text: 'Revenus', color: Colors.white,)
                        ],
                      ),
                    ),
                    NextButton(
                      onTap: () {},
                      color: Theme.of(context).highlightColor,
                      child: Row(
                        children: [
                          Icon(Icons.money_off, color: Colors.white,),
                          sizedbox2,
                          sizedbox2,
                          AppTextLarge(text: 'Depenses', color: Colors.white,)
                        ],
                      ),
                    ),
                    NextButton(
                      onTap: () {},
                      color: Theme.of(context).highlightColor,
                      child: Row(
                        children: [
                          Icon(Icons.account_balance, color: Colors.white,),
                          sizedbox2,
                          sizedbox2,
                          AppTextLarge(text: 'Dettes', color: Colors.white,)
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }, childCount: 1),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Container(
                  margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                  padding:
                      EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 10),
                  decoration: BoxDecoration(
                      color: Theme.of(context).highlightColor,
                      borderRadius: BorderRadius.circular(20)),
                  height: 160.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AppTextLarge(
                            text: 'Revenus',
                            color: Colors.white,
                            size: 18,
                          ),
                          AppTextLarge(
                            text: '\$ 180.00',
                            color: Colors.green,
                            size: 20.0,
                          ),
                          AppTextLarge(
                            size: 18,
                            text: 'Depenses',
                            color: Colors.white,
                          ),
                          AppTextLarge(
                            text: '\$ 280.00',
                            color: Colors.red,
                            size: 20.0,
                          ),
                          AppTextLarge(
                            size: 18,
                            text: 'Dettes',
                            color: Colors.white,
                          ),
                          AppTextLarge(
                            text: '\$ 380.00',
                            color: Colors.lightBlueAccent,
                            size: 20,
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          AppTextLarge(
                            text: "Aujourd'hui",
                            color: Colors.white,
                          ),
                          Row(
                            children: [
                              Container(
                                width: 30,
                                height: 40,
                                color: Colors.lightGreenAccent,
                              ),
                              sizedbox2,
                              Container(
                                width: 30,
                                height: 40,
                                color: Colors.redAccent,
                              ),
                              sizedbox2,
                              Container(
                                width: 30,
                                height: 40,
                                color: Colors.lightBlueAccent,
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                );
              },
              childCount: 4, // Nombre d'éléments dans la liste
            ),
          ),
        ],
      ),
    );
  }
}
