import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screen/login_screen.dart';
import 'screen/register.dart';
import 'screen/home_screen.dart';

void main() {
  runApp(SemerbakHarumApp());
}

class SemerbakHarumApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Semerbak Harum', // JUDUL BARU
      debugShowCheckedModeBanner: false,
      theme: _buildThemeData(),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }

  ThemeData _buildThemeData() {
    final baseTheme = ThemeData.light();
    return baseTheme.copyWith(
      primaryColor: Color(0xFF8D7B68),
      scaffoldBackgroundColor: Color(0xFFFDF8F0),
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: Color(0xFF8D7B68),
        secondary: Color(0xFFA4907C),
        surface: Colors.white,
        onPrimary: Colors.white,
      ),
      textTheme: GoogleFonts.montserratTextTheme(baseTheme.textTheme).copyWith(
        headlineSmall: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3C3633)),
        bodyLarge: TextStyle(color: Color(0xFF605752)),
        bodyMedium: TextStyle(color: Color(0xFF605752)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF3C3633)),
        titleTextStyle: GoogleFonts.lora( // Font kustom untuk judul app bar
          color: Color(0xFF3C3633),
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF8D7B68),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: TextStyle(color: Colors.grey[400]),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}