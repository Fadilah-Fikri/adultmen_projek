import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'addresses_page.dart';
import 'favorites_page.dart';
import 'package:adultmen_uas/services/favorite_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isLoading = true;
  String? _userId;
  String? _email;
  String? _avatarUrl;
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        _userId = user.id;
        _email = user.email;

        final data = await Supabase.instance.client
            .from('profiles')
            .select('full_name, avatar_url')
            .eq('id', _userId!)
            .single();

        if (mounted) {
          _nameController.text = data['full_name'] ?? '';
          _avatarUrl = data['avatar_url'];
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal memuat data profil: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickAvatar() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedImageBytes = result.files.first.bytes;
          _selectedImageName = result.files.first.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal memilih gambar: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
      }
    }
  }

  Future<String?> _uploadAvatar() async {
    if (_selectedImageBytes == null || _selectedImageName == null) {
      return null;
    }

    try {
      final filePath =
          'avatars/$_userId/${DateTime.now().toIso8601String()}_$_selectedImageName';
      await Supabase.instance.client.storage.from('avatars').uploadBinary(
            filePath,
            _selectedImageBytes!,
            fileOptions: FileOptions(
                contentType: 'image/${_selectedImageName!.split('.').last}'),
          );

      return Supabase.instance.client.storage
          .from('avatars')
          .getPublicUrl(filePath);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal mengunggah gambar: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
      }
      return null;
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isLoading = true);

    try {
      String? newAvatarUrl = _avatarUrl;

      if (_selectedImageBytes != null) {
        newAvatarUrl = await _uploadAvatar();
        if (newAvatarUrl == null) {
          setState(() => _isLoading = false);
          return;
        }
      }

      final updates = {
        'id': _userId!,
        'full_name': _nameController.text.trim(),
        'updated_at': DateTime.now().toIso8601String(),
        'avatar_url': newAvatarUrl,
      };

      await Supabase.instance.client.from('profiles').upsert(updates);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Profil berhasil diperbarui!'),
          backgroundColor: Colors.green,
        ));
        setState(() {
          _avatarUrl = newAvatarUrl;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal memperbarui profil: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _selectedImageBytes = null;
        _selectedImageName = null;
      }
    }
  }


  Widget _buildAvatar() {
    ImageProvider<Object> backgroundImage;
    if (_selectedImageBytes != null) {
      backgroundImage = MemoryImage(_selectedImageBytes!);
    } else if (_avatarUrl != null && _avatarUrl!.isNotEmpty) {
      backgroundImage = NetworkImage(_avatarUrl!);
    } else {
      return const CircleAvatar(
        radius: 60,
        backgroundColor: Colors.white,
        child: Icon(Icons.person, size: 60, color: Colors.grey),
      );
    }
    return CircleAvatar(radius: 60, backgroundImage: backgroundImage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                _buildSliverAppBar(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildProfileFormCard(),
                        const SizedBox(height: 24),
                        _buildMarketplaceMenu(),
                        const SizedBox(height: 24),
                        _buildLogoutButton(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 250.0,
      pinned: true,
      floating: false,
      elevation: 4,
      backgroundColor: Colors.black,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          _nameController.text.isNotEmpty ? _nameController.text : "Pengguna",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
            shadows: [Shadow(blurRadius: 2.0, color: Colors.black87)],
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black.withOpacity(0.8), Colors.grey[800]!.withOpacity(0.9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Stack(
              children: [
                _buildAvatar(),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Material(
                    color: const Color(0xFFD4AF37), // Gold color
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    elevation: 4.0,
                    child: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.black),
                      onPressed: _pickAvatar,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileFormCard() {
    return Card(
      elevation: 5.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _email ?? 'Tidak ada email',
                readOnly: true,
                style: TextStyle(color: Colors.grey[600]),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFFD4AF37)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap',
                  labelStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  prefixIcon: const Icon(Icons.person_outline, color: Color(0xFFD4AF37)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Nama tidak boleh kosong';
                  return null;
                },
              ),
              const SizedBox(height: 10), // Reduced space
              ElevatedButton(
                onPressed: _isLoading ? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(15.0)),
                  ),
                  elevation: 0,
                ),
                child: Center(
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.black),
                        )
                      : const Text(
                          'SIMPAN PERUBAHAN',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMarketplaceMenu() {
    return Card(
      elevation: 5.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      clipBehavior: Clip.antiAlias, // Ensures content respects the border radius
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.shopping_bag_outlined,
            title: 'Pesanan Saya',
            onTap: () => _showComingSoon('Halaman Pesanan Saya'),
          ),
          const Divider(height: 1),
          _buildMenuItem(
            icon: Icons.favorite_border,
            title: 'Favorites',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoritesPage()),
              );
            },
          ),
          const Divider(height: 1),
          _buildMenuItem(
            icon: Icons.location_on_outlined,
            title: 'Alamat Pengiriman',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddressPage()),
              );
            },
          ),
          const Divider(height: 1),
          _buildMenuItem(
            icon: Icons.account_circle_outlined,
            title: 'Pengaturan Akun',
            onTap: () => _showComingSoon('Halaman Pengaturan Akun'),
          ),
          const Divider(height: 1),
          _buildMenuItem(
            icon: Icons.help_outline,
            title: 'Pusat Bantuan',
            onTap: () => _showComingSoon('Halaman Pusat Bantuan'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: Colors.black87),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
  
  void _showComingSoon(String pageName) {
     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$pageName segera hadir!'),
      backgroundColor: const Color(0xFFD4AF37),
    ));
  }

  Widget _buildLogoutButton() {
    return OutlinedButton.icon(
      icon: const Icon(Icons.logout, color: Colors.redAccent),
      label: const Text(
        'Logout',
        style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
      ),
      onPressed: () async {
        await Supabase.instance.client.auth.signOut();
        FavoriteService.clearFavorites(); 
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        }
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15),
        side: const BorderSide(color: Colors.redAccent, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }
}