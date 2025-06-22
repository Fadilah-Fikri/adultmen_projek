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
    // Memberi sedikit jeda agar frame pertama selesai dirender
    await Future.delayed(Duration.zero);
    if (!mounted) return;

    final session = Supabase.instance.client.auth.currentSession;

    // Jika ada sesi login yang aktif
    if (session != null) {
      try {
        // Ambil data profil pengguna dari database untuk mengecek role
        final profile = await Supabase.instance.client
            .from('profiles')
            .select('role')
            .eq('id', session.user.id)
            .single();
        
        final role = profile['role'];

        // --- LOGIKA PERCABANGAN BERDASARKAN ROLE ---
        if (role == 'admin') {
          // Jika rolenya admin, arahkan ke dashboard admin
          Navigator.pushReplacementNamed(context, '/admin_dashboard');
        } else {
          // Jika user biasa, arahkan ke halaman utama (home)
          Navigator.pushReplacementNamed(context, '/home');
        }
      } catch (e) {
        // Jika terjadi error saat mengambil profil (misal: RLS salah),
        // arahkan kembali ke halaman login untuk keamanan.
        Navigator.pushReplacementNamed(context, '/login');
      }
    } else {
      // Jika tidak ada sesi login sama sekali, arahkan ke halaman login
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tampilkan layar loading sementara proses redirect berjalan
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}