import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    // Tunggu frame pertama selesai render untuk menghindari error navigasi
    await Future.delayed(Duration.zero);
    if (!mounted) return;

    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      // Jika user sudah login, cek rolenya
      try {
        final profile = await Supabase.instance.client
            .from('profiles')
            .select('role')
            .eq('id', session.user.id)
            .single();
        final role = profile['role'];
        if (role == 'admin') {
          Navigator.pushReplacementNamed(context, '/admin'); // Arahkan ke dashboard admin
        } else {
          Navigator.pushReplacementNamed(context, '/home'); // Arahkan ke home
        }
      } catch (e) {
        // Jika gagal fetch profile (misal: RLS salah), arahkan ke login
        Navigator.pushReplacementNamed(context, '/login');
      }
    } else {
      // Jika tidak ada session, arahkan ke login
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}