import 'dart:io';

import 'package:balare/widget/app_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SettingsService {
  final BuildContext context;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  File? _profileImage; // Variable pour le fichier d'image local
  String?
      _profileImageUrl; // Variable pour stocker l'URL de l'image téléchargée

  SettingsService({
    required this.context,
    required this.nameController,
    required this.phoneController,
  });

  // ------- Fonction pour récupérer les données de l'utilisateur depuis Firestore----------

  Future<void> fetchUserData() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        nameController.text = userDoc['name'] ?? '';
        phoneController.text = userDoc['phoneNumber'] ?? '';
        _profileImageUrl = userDoc['photo']; // Si vous voulez utiliser l'URL
      }
    } catch (e) {
      // Gestion des erreurs
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erreur lors de la récupération des données : $e')),
      );
    }
  }
//---------------- Fonction pour sauvegarder l'image sur storage -----------------

  Future<void> uploadProfileImage(String uid) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('user_profiles')
          .child('$uid.jpg');

      if (_profileImage != null) {
        await ref.putFile(_profileImage!);
        _profileImageUrl = await ref.getDownloadURL();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erreur lors du téléchargement de l\'image : $e')),
      );
    }
  }

  //---------------- Fonction pour la mise a jours du profil----------------

  Future<void> saveChanges() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    if (_profileImage != null) {
      await uploadProfileImage(uid);
    }

    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'name': nameController.text,
        'phoneNumber': phoneController.text,
        'photo': _profileImageUrl, // Utilisez _profileImageUrl ici
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Modifications enregistrées avec succès')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'enregistrement : $e')),
      );
    }
  }

  // ------------------- Fonction pour se deconnecter----------------
  Future<void> signOut(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Affichage du dialog de confirmation
        _showLogoutConfirmationDialog(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la déconnexion : $e')),
      );
    }
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Déconnexion'),
          content: Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
          actions: [
            TextButton(
              child: AppText(
                  text: 'Annuler',
                  color: Theme.of(context).colorScheme.inverseSurface),
              onPressed: () {
                Navigator.of(context).pop(); // Fermer le dialog
              },
            ),
            TextButton(
              child: AppText(
                text: 'Déconnexion',
                color: Theme.of(context).colorScheme.error,
              ),
              onPressed: () async {
                try {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    final String uid = user.uid;
                    // Supprimer le FCM Token
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .update({
                      'fcmToken': '',
                    });

                    // Déconnexion
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacementNamed(context, '/auth');
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Erreur lors de la déconnexion : $e')),
                  );
                } finally {
                  Navigator.of(context)
                      .pop(); // Fermer le dialog après l'action
                }
              },
            ),
          ],
        );
      },
    );
  }

  // ----------- Fonction pour recuperer l'image en local ------------

  Future<void> pickImage(
      ImageSource source, Function(File) onImagePicked) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      onImagePicked(
          imageFile); // Passer le fichier d'image à la fonction de rappel
    }
  }
}
