import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddEditProductScreen extends StatefulWidget {
  final String? productId;

  const AddEditProductScreen({Key? key, this.productId}) : super(key: key);

  bool get isEditMode => productId != null;

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  String? _existingImageUrl;

  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _longDescController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  bool _isFeatured = false;
  
  @override
  void initState() {
    super.initState();
    if (widget.isEditMode) {
      _fetchProductDetails();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _longDescController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _fetchProductDetails() async {
    setState(() { _isLoading = true; });
    try {
      final data = await Supabase.instance.client
          .from('fragrances')
          .select()
          .eq('id', widget.productId!)
          .single();
      
      _nameController.text = data['name'] ?? '';
      _descController.text = data['description'] ?? '';
      _longDescController.text = data['long_description'] ?? '';
      _priceController.text = (data['price'] ?? 0).toString();
      _stockController.text = (data['stock'] ?? 0).toString();
      _isFeatured = data['is_featured'] ?? false;
      _existingImageUrl = data['image_url'];

    } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to fetch details: $e')));
    } finally {
      if(mounted) setState(() { _isLoading = false; });
    }
  }

  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result != null && result.files.first.bytes != null) {
        setState(() {
          _selectedImageBytes = result.files.first.bytes;
          _selectedImageName = result.files.first.name;
          _existingImageUrl = null;
        });
      }
    } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImageBytes == null || _selectedImageName == null) {
      return null;
    }
    
    try {
      final imagePath = 'public/${DateTime.now().toIso8601String()}_$_selectedImageName';
      await Supabase.instance.client.storage
          .from('produk')
          .uploadBinary(
            imagePath,
            _selectedImageBytes!,
            fileOptions: FileOptions(contentType: 'image/${_selectedImageName!.split('.').last}'),
          );
      
      return Supabase.instance.client.storage
          .from('produk')
          .getPublicUrl(imagePath);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error uploading image: $e')));
      return null;
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() { _isLoading = true; });

    String? imageUrl = _existingImageUrl;

    if (_selectedImageBytes != null) {
      imageUrl = await _uploadImage();
      if (imageUrl == null) {
        setState(() { _isLoading = false; });
        return;
      }
    }

    if (imageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gambar produk wajib diisi.')));
        setState(() { _isLoading = false; });
        return;
    }

    final productData = {
      'name': _nameController.text,
      'description': _descController.text,
      'long_description': _longDescController.text,
      'image_url': imageUrl,
      'price': double.tryParse(_priceController.text) ?? 0,
      'stock': int.tryParse(_stockController.text) ?? 0,
      'is_featured': _isFeatured,
    };

    try {
      if (widget.isEditMode) {
        await Supabase.instance.client.from('fragrances').update(productData).eq('id', widget.productId!);
      } else {
        await Supabase.instance.client.from('fragrances').insert(productData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Produk berhasil disimpan!'), backgroundColor: Colors.green));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan produk: $e'), backgroundColor: Theme.of(context).colorScheme.error));
      }
    } finally {
       if(mounted) setState(() { _isLoading = false; });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditMode ? 'Edit Produk' : 'Tambah Produk Baru'),
        elevation: 1,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // --- KARTU UNTUK GAMBAR PRODUK ---
            Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: InkWell(
                onTap: _pickImage,
                child: Container(
                  height: 220,
                  width: double.infinity,
                  child: (_selectedImageBytes != null)
                      ? Image.memory(_selectedImageBytes!, fit: BoxFit.cover)
                      : (_existingImageUrl != null)
                        ? Image.network(_existingImageUrl!, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder())
                        : _buildImagePlaceholder(),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- KARTU UNTUK DETAIL PRODUK ---
            _buildSectionCard(
              title: 'Detail Produk',
              children: [
                TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nama Produk'), validator: (val) => val!.isEmpty ? 'Wajib diisi' : null),
                const SizedBox(height: 16),
                TextFormField(controller: _descController, decoration: const InputDecoration(labelText: 'Deskripsi Singkat'), validator: (val) => val!.isEmpty ? 'Wajib diisi' : null),
                const SizedBox(height: 16),
                TextFormField(controller: _longDescController, decoration: const InputDecoration(labelText: 'Deskripsi Panjang'), maxLines: 3),
              ]
            ),
            const SizedBox(height: 24),

            // --- KARTU UNTUK INVENTARIS & OPSI ---
            _buildSectionCard(
              title: 'Inventaris & Opsi',
              children: [
                TextFormField(controller: _priceController, decoration: const InputDecoration(labelText: 'Harga', prefixText: 'Rp '), keyboardType: TextInputType.number, validator: (val) => val!.isEmpty ? 'Wajib diisi' : null),
                const SizedBox(height: 16),
                TextFormField(controller: _stockController, decoration: const InputDecoration(labelText: 'Stok'), keyboardType: TextInputType.number, validator: (val) => val!.isEmpty ? 'Wajib diisi' : null),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('Produk Unggulan (Featured)'),
                  value: _isFeatured,
                  onChanged: (val) => setState(() => _isFeatured = val),
                  contentPadding: EdgeInsets.zero,
                ),
              ]
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveProduct,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
              ),
              child: Text(widget.isEditMode ? 'SIMPAN PERUBAHAN' : 'TAMBAHKAN PRODUK'),
            ),
          ],
        ),
      ),
    );
  }

  // Widget helper untuk placeholder gambar
  Widget _buildImagePlaceholder() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_a_photo_outlined, size: 50, color: Colors.grey),
        SizedBox(height: 8),
        Text('Pilih Gambar Produk'),
      ],
    );
  }

  // Widget helper untuk membuat kartu section
  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}