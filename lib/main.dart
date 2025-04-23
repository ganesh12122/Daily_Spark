import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/providers/dairy_provider.dart';
import 'core/providers/discipline_provider.dart';
import 'ui/screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DisciplineProvider()..loadFromPrefs()),
        ChangeNotifierProvider(create: (_) => DiaryProvider()..loadFromPrefs()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DisciplineProvider>(
      builder: (context, disciplineProvider, child) {
        return MaterialApp(
          title: 'SparkVow',
          theme: ThemeData(
            primarySwatch: Colors.deepPurple,
            brightness: Brightness.light,
            textTheme: GoogleFonts.poppinsTextTheme(),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              centerTitle: true,
              elevation: 0,
              titleTextStyle: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            cardTheme: CardTheme(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          darkTheme: ThemeData(
            primarySwatch: Colors.deepPurple,
            brightness: Brightness.dark,
            textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              centerTitle: true,
              elevation: 0,
              titleTextStyle: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            cardTheme: CardTheme(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          themeMode: disciplineProvider.darkMode ? ThemeMode.dark : ThemeMode.light,
          home: const OnboardingWrapper(),
        );
      },
    );
  }
}