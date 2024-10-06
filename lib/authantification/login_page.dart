import 'package:balare/widget/Keyboard_widget.dart';
import 'package:balare/widget/app_text.dart';
import 'package:balare/widget/app_text_large.dart';
import 'package:balare/widget/bouton_next.dart';
import 'package:balare/widget/constantes.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool isLoading = false;
  String _countryCode = '';
  bool isPhoneNumberEntered = false; // Variable pour gérer la progression
  bool _isPasswordVisible =
      false; // Variable pour gérer la visibilité du mot de passe

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: isPhoneNumberEntered
              ? _buildPasswordInput(
                  context) // Si le numéro est saisi, afficher la saisie du mot de passe
              : _buildPhoneNumberInput(
                  context), // Sinon, afficher la saisie du numéro de téléphone
        ),
      ),
    );
  }

  // Interface de saisie du numéro de téléphone
  Widget _buildPhoneNumberInput(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppTextLarge(
          size: 25,
          text: '''Bienvenue chez Balar ! Pour
commencer, entrez votre
Numéro de téléphone''',
          textAlign: TextAlign.center,
        ),
        sizedbox,
        SizedBox(
          child: Row(
            children: [
              Container(
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CountryCodePicker(
                  backgroundColor: Colors.grey,
                  onChanged: (countryCode) {
                    setState(() {
                      _countryCode = countryCode.dialCode!;
                    });
                  },
                  showFlag: true,
                  showCountryOnly: true,
                  initialSelection: 'CD',
                  favorite: ['+243', 'CD'],
                ),
              ),
              sizedbox2,
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: CupertinoTextField(
                    controller: _phoneNumberController,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                    keyboardType: TextInputType.none,
                    placeholder: 'Phone Number',
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        sizedbox,
        CustomKeyboard(
          onTextInput: (value) {
            _phoneNumberController.text += value;
          },
          onBackspace: () {
            if (_phoneNumberController.text.isNotEmpty) {
              _phoneNumberController.text = _phoneNumberController.text
                  .substring(0, _phoneNumberController.text.length - 1);
            }
          },
        ),
        sizedbox,
        NextButton(
          width: double.maxFinite,
          onTap: () {
            setState(() {
              isPhoneNumberEntered = true; // Passer à la saisie du mot de passe
            });
          },
          child: isLoading
              ? CupertinoActivityIndicator(color: Colors.white)
              : AppText(text: "Continuer", color: Colors.white),
        ),
      ],
    );
  }

  // Interface de saisie du mot de passe avec bouton retour
  Widget _buildPasswordInput(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Bouton de retour
        Align(
          alignment: Alignment.topLeft,
          child: IconButton(
            icon: Icon(CupertinoIcons.arrow_left_circle),
            onPressed: () {
              setState(() {
                isPhoneNumberEntered = false; // Revenir à la saisie du numéro
              });
            },
          ),
        ),
        sizedbox,
        sizedbox,
        sizedbox,
        AppTextLarge(
          text: 'Entrez votre code secret',
          size: 30,
        ),
        sizedbox,
        Pinput(
          obscureText:
              !_isPasswordVisible, // Gestion de la visibilité du mot de passe
          obscuringCharacter: '*', // Afficher les astérisques au lieu de points
          keyboardType: TextInputType.none,
          length: 4,
          controller: _otpController,
          onCompleted: (String pin) async {},
        ),
        IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible; // Changer la visibilité
            });
          },
        ),
        sizedbox,
        CustomKeyboard(
          onTextInput: (value) {
            _otpController.text += value;
          },
          onBackspace: () {
            if (_otpController.text.isNotEmpty) {
              _otpController.text = _otpController.text
                  .substring(0, _otpController.text.length - 1);
            }
          },
        ),
        sizedbox,
        NextButton(
          width: double.maxFinite,
          onTap: () {},
          child: isLoading
              ? CupertinoActivityIndicator(color: Colors.white)
              : AppText(text: "Continuer", color: Colors.white),
        ),
      ],
    );
  }
}
