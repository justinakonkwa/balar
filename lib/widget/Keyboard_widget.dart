import 'package:balare/widget/app_text.dart';
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
              _buildKey('', context,
                  onTap: onBackspace,
                  isBackspace: true), // Touche retour arrière avec icône
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeyboardRow(List<String> keys, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((key) => _buildKey(key, context)).toList(),
    );
  }

  Widget _buildKey(String value, BuildContext context,
      {VoidCallback? onTap, bool isBackspace = false}) {
    return GestureDetector(
      onTap: onTap ?? () => _textInputHandler(value),
      child: Container(
        margin: const EdgeInsets.all(8.0),
        width: 60,
        height: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          border: Border.all(color: Theme.of(context).highlightColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: isBackspace
            ? Icon(Icons.backspace,
                size: 24,
                color: Theme.of(context)
                    .colorScheme
                    .error) // Icône pour retour arrière
            : AppText(
                text: value,
              ),
      ),
    );
  }
}
