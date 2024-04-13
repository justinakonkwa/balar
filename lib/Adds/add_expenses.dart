import 'package:flutter/material.dart';
import 'package:balare/Modeles/firebase.dart';

class AddItemPage extends StatefulWidget {
  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Item'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(labelText: 'Category'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the category';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the price';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              MaterialButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      String? userId = await AllFunctions()
                          .getUserId(); // Récupérer l'ID de l'utilisateur
                      if (userId != null) {
                        await AllFunctions.addExpense(
                          userId,
                          _nameController.text,
                          _categoryController.text,
                          double.parse(
                              _priceController.text), // Convertir en double
                          context,
                        );
                      } else {
                        // L'utilisateur n'est pas connecté
                        print('User not logged in.');
                      }
                    } catch (e) {
                      // Une erreur s'est produite lors de l'ajout de la dépense
                      print('Error adding expense: $e');
                    }
                  }
                },
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: AddItemPage(),
  ));
}
