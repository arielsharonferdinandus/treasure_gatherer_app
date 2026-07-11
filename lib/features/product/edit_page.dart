import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/item_provider.dart';
import '../../data/models/item_model.dart';
import '../../core/utils/image_picker_helper.dart';
import '../../core/shared_widgets/item_image.dart';

class EditPage extends StatefulWidget {
  final Item item;
  const EditPage({super.key, required this.item});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final _formKey = GlobalKey<FormState>();
  final Color primaryColor = const Color(0xFF5DB075);

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _defectController;
  late final TextEditingController _priceController;

  late bool _isManualDisassemble;

  late String? _pickedPhoto;
  bool _showPhotoError = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _descriptionController = TextEditingController(text: widget.item.description);
    _defectController = TextEditingController(text: widget.item.defectDescription);
    _priceController = TextEditingController(text: widget.item.price.toInt().toString());
    _isManualDisassemble = widget.item.isManualDisassemble;
    _pickedPhoto = widget.item.thumbnailUrl.isEmpty ? null : widget.item.thumbnailUrl;
  }

  @override
  void dispose() {
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

    if (_pickedPhoto == null) {
      setState(() => _showPhotoError = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Foto barang wajib diisi.")),
      );
      return;
    }

    final updatedItem = Item(
      id: widget.item.id,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      defectDescription: _defectController.text.trim().isEmpty
          ? "Belum ada catatan kondisi barang."
          : _defectController.text.trim(),
      thumbnailUrl: _pickedPhoto!,
      price: double.tryParse(_priceController.text.trim()) ?? widget.item.price,
      stars: widget.item.stars,
      isManualDisassemble: _isManualDisassemble,
    );

    final itemProvider = context.read<ItemProvider>();
    final success = await itemProvider.updateItemDetails(updatedItem);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Perubahan berhasil disimpan!")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(itemProvider.errorMessage ?? "Gagal menyimpan perubahan.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ItemProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Barang", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
              // Read-only star display
              Row(
                children: [
                  const Text("Rating Sistem: ", style: TextStyle(fontWeight: FontWeight.bold)),
                  ...List.generate(5, (i) => Icon(
                    i < widget.item.stars ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 20,
                  )),
                ],
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Nama Barang", border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? "Nama barang tidak boleh kosong" : null,
              ),
              const SizedBox(height: 16),

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
                decoration: const InputDecoration(labelText: "Deskripsi Defektif", border: OutlineInputBorder()),
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
                    : const Text("Simpan Perubahan", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}