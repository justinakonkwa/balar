import 'package:balare/Modeles/firebase.dart';
import 'package:balare/widget/app_text_large.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widget/bouton_next.dart';

class TransactionFormPage extends StatefulWidget {
  final String type; // Le type de transaction (revenus, dépenses, dettes)
  const TransactionFormPage({required this.type, super.key});

  @override
  _TransactionFormPageState createState() => _TransactionFormPageState();
}

class _TransactionFormPageState extends State<TransactionFormPage> {
  final TextEditingController _nameController = TextEditingController();
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
        _nameController.text,
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
        _nameController.text,
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
        _nameController.text,
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            if (widget.type != null) ...[
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nom'),
              ),
              TextField(
                controller: _categoryController,
                decoration: InputDecoration(labelText: 'Catégorie'),
              ),
              TextField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Prix'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _selectDate(context),
                child: Text(
                  _selectedDate == null
                      ? 'Sélectionner la Date'
                      : 'Date: ${_selectedDate!.toLocal()}'.split(' ')[0],
                ),
              ),
              DropdownButton<String>(
                value: _selectedCurrency,
                hint: Text('Sélectionner la devise'),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCurrency = newValue;
                  });
                },
                items: <String>['USD', 'EUR', 'XAF']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  addTransaction(context); // Appeler la méthode pour ajouter une transaction
                },
                child: Text('Ajouter ${widget.type.capitalizeFirst}'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String get capitalizeFirst => '${this[0].toUpperCase()}${substring(1)}';
}
