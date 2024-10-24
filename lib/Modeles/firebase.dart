import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AllFunctions {
  static const String collectionUsers = 'users';
  static const String collectionExpenses = 'expenses';
  static const String collectionIncomes = 'incomes';
  static const String collectionDebts = 'debts';

  Future<String?> getUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }
  final StreamController<String?> _userIdController = StreamController<String?>();

  AllFunctions() {
    // Écoutez les changements d'état de l'utilisateur
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _userIdController.add(user?.uid);
    });
  }

  Stream<String?> getUserIdStream() {
    return _userIdController.stream;
  }

  void dispose() {
    _userIdController.close(); // Fermez le StreamController lorsque vous n'en avez plus besoin
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
      collectionExpenses,
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
      collectionIncomes,
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
      collectionDebts,
      context,
    );
  }

  static Future<void> _addTransaction(
      String userId,
      String category,
      double price,
      String description,
      String? currency,
      DateTime? date,
      String collection,
      BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection(collectionUsers)
          .doc(userId)
          .collection(collection)
          .add({
        'category': category,
        'price': price,
        'description': description,
        'currency': currency,
        'date': date?.toIso8601String(),
      });

      _showDialog(context, 'Succès', 'Transaction ajoutée avec succès.');
    } catch (e) {
      _showDialog(context, 'Erreur',
          'Échec de l\'ajout de la transaction. Veuillez réessayer plus tard.');
      print('Erreur lors de l\'ajout de la transaction: $e');
    }
  }

  static void _showDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
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
  }

  static Stream<List<Map<String, dynamic>>> listenToTransactions(
      String userId, String collection) {
    print("Filtre des transactions pour l'utilisateur : $userId");
    return FirebaseFirestore.instance
        .collection(collectionUsers)
        .doc(userId)
        .collection(collection)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((document) {
        final data = document.data() as Map<String, dynamic>;
        return {
          'id': document.id,
          ...data,
        };
      }).toList();
    });
  }
}
