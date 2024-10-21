// Widget de clavier personnalisé
import 'package:flutter/material.dart';

class CustomKeyboard extends StatelessWidget {
  final ValueSetter<String> onTextInput;
  final VoidCallback onBackspace;

  CustomKeyboard({
    required this.onTextInput,
    required this.onBackspace,
  });

  void _textInputHandler(String text) => onTextInput.call(text);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 310.0, // Ajuste la hauteur du clavier
      child: Column(
        children: [
          // Première rangée de touches
          _buildKeyboardRow(['1', '2', '3'], context),
          // Deuxième rangée de touches
          _buildKeyboardRow(['4', '5', '6'], context),
          // Troisième rangée de touches
          _buildKeyboardRow(['7', '8', '9'], context),
          // Dernière rangée avec espace et retour arrière
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKey('0', context),
              _buildKey('X', context,
                  onTap: onBackspace), // Touche retour arrière
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeyboardRow(List<String> keys, BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: keys.map((key) => _buildKey(key, context)).toList());
  }

  Widget _buildKey(String value, BuildContext context, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ?? () => _textInputHandler(value),
      child: Container(
        margin: const EdgeInsets.all(8.0),
        width: 60,
        height: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).highlightColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          value,
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
