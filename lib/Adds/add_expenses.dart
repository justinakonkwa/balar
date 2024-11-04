import 'package:balare/Modeles/firebase/add_transaction.dart';
import 'package:balare/screens/history_screen.dart';
import 'package:balare/widget/app_text.dart';
import 'package:balare/widget/app_text_large.dart';
import 'package:balare/widget/bouton_next.dart';
import 'package:balare/widget/constantes.dart';
import 'package:balare/widget/message_widget.dart';
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
  DateTime _selectedDate = DateTime.now(); // Date actuelle par défaut
  bool _isSubmitting = false; // État de soumission

  // Méthode pour ajouter une transaction
  Future<void> addTransaction(BuildContext context) async {
    if (_isSubmitting) return; // Eviter la soumission multiple
    setState(() {
      _isSubmitting = true; // Désactiver le bouton
    });

    String userId = (await FirebaseAuth.instance.currentUser)?.uid ?? '';

    // Validation des champs
    if (_categoryController.text.isEmpty) {
      _isSubmitting = false;
      // _showErrorDialosg('La catégorie est obligatoire.');
      showCustomSnackBar(context, "La catégorie est obligatoire.");
      return;
    }

    if (_priceController.text.isEmpty) {
      _isSubmitting = false;
      showCustomSnackBar(context, 'Le montant est obligatoire.');
      return;
    }

    if (_selectedDate == null) {
      _isSubmitting = false;
      showCustomSnackBar(context, "La date est obligatoire.");
      return;
    }

    if (widget.type == null) {
      // Aucune transaction sélectionnée
      return;
    }

    try {
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

      Navigator.pop(context);
      // Optionnel: Afficher un message de succès ou naviguer
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transaction ajoutée avec succès!')),
      );
      Navigator.pop(context);
      // Réinitialiser les champs si nécessaire
      _categoryController.clear();
      _priceController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedCurrency = null; // Réinitialiser la devise
        _selectedDate = DateTime.now(); // Réinitialiser la date à aujourd'hui
      });
    } catch (e) {
      // Gérer les erreurs, afficher un message d'erreur si nécessaire
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'ajout de la transaction.')),
      );
    } finally {
      setState(() {
        _isSubmitting = false; // Réactiver le bouton
      });
    }
  }

  // Sélection de la date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate, // Utiliser la date sélectionnée
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate; // Mettre à jour la date
      });
    }
  }

  title() {
    if (widget.type == 'incomes') {
      return AppText(text: 'Révenus');
    } else if (widget.type == 'expenses') {
      return AppText(text: 'Dépenses');
    } else {
      return AppText(text: 'Dettes');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Hero(
          tag: 'Back',
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistoriquePage(
                    type: widget.type,
                  ),
                ),
              );
            },
            child: Row(
              children: [
                Icon(Icons.arrow_back),
                SizedBox(
                  width: 5,
                ),
                AppText(text: 'Back'),
              ],
            ),
          ),
        ),
        title: title(),
        centerTitle: true,
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
                      borderRadius: BorderRadius.circular(15),
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
                      borderRadius: BorderRadius.circular(15),
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
                            padding: EdgeInsets.only(
                              left: 20,
                            ),
                            controller: _priceController,
                            style: TextStyle(
                                fontFamily: 'Montserrat',
                                color:
                                    Theme.of(context).colorScheme.onBackground),
                            keyboardType: TextInputType.number,
                            placeholder: 'Montant',
                            decoration: BoxDecoration(
                              color: Theme.of(context).highlightColor,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            suffix: Padding(
                              padding: EdgeInsets.only(right: 20.0),
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
                            borderRadius: BorderRadius.circular(15),
                            color: Theme.of(context).highlightColor,
                          ),
                          width: MediaQuery.of(context).size.width * 0.27,
                          child: DropdownButton<String>(
                            underline: SizedBox(),
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
                                child: AppText(text: value),
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
                  child: AppText(
                    text: 'Date: ${_selectedDate.toLocal()}'.split(' 1')[0],
                  ),
                ),
                SizedBox(height: 40),
                NextButton(
                  onTap: () {
                    addTransaction(
                        context); // Appeler la méthode pour ajouter une transaction
                  },
                  child: _isSubmitting
                      ? CupertinoActivityIndicator()
                      : AppText(
                          text: 'Ajouter ${widget.type.capitalizeFirst}',
                          color: Theme.of(context).colorScheme.surface,
                        ),
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
