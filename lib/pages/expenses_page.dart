import 'package:balare/Adds/add_expenses.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:balare/Modeles/firebase.dart';

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({Key? key}) : super(key: key);

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expenses'),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: AllFunctions.listenToExpenses(user!.uid), // Utiliser userId ici
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<Map<String, dynamic>>? expenses = snapshot.data;
            if (expenses != null && expenses.isNotEmpty) {
              return ListView.builder(
                itemCount: expenses.length,
                itemBuilder: (context, index) {
                  // Récupérer les données de chaque dépense
                  Map<String, dynamic> expenseData = expenses[index];
                  return Card(
                    child: ListTile(
                            title: Text(expenseData['name']),
                            subtitle: Text('Category: ${expenseData['category']}, Price: \$${expenseData['price']}'),
                          ),
                  );
                },
              );
            } else {
              return Center(child: Text('No expenses found.'));
            }
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: ((context) => AddItemPage())));
        },
        child: const Text('Add'),
      ),
    );
  }
}
