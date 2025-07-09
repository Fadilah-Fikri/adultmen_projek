import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddEditAddressPage extends StatefulWidget {
  final Map<String, dynamic>? address; // Nullable, jika null berarti 'Tambah', jika tidak null 'Edit'

  const AddEditAddressPage({Key? key, this.address}) : super(key: key);

  @override
  State<AddEditAddressPage> createState() => _AddEditAddressPageState();
}

class _AddEditAddressPageState extends State<AddEditAddressPage> {
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;
  bool _isLoading = false;

  late final TextEditingController _labelController;
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _postalCodeController;
  bool _isPrimary = false;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.address?['label']);
    _nameController = TextEditingController(text: widget.address?['recipient_name']);
    _phoneController = TextEditingController(text: widget.address?['phone_number']);
    _addressController = TextEditingController(text: widget.address?['full_address']);
    _cityController = TextEditingController(text: widget.address?['city']);
    _postalCodeController = TextEditingController(text: widget.address?['postal_code']);
    _isPrimary = widget.address?['is_primary'] ?? false;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = _supabase.auth.currentUser!.id;
      final data = {
        'user_id': userId,
        'label': _labelController.text,
        'recipient_name': _nameController.text,
        'phone_number': _phoneController.text,
        'full_address': _addressController.text,
        'city': _cityController.text,
        'postal_code': _postalCodeController.text,
        'is_primary': _isPrimary,
      };

      if (widget.address == null) {
        // Mode Tambah
        await _supabase.from('addresses').insert(data);
      } else {
        // Mode Edit
        await _supabase.from('addresses').update(data).eq('id', widget.address!['id']);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alamat berhasil disimpan'), backgroundColor: Colors.green),
      );
      Navigator.of(context).pop(true); // Kirim sinyal 'true' untuk refresh
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan alamat: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.address == null ? 'Tambah Alamat Baru' : 'Edit Alamat'),
        backgroundColor: Colors.black,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildTextFormField(_labelController, 'Label Alamat (Contoh: Rumah, Kantor)'),
            _buildTextFormField(_nameController, 'Nama Penerima'),
            _buildTextFormField(_phoneController, 'Nomor Telepon', keyboardType: TextInputType.phone),
            _buildTextFormField(_addressController, 'Alamat Lengkap'),
            _buildTextFormField(_cityController, 'Kota / Kabupaten'),
            _buildTextFormField(_postalCodeController, 'Kode Pos', keyboardType: TextInputType.number),
            SwitchListTile(
              title: const Text('Jadikan Alamat Utama'),
              value: _isPrimary,
              onChanged: (value) => setState(() => _isPrimary = value),
              activeColor: const Color(0xFFD4AF37),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveAddress,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.black)
                  : const Text('SIMPAN ALAMAT', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField(TextEditingController controller, String label, {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label tidak boleh kosong';
          }
          return null;
        },
      ),
    );
  }
}