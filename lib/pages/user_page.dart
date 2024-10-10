// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'dart:io';

import 'package:balare/config/utils.dart';
import 'package:balare/language/choose_language.dart';
import 'package:balare/theme/theme_provider.dart';
import 'package:balare/widget/app_text.dart';
import 'package:balare/widget/app_text_large.dart';
import 'package:balare/widget/constantes.dart';
import 'package:balare/widget/lign.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isEditing = false; // Gérer l'état d'édition
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Récupérez les données de l'utilisateur dans Firestore
    fetchUserData();
  }

  // Fonction pour récupérer les données de l'utilisateur depuis Firestore
  Future<void> fetchUserData() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (userDoc.exists) {
      setState(() {
        nameController.text = userDoc['name'] ?? ''; // Nom de l'utilisateur
        phoneController.text =
            userDoc['phoneNumber'] ?? ''; // Numéro de téléphone
      });
    }
  }

  // Fonction pour enregistrer les modifications dans Firestore
  Future<void> saveChanges() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'name': nameController.text, // Enregistre le nom modifié
        'phoneNumber': phoneController.text, // Enregistre le numéro modifié
      });

      // Affiche un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Modifications enregistrées avec succès')),
      );
    } catch (e) {
      // Affiche un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'enregistrement : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: AppText(
          text: translate("settings.title"),
        ),
        elevation: 0,
        // actions: [
        //   if (isEditing)
        //     IconButton(
        //       icon: Icon(Icons.save),
        //       onPressed: () {
        //         saveChanges(); // Sauvegarder les modifications
        //         setState(() {
        //           isEditing = false; // Désactiver l'édition après sauvegarde
        //         });
        //       },
        //     ),
        // ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20),
        child: ListView(
          children: [
            Container(
              padding:
                  EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
              height: 120,
              width: double.maxFinite,
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                color: Theme.of(context).highlightColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey,
                            child: AppTextLarge(
                              text: nameController.text.isNotEmpty?
                              nameController.text[0]:'',
                              size: 40,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isEditing =
                                    !isEditing; // Active/désactive l'édition
                              });
                            },
                            child: CircleAvatar(
                              radius: 18.0,
                              backgroundColor: Theme.of(context).highlightColor,
                              child: Icon(CupertinoIcons.camera),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          isEditing
                              ? SizedBox(
                                  width: 150,
                                  child: TextField(
                                    controller: nameController,
                                    decoration: InputDecoration(
                                      hintText: 'Entrez votre nom',
                                    ),
                                  ),
                                )
                              : AppText(text: nameController.text),
                          isEditing
                              ? SizedBox(
                                  width: 150,
                                  child: TextField(
                                    controller: phoneController,
                                    decoration: InputDecoration(
                                      hintText: 'Entrez votre numéro',
                                    ),
                                  ),
                                )
                              : AppText(text: phoneController.text),
                        ],
                      ),
                      isEditing
                          ? IconButton(
                              icon: Icon(Icons.save),
                              onPressed: () {
                                saveChanges(); // Sauvegarder les modifications
                                setState(() {
                                  isEditing =
                                      false; // Désactiver l'édition après sauvegarde
                                });
                              },
                            )
                          : IconButton(
                              icon: Icon(
                                  CupertinoIcons.pencil_ellipsis_rectangle),
                              onPressed: () {
                                setState(() {
                                  isEditing =
                                      !isEditing; // Active/désactive l'édition
                                });
                              },
                            )
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            AppText(
              text: translate("settings.general").toUpperCase(),
              color: Theme.of(context).colorScheme.onBackground,
            ),
            Container(
              margin: const EdgeInsets.only(
                top: 8,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).highlightColor,
                borderRadius: const BorderRadius.all(
                  Radius.circular(8),
                ),
              ),
              child: Column(
                children: [
                  card1(
                    ontap: () {
                      showI18nDialog(context: context);
                    },
                    icon: Icons.translate_outlined,
                    title: translate("settings.language"),
                    icon2: Icons.switch_right_outlined,
                    showLast: false,
                  ),
                  Consumer<ThemeProvider>(
                    builder: (context, provider, child) {
                      bool theme = provider.currentTheme;

                      return myCard(
                        ontap: () => provider.changeTheme(!theme),
                        context: context,
                        fistWidget: Icon(CupertinoIcons.brightness),
                        title: theme
                            ? translate('theme.light')
                            : translate('theme.dark'),
                        secondWidget: Icon(CupertinoIcons.light_max),
                        showLast: true,
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            AppText(
              text: translate("settings.general").toUpperCase(),
              color: Theme.of(context).colorScheme.onBackground,
            ),
            Container(
              margin: const EdgeInsets.only(
                top: 8,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).highlightColor,
                borderRadius: const BorderRadius.all(Radius.circular(8)),
              ),
              child: Column(
                children: [
                  card1(
                      ontap: () {},
                      icon: CupertinoIcons.phone,
                      title: translate("settings.contactUs"),
                      showLast: false),
                  card1(
                      ontap: () {
                        var url = Platform.isAndroid
                            ? 'https://play.google.com/store/apps/details?id=com.wexende.expensexai'
                            : 'https://apps.apple.com/us/app/money-ai/id6474200248';
                        myLaunchUrl(url);
                      },
                      icon: Icons.star_half_outlined,
                      title: translate("settings.leaveReview"),
                      showLast: true),
                ],
              ),
            ),
            SizedBox(height: 20),
            AppText(
              text: translate("settings.general").toUpperCase(),
              color: Theme.of(context).colorScheme.onBackground,
            ),
            Container(
              margin: const EdgeInsets.only(
                top: 8,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).highlightColor,
                borderRadius: const BorderRadius.all(
                  Radius.circular(8),
                ),
              ),
              child: Column(
                children: [
                  card1(
                      ontap: () {
                        myLaunchUrl(
                            'https://raw.githubusercontent.com/SleentOS/compTIA-Acronyms-Terms-And-Conditions/main/README.md');
                      },
                      icon: Icons.privacy_tip_outlined,
                      title: translate("settings.privacy_policy"),
                      showLast: false),
                  card1(
                      ontap: () {
                        myLaunchUrl(
                            'https://raw.githubusercontent.com/SleentOS/compTIA-Acronyms-Terms-And-Conditions/main/README.md');
                      },
                      icon: CupertinoIcons.arrow_3_trianglepath,
                      title: translate("settings.terms_and_conditions"),
                      showLast: false),
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.only(
                top: 8,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).highlightColor,
                borderRadius: const BorderRadius.all(Radius.circular(8)),
              ),
              child: card1(
                  ontap: () {
                    _signOut(context);
                  },
                  icon: Icons.exit_to_app,
                  title: 'Sign Out',
                  showLast: true),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      // Obtenir l'ID de l'utilisateur actuellement connecté
      final String uid = FirebaseAuth.instance.currentUser!.uid;

      // Référence à Firestore
      final usersRef = FirebaseFirestore.instance.collection('users');

      // Mettre à jour le document de l'utilisateur pour supprimer la valeur du token
      // en définissant sa valeur à une chaîne vide
      await usersRef.doc(uid).update({'fcmToken': ''});

      // Se déconnecter
      await FirebaseAuth.instance.signOut();

      // Rediriger l'utilisateur
      Navigator.pushReplacementNamed(context, '/intro');
    } catch (e) {
      print('Erreur pendant la déconnexion ou la mise à jour du token : $e');
      // Afficher un message d'erreur à l'utilisateur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la déconnexion. Veuillez réessayer.'),
        ),
      );
    }
  }

  card1(
      {required Function() ontap,
      required IconData icon,
      required String title,
      IconData icon2 = Icons.navigate_next_outlined,
      bool showLast = false}) {
    return InkWell(
      onTap: ontap,
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              icon,
              // color: AppColors.bigTextColor,
            ),
            title: Container(
              alignment: Alignment.centerLeft,
              child: AppText(
                text: title,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            trailing: Icon(
              icon2,
              // color: AppColors.bigTextColor,
            ),
            // subtitle: Container(),
          ),
          if (!showLast)
            Container(
              margin: EdgeInsets.only(left: 60),
              height: 0.5,
              color: Theme.of(context).colorScheme.secondary,
            )
        ],
      ),
    );
  }

  Widget myCard({
    required BuildContext context,
    required Function() ontap,
    required Widget fistWidget,
    required String title,
    Widget secondWidget = const Icon(
      CupertinoIcons.brightness,
    ),
    bool showLast = false,
  }) {
    return InkWell(
      onTap: ontap,
      child: Column(
        children: [
          ListTile(
            leading: fistWidget,
            title: Container(
              alignment: Alignment.centerLeft,
              child: AppText(
                text: title,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            trailing: secondWidget,
            // subtitle: Container(),
          ),
          if (!showLast) const Lign(indent: 60, endIndent: 0)
        ],
      ),
    );
  }
}
