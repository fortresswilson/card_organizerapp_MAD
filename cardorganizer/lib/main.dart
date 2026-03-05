import 'package:flutter/material.dart';
import '/db/database_helper.dart';
import 'screens/folders_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      home: const FoldersScreen(),
    );
  }
}