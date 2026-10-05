import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const JamaKharchApp());
}

class JamaKharchApp extends StatelessWidget {
  const JamaKharchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'जमा खर्च',

      theme: ThemeData(
        useMaterial3: true,

        scaffoldBackgroundColor:
            const Color(0xffF7F9FC),

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff2563EB),
        ),

        textTheme:
            GoogleFonts.poppinsTextTheme(),

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          centerTitle: false,
        ),
      ),

      home: const HomeScreen(),
    );
  }
}