import 'package:flutter/material.dart';
import 'data/db/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database (creates tables + seeds Hearts/Spades cards)
  await DatabaseHelper.instance.init();

  runApp(const CardOrganizerApp());
}

class CardOrganizerApp extends StatelessWidget {
  const CardOrganizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Organizer',
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Organizer'),
      ),
      body: const Center(
        child: Text(
          'Database initialized ✅',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}