import 'dart:io';
import 'package:balare/widget/app_text.dart';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class BudgetPage extends StatefulWidget {
  @override
  _BudgetPageState createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  // Contrôleur pour capturer l'écran
  final ScreenshotController _screenshotController = ScreenshotController();

  double totalContributions = 200.0; // Exemple
  double objectif = 400.0; // Exemple

  @override
  Widget build(BuildContext context) {
    double progression = (totalContributions / objectif).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: Text('Mon Budget'),
      ),
      body: Screenshot(
        controller: _screenshotController,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Montant total des contributions : $totalContributions €',
                style: TextStyle(fontSize: 18)),
            Text('Objectif : $objectif €', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            LinearProgressIndicator(value: progression),
            SizedBox(height: 10),
            Text('Progression : ${(progression * 100).toStringAsFixed(2)} %',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _captureAndShareBudget,
              child: AppText(text: 'Partager mon budget'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _captureAndShareBudget() async {
    // Capture d'écran
    final image = await _screenshotController.capture();

    if (image != null) {
      // Enregistrement de l'image temporairement
      final directory = await getTemporaryDirectory();
      final imagePath = await File('${directory.path}/budget.png').create();
      await imagePath.writeAsBytes(image);

      // Partager l'image
      Share.shareXFiles([XFile(imagePath.path)],
          text: 'Voici mon budget actuel !');
    }
  }
}