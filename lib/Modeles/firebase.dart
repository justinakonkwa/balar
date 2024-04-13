import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AllFunctions {

Future<String?> getUserId() async {
  // Récupérer l'utilisateur actuellement connecté
  User? user = FirebaseAuth.instance.currentUser;

  // Vérifier si l'utilisateur est connecté
  if (user != null) {
    // Renvoyer l'ID de l'utilisateur
    return user.uid;
  } else {
    // Aucun utilisateur n'est connecté
    return null;
  }
}


  static Future<void> addExpense(String userId, String name, String category,
      double price, BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('expenses')
          .add({
        'name': name,
        'category': category,
        'price': price,
      });

      // Afficher une boîte de dialogue de confirmation
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('Expense added successfully.'),
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
            title: Text('Error'),
            content: Text('Failed to add expense. Please try again later.'),
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
      print('Error adding expense: $e');
    }
  }
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
}
