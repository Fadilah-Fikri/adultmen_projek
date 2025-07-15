import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:adultmen_uas/providers/cart_provider.dart';
import 'package:intl/date_symbol_data_local.dart'; // <-- 1. TAMBAHKAN IMPORT INI

// Import screen Anda
import 'screen/home_screen.dart';
import 'screen/login_screen.dart';
import 'screen/register.dart';
import 'screen/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:adultmen_uas/screen/admin/admin_dashboard_screen.dart';
import 'package:adultmen_uas/screen/admin/manage_products_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ioszwcuulofzarztpdqe.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imlvc3p3Y3V1bG9memFyenRwZHFlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA1OTc2NDksImV4cCI6MjA2NjE3MzY0OX0.hfADScj2WDH9gU79e7TriH5eV3cRmuglajpZvrHMqJ4',
  );

  // <-- 2. TAMBAHKAN BARIS INI UNTUK INISIALISASI FORMAT TANGGAL -->
  await initializeDateFormatting('id_ID', null);

  // Bungkus dengan MultiProvider agar mudah menambah provider lain di masa depan
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()),
      ],
      child: ScentifyApp(),
    ),
  );
}

class ScentifyApp extends StatelessWidget {
  const ScentifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scentify',
      debugShowCheckedModeBanner: false,
      theme: _buildThemeData(),
      initialRoute: '/', 
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) =>  LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/admin_dashboard': (context) => const AdminDashboardScreen(),
        '/manage_products': (context) => const ManageProductsScreen(),
      },
    );
  }

  ThemeData _buildThemeData() {
    final baseTheme = ThemeData.light();
    return baseTheme.copyWith(
      primaryColor: const Color(0xFF8D7B68),
      scaffoldBackgroundColor: const Color(0xFFFDF8F0),
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: const Color(0xFF8D7B68),
        secondary: const Color(0xFFA4907C),
        surface: Colors.white,
        onPrimary: Colors.white,
      ),
      textTheme: GoogleFonts.montserratTextTheme(baseTheme.textTheme).copyWith(
        headlineSmall: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3C3633)),
        bodyLarge: const TextStyle(color: Color(0xFF605752)),
        bodyMedium: const TextStyle(color: Color(0xFF605752)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF3C3633)),
        titleTextStyle: GoogleFonts.lora(
          color: const Color(0xFF3C3633),
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8D7B68),
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