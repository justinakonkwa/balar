import 'dart:ffi';

import 'package:balare/Modeles/firebase.dart';
import 'package:balare/widget/app_text.dart';
import 'package:balare/widget/app_text_large.dart';
import 'package:balare/widget/bouton_next.dart';
import 'package:balare/widget/constantes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransactionFormPage extends StatefulWidget {
  final String type;
  const TransactionFormPage({required this.type, super.key});

  @override
  _TransactionFormPageState createState() => _TransactionFormPageState();
}

class _TransactionFormPageState extends State<TransactionFormPage> {
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedCurrency; // Gérer les devises
  DateTime? _selectedDate; // Gérer la date

  // Méthode pour ajouter une transaction
  Future<void> addTransaction(BuildContext context) async {
    String userId = (await FirebaseAuth.instance.currentUser)?.uid ?? '';

    if (widget.type == null) {
      // Aucune transaction sélectionnée
      return;
    }

    if (widget.type == 'incomes') {
      await AllFunctions.addIncome(
        userId,
        _categoryController.text,
        double.tryParse(_priceController.text) ?? 0,
        _descriptionController.text,
        _selectedCurrency,
        _selectedDate,
        context,
      );
    } else if (widget.type == 'expenses') {
      await AllFunctions.addExpense(
        userId,
        _categoryController.text,
        double.tryParse(_priceController.text) ?? 0,
        _descriptionController.text,
        _selectedCurrency,
        _selectedDate,
        context,
      );
    } else if (widget.type == 'debts') {
      await AllFunctions.addDebt(
        userId,
        _categoryController.text,
        double.tryParse(_priceController.text) ?? 0,
        _descriptionController.text,
        _selectedCurrency,
        _selectedDate,
        context,
      );
    }
  }

  // Sélection de la date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter une Transaction'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              if (widget.type != null) ...[
                AppTextLarge(
                  text: 'Categories',
                  size: 18,
                ),
                sizedbox,
                Container(
                  height: 50,
                  child: CupertinoTextField(
                    controller: _categoryController,
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: Theme.of(context).colorScheme.onBackground),
                    keyboardType: TextInputType.name,
                    placeholder: 'Categories',
                    decoration: BoxDecoration(
                      color: Theme.of(context).highlightColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                sizedbox,
                sizedbox,
                AppTextLarge(
                  text: 'Description',
                  size: 18,
                ),
                sizedbox,
                Container(
                  child: CupertinoTextField(
                    controller: _descriptionController,
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: Theme.of(context).colorScheme.onBackground),
                    keyboardType: TextInputType.name,
                    placeholder: 'Description',
                    decoration: BoxDecoration(
                      color: Theme.of(context).highlightColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    maxLines: 4,
                  ),
                ),
                sizedbox,
                sizedbox,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppTextLarge(
                          text: 'Montant',
                          size: 18,
                        ),
                        sizedbox,
                        Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: CupertinoTextField(
                            padding: EdgeInsets.only(left: 20,),
                            controller: _priceController,
                            style: TextStyle(
                                fontFamily: 'Montserrat',
                                color:
                                    Theme.of(context).colorScheme.onBackground),
                            keyboardType: TextInputType.number,
                            placeholder: 'Montant',
                            decoration: BoxDecoration(
                              color: Theme.of(context).highlightColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            suffix: Padding(
                              padding:  EdgeInsets.only(right: 20.0),
                              child: Icon(Icons.money),
                            ),

                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppTextLarge(
                          text: 'Devise',
                          size: 18,
                        ),
                        sizedbox,
                        Container(
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Theme.of(context).highlightColor,
                          ),
                          width: MediaQuery.of(context).size.width * 0.27,
                          child: DropdownButton<String>(
                            value: _selectedCurrency,
                            hint: AppText(text: 'Devise'),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedCurrency = newValue;
                              });
                            },
                            items: <String>[
                              'USD',
                              'CDF',
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),
                AppTextLarge(
                  text: 'Date',
                  size: 18,
                ),
                sizedbox,
                NextButton(
                  color: Theme.of(context).highlightColor,
                  onTap: () {
                    _selectDate(context);
                  },
                  child: Text(
                    _selectedDate == null
                        ? 'Sélectionner la Date'
                        : 'Date: le ' +
                            'Date: ${_selectedDate!.toLocal()}'.split(' ')[1],
                  ),
                ),
                SizedBox(height: 20),
                NextButton(
                  onTap: () {
                    addTransaction(
                        context); // Appeler la méthode pour ajouter une transaction
                  },
                  child: Text('Ajouter ${widget.type.capitalizeFirst}'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String get capitalizeFirst => '${this[0].toUpperCase()}${substring(1)}';
}
