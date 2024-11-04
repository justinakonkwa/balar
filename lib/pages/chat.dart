import 'package:balare/widget/app_text.dart';
import 'package:balare/widget/constantes.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Future<void> openWhatsApp(String phoneNumber, String message) async {
    final String encodedMessage = Uri.encodeComponent(message);
    final Uri whatsappUrl =
    Uri.parse('whatsapp://send?phone=$phoneNumber&text=$encodedMessage');

    bool canOpen = await canLaunchUrl(whatsappUrl);
    if (canOpen) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      print("Erreur : WhatsApp n'est pas détecté comme installé.");
      throw 'Impossible d\'ouvrir WhatsApp';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: AppText(text: 'Chat'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppText(
                text:
                "De questions sur l'argent? Nous avons des reponses !",
                textAlign: TextAlign.center,
              ),
              sizedbox,
              sizedbox,
              GestureDetector(
                onTap: () {
                  openWhatsApp(
                    '+243975024769',
                    'Bonjour, je vous contacte depuis mon application Balar !',
                  );
                },
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .inverseSurface
                            .withOpacity(0.4),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.phone,
                        size: 60,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
