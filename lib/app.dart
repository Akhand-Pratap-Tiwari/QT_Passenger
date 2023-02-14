import 'package:flutter/material.dart';

import 'auth_gate.dart';

class CommonThemeProperties {
  const CommonThemeProperties();
  final inputDecorationTheme = const InputDecorationTheme(
    isDense: true,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(8.0),
      ),
    ),
  );
  final primarySwatch = Colors.amber;
  final floatingActionButtonTheme = const FloatingActionButtonThemeData(
      backgroundColor: Color.fromRGBO(230, 74, 25, 1),
      foregroundColor: Colors.white,
      extendedTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w500));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  final commonThemeProperties = const CommonThemeProperties();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quick TAXI',
      debugShowCheckedModeBanner: true,
      theme: ThemeData(
        splashColor: Colors.pinkAccent.shade100.withOpacity(0.5),
          useMaterial3: true,
          inputDecorationTheme: commonThemeProperties.inputDecorationTheme,
          primarySwatch: commonThemeProperties.primarySwatch,
          floatingActionButtonTheme:
              commonThemeProperties.floatingActionButtonTheme
          /* light theme settings */
          ),
      darkTheme: ThemeData(
        splashColor: Colors.redAccent.withOpacity(0.5),
        useMaterial3: true,
        inputDecorationTheme: commonThemeProperties.inputDecorationTheme,
        primarySwatch: commonThemeProperties.primarySwatch,
        brightness: Brightness.dark,
        floatingActionButtonTheme:
            commonThemeProperties.floatingActionButtonTheme,
        /* dark theme settings */
      ),
      themeMode: ThemeMode.system,
      home: const AuthGate(),
    );
  }
}
