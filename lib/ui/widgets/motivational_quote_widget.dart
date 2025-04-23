import 'package:flutter/material.dart';

class MotivationalQuoteWidget extends StatelessWidget {
  const MotivationalQuoteWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quotes = [
      "Discipline is choosing between what you want now and what you want most.",
      "You will never always be motivated. You must learn to be disciplined.",
      "The only discipline that lasts is self-discipline.",
      "Discipline is the bridge between goals and accomplishment.",
      "Small disciplines repeated with consistency every day lead to great achievements.",
      "You don't have to be extreme, just consistent.",
      "The pain of discipline is nothing like the pain of disappointment.",
      "Success is nothing more than a few simple disciplines, practiced every day.",
      "Discipline is the soul of an army. It makes small numbers formidable.",
      "With discipline, you can achieve anything. Without it, nothing.",
    ];
    final randomQuote = quotes[DateTime.now().day % quotes.length];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'TODAY\'S BATTLE CRY',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              randomQuote,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}