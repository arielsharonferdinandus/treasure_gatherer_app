import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/item_provider.dart';
import '../../providers/auth_provider.dart';
import '../../data/models/item_model.dart';
import '../../core/utils/image_picker_helper.dart';
import '../../core/shared_widgets/item_image.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final Color primaryColor = const Color(0xFF5DB075);

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _defectController = TextEditingController();
  final _priceController = TextEditingController();

  String? _pickedPhoto;
  bool _showPhotoError = false;

  String _usageDuration = "cukup lama";
  bool _isManualDisassemble = false;

  bool _isDetectedResell = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_checkResellDetection);
  }

  void _checkResellDetection() {
    final authProvider = context.read<AuthProvider>();
    final detected = authProvider.hasPurchasedByName(_nameController.text);
    if (detected != _isDetectedResell) {
      setState(() => _isDetectedResell = detected);
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_checkResellDetection);
    _nameController.dispose();
    _descriptionController.dispose();
    _defectController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final result = await ImagePickerHelper.showPickerSheet(context);
    if (result != null) {
      setState(() {
        _pickedPhoto = result;
        _showPhotoError = false;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Photo is mandatory
    if (_pickedPhoto == null) {
      setState(() => _showPhotoError = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Foto barang wajib diambil sebelum mendaftarkan barang.")),
      );
      return;
    }

    int initialStars = 5;
    if (_isDetectedResell) {
      final temp = Item(id: '', name: '', description: '', stars: 5);
      temp.processReSell(_usageDuration);
      initialStars = temp.stars;
    }

    final itemName = _nameController.text.trim();

    final newItem = Item(
      id: '',
      name: itemName,
      description: _descriptionController.text.trim(),
      defectDescription: _defectController.text.trim().isEmpty
          ? "Belum ada catatan kondisi barang."
          : _defectController.text.trim(),
      thumbnailUrl: _pickedPhoto!,
      price: double.tryParse(_priceController.text.trim()) ?? 0,
      stars: initialStars,
      isManualDisassemble: _isManualDisassemble,
    );

    final itemProvider = context.read<ItemProvider>();
    final authProvider = context.read<AuthProvider>();

    final success = await itemProvider.addItem(newItem);

    if (!mounted) return;

    if (success) {
      if (_isDetectedResell) {
        await authProvider.consumePurchaseByName(itemName);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Barang berhasil didaftarkan!")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(itemProvider.errorMessage ?? "Gagal mendaftarkan barang.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ItemProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Jual Barang", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Nama Barang", border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? "Nama barang tidak boleh kosong" : null,
              ),
              const SizedBox(height: 12),

              if (_isDetectedResell) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          "Sistem mendeteksi barang ini pernah Anda beli sebelumnya. Rating awal akan dikurangi sesuai lama pemakaian.",
                          style: TextStyle(fontSize: 12, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text("Berapa lama barang digunakan sebelum dijual kembali?", style: TextStyle(fontSize: 13, color: Colors.grey)),
                RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  title: const Text("Sangat cepat (-2 bintang)"),
                  value: "sangat cepat",
                  groupValue: _usageDuration,
                  activeColor: primaryColor,
                  onChanged: (val) => setState(() => _usageDuration = val!),
                ),
                RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  title: const Text("Cukup lama (-1 bintang)"),
                  value: "cukup lama",
                  groupValue: _usageDuration,
                  activeColor: primaryColor,
                  onChanged: (val) => setState(() => _usageDuration = val!),
                ),
                RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  title: const Text("Sangat lama (-2 bintang)"),
                  value: "sangat lama",
                  groupValue: _usageDuration,
                  activeColor: primaryColor,
                  onChanged: (val) => setState(() => _usageDuration = val!),
                ),
                const Divider(height: 32),
              ] else ...[
                const SizedBox(height: 8),
              ],

              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: "Deskripsi / Kelebihan Barang", border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? "Deskripsi tidak boleh kosong" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _defectController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: "Deskripsi Defektif (opsional)",
                  hintText: "Kosongkan jika tidak ada kekurangan",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: false),
                decoration: const InputDecoration(labelText: "Harga (Rp)", border: OutlineInputBorder()),
                validator: (val) {
                  if (val == null || val.isEmpty) return "Harga tidak boleh kosong";
                  if (double.tryParse(val.trim()) == null) return "Harga harus berupa angka";
                  if (double.parse(val.trim()) <= 0) return "Harga harus lebih dari 0";
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Mandatory photo field — captured via camera or gallery.
              const Text("Foto Barang", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickPhoto,
                child: Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _showPhotoError ? Colors.red : Colors.grey.shade400,
                      width: _showPhotoError ? 1.5 : 1,
                    ),
                  ),
                  child: _pickedPhoto == null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add_a_photo, size: 36, color: Colors.grey.shade600),
                              const SizedBox(height: 8),
                              Text("Ketuk untuk ambil foto", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                            ],
                          ),
                        )
                      : Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(7),
                              child: ItemImage(
                                source: _pickedPhoto!,
                                height: 160,
                                width: double.infinity,
                              ),
                            ),
                            Positioned(
                              right: 8,
                              top: 8,
                              child: CircleAvatar(
                                backgroundColor: Colors.black54,
                                radius: 16,
                                child: IconButton(
                                  icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                                  onPressed: _pickPhoto,
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              if (_showPhotoError)
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text("Foto barang wajib diisi", style: TextStyle(color: Colors.red, fontSize: 12)),
                ),

              const Divider(height: 40),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Set Manual ke 'For Disassemble'"),
                subtitle: const Text("Khusus untuk engineer pembongkar komponen aktif"),
                value: _isManualDisassemble,
                activeColor: Colors.orange,
                onChanged: (val) => setState(() => _isManualDisassemble = val),
              ),

              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: isLoading ? null : _submit,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text("Daftarkan Barang", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}