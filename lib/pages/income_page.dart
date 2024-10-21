import 'package:balare/screens/plan_epargne_screen.dart';
import 'package:balare/widget/app_text.dart';
import 'package:balare/widget/app_text_large.dart';
import 'package:balare/widget/bouton_next.dart';
import 'package:balare/widget/constantes.dart';
import 'package:balare/widget/textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class IncomePage extends StatefulWidget {
  const IncomePage({super.key});

  @override
  State<IncomePage> createState() => _IncomePageState();
}

class _IncomePageState extends State<IncomePage> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _objectifController = TextEditingController();
  DateTime? _selectedDate;
  String _selectedFrequency = 'défaut';

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

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
                    AppText(text: 'Plan d\'Epargnes'),
                  ],
                ),
              ),
            ),
            sizedbox,
            sizedbox,
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (BuildContext context) {
                    return Padding(
                      padding: MediaQuery.of(context).viewInsets,
                      child: Container(
                        padding: EdgeInsets.only(
                            left: 15, right: 15, top: 20, bottom: 30),
                        height: 450,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.background,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: StatefulBuilder(
                          builder: (BuildContext context,
                              StateSetter setModalState) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    AppTextLarge(text: 'Ajouter une épargne'),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Icon(
                                        Icons.cancel_outlined,
                                        color: Colors.red,
                                      ),
                                    )
                                  ],
                                ),
                                sizedbox, sizedbox,
                                sizedbox,
                                textfield(
                                  context,
                                  "Nom de l\'épargne",
                                  _nomController,
                                  double.maxFinite,
                                  Icon(Icons.text_fields_sharp),
                                ),
                                sizedbox,
                                sizedbox,
                                textfield(
                                  context,
                                  "Objectif \$",
                                  _objectifController,
                                  double.maxFinite,
                                  Icon(Icons.bar_chart),
                                ),

                                sizedbox,
                                sizedbox,
                                // Sélection de la date
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      alignment: Alignment.center,
                                      width: MediaQuery.of(context).size.width *
                                          0.78,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        border: Border.all(
                                          color:
                                              Theme.of(context).highlightColor,
                                        ),
                                      ),
                                      child: AppText(
                                        text: _selectedDate == null
                                            ? 'Choisir une date'
                                            : 'Date : ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        _selectDate(context).then((_) {
                                          setModalState(() {
                                            // Rafraîchir l'état du modal après avoir sélectionné la date
                                          });
                                        });
                                      },
                                      child: Container(
                                        height: 50,
                                        width: 50,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                          border: Border.all(
                                            color: Theme.of(context)
                                                .highlightColor,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.arrow_drop_down,
                                          size: 40,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                sizedbox,
                                sizedbox,

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      alignment: Alignment.center,
                                      width: MediaQuery.of(context).size.width *
                                          0.78,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        border: Border.all(
                                          color:
                                              Theme.of(context).highlightColor,
                                        ),
                                      ),
                                      child: AppText(
                                        text: _selectedFrequency,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        _selectDate(context).then((_) {
                                          setModalState(() {
                                            // Rafraîchir l'état du modal après avoir sélectionné la date
                                          });
                                        });
                                      },
                                      child: Container(
                                        alignment: Alignment.center,
                                        height: 50,
                                        width:
                                            50.0, // S'étendre sur toute la largeur disponible
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                          border: Border.all(
                                            color: Theme.of(context)
                                                .highlightColor,
                                          ),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          // Cacher la ligne sous le DropdownButton
                                          child: DropdownButton<String>(
                                            padding:
                                                EdgeInsets.only(right: 7.0),
                                            icon: Center(
                                              child: Icon(
                                                Icons.arrow_drop_down,
                                                size: 35.0,
                                              ),
                                            ),
                                            isExpanded:
                                                true, // Permet au DropdownButton de prendre toute la largeur
                                            items: <String>[
                                              'Par Jour',
                                              'Par Semaine',
                                              'par Mois',
                                              'défaut',
                                            ].map<DropdownMenuItem<String>>(
                                                (String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: AppText(text: value),
                                              );
                                            }).toList(),
                                            onChanged: (String? newValue) {
                                              setModalState(() {
                                                _selectedFrequency = newValue!;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Spacer(),

                                NextButton(
                                  onTap: () async {
                                    await _saveEpargneToFirebase();
                                    Navigator.pop(context);
                                  },
                                  child: AppText(
                                    text: 'Valider',
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    );
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
                    AppText(text: 'Plan d\'Epargnes'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveEpargneToFirebase() async {
    String userId = (await FirebaseAuth.instance.currentUser)?.uid ?? '';

    String nom = _nomController.text;
    String objectif = _objectifController.text;
    String dateLimite = _selectedDate != null
        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
        : 'Non défini';
    String frequence = _selectedFrequency;

    if (nom.isNotEmpty &&
        objectif.isNotEmpty &&
        dateLimite.isNotEmpty &&
        frequence.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('epargnes')
            .add({
          'nom': nom,
          'objectif': double.parse(objectif),
          'date_limite': dateLimite,
          'frequence': frequence,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Clear les champs après soumission
        _nomController.clear();
        _objectifController.clear();
        setState(() {
          _selectedDate = null;
          _selectedFrequency = 'défaut';
        });
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EpargneListPage()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Épargne ajoutée avec succès')));
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erreur : $e')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veuillez remplir tous les champs')));
    }
  }
}
