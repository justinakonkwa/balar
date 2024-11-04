// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'dart:io';

import 'package:balare/Modeles/firebase/user_service.dart';
import 'package:balare/config/utils.dart';
import 'package:balare/language/choose_language.dart';
import 'package:balare/theme/theme_provider.dart';
import 'package:balare/widget/app_text.dart';
import 'package:balare/widget/app_text_large.dart';
import 'package:balare/widget/constantes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isEditing = false; // Gérer l'état d'édition
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  File? _profileImage; // Variable pour le fichier d'image local
  late SettingsService settingsService;

  @override
  void initState() {
    super.initState();
    // Initialize the settings service and fetch user data
    setState(() {
      settingsService = SettingsService(
        context: context,
        nameController: nameController,
        phoneController: phoneController,
      );
    });
    fetchUserData();
  }

  void fetchUserData() async {
    await settingsService.fetchUserData();
    setState(() {}); // Rafraîchir l'interface après la récupération des données
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: AppText(
          text: translate("settings.title"),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20),
        child: ListView(
          children: [
            sizedbox,
            AppText(
              text: translate("settings.general").toUpperCase(),
              color: Theme.of(context).colorScheme.onBackground,
            ),
            sizedbox,
            sizedbox,
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
                            backgroundImage: _profileImage != null
                                ? FileImage(_profileImage!)
                                : null,
                            child: _profileImage == null
                                ? AppTextLarge(
                                    text: nameController.text.isNotEmpty
                                        ? nameController.text[0]
                                        : '',
                                    size: 40,
                                  )
                                : null,
                          ),
                          GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (BuildContext context) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(
                                        leading: Icon(CupertinoIcons.camera),
                                        title: Text('Prendre une photo'),
                                        onTap: () async {
                                          await settingsService.pickImage(
                                              ImageSource.camera, (imageFile) {
                                            setState(() {
                                              _profileImage =
                                                  imageFile; // Mettre à jour l'état
                                            });
                                          });
                                          Navigator.pop(context);
                                        },
                                      ),
                                      ListTile(
                                        leading: Icon(CupertinoIcons.photo),
                                        title:
                                            Text('Choisir depuis la galerie'),
                                        onTap: () async {
                                          await settingsService.pickImage(
                                              ImageSource.gallery, (imageFile) {
                                            setState(() {
                                              _profileImage =
                                                  imageFile; // Mettre à jour l'état
                                            });
                                          });
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
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
                                  child: CupertinoTextField(
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .inverseSurface,
                                    ),
                                    controller: nameController,
                                    placeholder: 'Entrez votre nom',
                                    cursorColor: Theme.of(context)
                                        .colorScheme
                                        .inverseSurface,
                                  ),
                                )
                              : AppText(text: nameController.text),
                          sizedbox,
                          isEditing
                              ? SizedBox(
                                  width: 150,
                                  child: CupertinoTextField(
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .inverseSurface,
                                    ),
                                    controller: phoneController,
                                    placeholder: 'Entrez votre nom',
                                    cursorColor: Theme.of(context)
                                        .colorScheme
                                        .inverseSurface,
                                  ),
                                )
                              : AppText(text: phoneController.text),
                        ],
                      ),
                      isEditing
                          ? IconButton(
                              icon: Icon(Icons.save),
                              onPressed: () {
                                settingsService
                                    .saveChanges(); // Sauvegarder les modifications
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
            SizedBox(height: 15),

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
                  myCard(
                    context,
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
                        context,
                        ontap: () => provider.changeTheme(!theme),
                        icon: CupertinoIcons.brightness,
                        title: theme
                            ? translate('theme.light')
                            : translate('theme.dark'),
                        icon2: CupertinoIcons.light_max,
                        showLast: true,
                      );
                    },
                  ),
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
              child: Column(
                children: [
                  myCard(context,
                      ontap: () {},
                      icon: CupertinoIcons.phone,
                      title: translate("settings.contactUs"),
                      showLast: false),
                  myCard(context, ontap: () {
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
            // AppText(
            //   text: translate("settings.general").toUpperCase(),
            //   color: Theme.of(context).colorScheme.onBackground,
            // ),
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
                  myCard(context, ontap: () {
                    myLaunchUrl(
                        'https://raw.githubusercontent.com/SleentOS/compTIA-Acronyms-Terms-And-Conditions/main/README.md');
                  },
                      icon: Icons.privacy_tip_outlined,
                      title: translate("settings.privacy_policy"),
                      showLast: false),
                  myCard(context, ontap: () {
                    myLaunchUrl(
                        'https://raw.githubusercontent.com/SleentOS/compTIA-Acronyms-Terms-And-Conditions/main/README.md');
                  },
                      icon: CupertinoIcons.arrow_3_trianglepath,
                      title: translate("settings.terms_and_conditions"),
                      showLast: true),
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
              child: myCard(context, ontap: () {
                settingsService.signOut(context);
              }, icon: Icons.exit_to_app, title: 'Sign Out', showLast: true),
            )
          ],
        ),
      ),
    );
  }

  Widget myCard(BuildContext context,
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
}

