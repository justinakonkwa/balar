import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AllFunctions {
  Future<String?> getUserId() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      return user.uid;
    } else {
      return null;
    }
  }

  static Future<void> addExpense(
      String userId,
      String category,
      double price,
      String description,
      String? currency,
      DateTime? date,
      BuildContext context) async {
    await _addTransaction(
      userId,
      category,
      price,
      description,
      currency,
      date,
      'expenses', // Collection pour les dépenses
      context,
    );
  }

  static Future<void> addIncome(
      String userId,
      String category,
      double price,
      String description,
      String? currency,
      DateTime? date,
      BuildContext context) async {
    await _addTransaction(
      userId,
      category,
      price,
      description,
      currency,
      date,
      'incomes', // Collection pour les revenus
      context,
    );
  }

  static Future<void> addDebt(
      String userId,
      String category,
      double price,
      String description,
      String? currency,
      DateTime? date,
      BuildContext context) async {
    await _addTransaction(
      userId,
      category,
      price,
      description,
      currency,
      date,
      'debts', // Collection pour les dettes
      context,
    );
  }

  // Méthode générique pour ajouter une transaction
  static Future<void> _addTransaction(
      String userId,
      String category,
      double price,
      String description,
      String? currency,
      DateTime? date,
      String collection, // Nom de la collection
      BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection(collection) // Utiliser la collection passée en paramètre
          .add({
        'category': category,
        'price': price,
        'description': description,
        'currency': currency,
        'date': date != null ? date.toIso8601String() : null,
      });

      // Afficher une boîte de dialogue de confirmation
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Succès'),
            content: Text('Transaction ajoutée avec succès.'),
            actions: <Widget>[
              MaterialButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Afficher une boîte de dialogue d'erreur
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Erreur'),
            content: Text(
                'Échec de l\'ajout de la transaction. Veuillez réessayer plus tard.'),
            actions: <Widget>[
              MaterialButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      print('Erreur lors de l\'ajout de la transaction: $e');
    }
  }

  // Nouvelle méthode pour écouter les dépenses
  static Stream<List<Map<String, dynamic>>> listenToExpenses(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .snapshots()
        .map((querySnapshot) {
      List<Map<String, dynamic>> expensesList = [];
      querySnapshot.docs.forEach((DocumentSnapshot document) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        data['id'] = document.id; // Ajouter l'ID du document aux données
        expensesList.add(data);
      });
      return expensesList;
    });
  }

  // Nouvelle méthode pour écouter les revenus
  static Stream<List<Map<String, dynamic>>> listenToIncomes(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('incomes')
        .snapshots()
        .map((querySnapshot) {
      List<Map<String, dynamic>> incomesList = [];
      querySnapshot.docs.forEach((DocumentSnapshot document) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        data['id'] = document.id; // Ajouter l'ID du document aux données
        incomesList.add(data);
      });
      return incomesList;
    });
  }

  // Nouvelle méthode pour écouter les dettes
  static Stream<List<Map<String, dynamic>>> listenToDebts(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('debts')
        .snapshots()
        .map((querySnapshot) {
      List<Map<String, dynamic>> debtsList = [];
      querySnapshot.docs.forEach((DocumentSnapshot document) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        data['id'] = document.id; // Ajouter l'ID du document aux données
        debtsList.add(data);
      });
      return debtsList;
    });
  }

  // Méthode générique pour écouter les transactions en fonction du type
  static Stream<List<Map<String, dynamic>>> listenToTransactions(
      String userId, String collection) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection(collection)
        .snapshots()
        .map((querySnapshot) {
      List<Map<String, dynamic>> transactionList = [];
      querySnapshot.docs.forEach((DocumentSnapshot document) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        data['id'] = document.id; // Ajouter l'ID du document aux données
        transactionList.add(data);
      });
      return transactionList;
    });
  }
}
