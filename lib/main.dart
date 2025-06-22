import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screen/home_screen.dart';
import 'screen/login_screen.dart';
import 'screen/register.dart';
import 'screen/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:adultmen_uas/screen/admin/admin_dashboard_screen.dart';
import 'package:adultmen_uas/screen/admin/manage_products_screen.dart';

Future<void> main() async {
  // Pastikan Flutter binding sudah siap
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Supabase di sini
  await Supabase.initialize(
    // Ganti dengan URL dan Anon Key dari proyek Supabase Anda
    url: 'https://ioszwcuulofzarztpdqe.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imlvc3p3Y3V1bG9memFyenRwZHFlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA1OTc2NDksImV4cCI6MjA2NjE3MzY0OX0.hfADScj2WDH9gU79e7TriH5eV3cRmuglajpZvrHMqJ4',
  );

  runApp(SemerbakHarumApp());
}

class SemerbakHarumApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Semerbak Harum',
      debugShowCheckedModeBanner: false,
      theme: _buildThemeData(),
      initialRoute: '/', // Mulai dari splash screen untuk cek auth
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(),
        '/admin_dashboard': (context) => AdminDashboardScreen(),
        '/manage_products': (context) => ManageProductsScreen(),
      },
    );
  }

  // ... (Sisa kode _buildThemeData() tidak perlu diubah, biarkan seperti semula)
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
        titleTextStyle: GoogleFonts.lora(
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