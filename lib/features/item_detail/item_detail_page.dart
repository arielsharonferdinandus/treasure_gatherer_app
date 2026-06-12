import 'package:flutter/material.dart';
import '../home/item_model.dart';

class ItemDetailPage extends StatefulWidget {
  final Item item;
  const ItemDetailPage({super.key, required this.item});

  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  // Fungsi simulasi aksi jual kembali oleh user untuk memicu perubahan bintang otomatis oleh sistem
  void _simulateReSell(String duration) {
    setState(() {
      widget.item.processReSell(duration);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Barang dijual kembali! Sisa bintang sistem: ${widget.item.stars}")),
    );

    if (widget.item.isForDisassemble) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Otomatisasi Sistem: Barang diturunkan ke kategori 'For Disassemble' karena bintang <= 1!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Scaffold(
      appBar: AppBar(title: Text(item.name), backgroundColor: Colors.teal),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(item.isForDisassemble ? "Kategori: For Disassemble" : "Kategori: Laman Utama"),
                  backgroundColor: item.isForDisassemble ? Colors.orange.shade300 : Colors.teal.shade200,
                ),
                Row(
                  children: List.generate(5, (index) => Icon(
                    index < item.stars ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  )),
                )
              ],
            ),
            const SizedBox(height: 20),
            const Text("Deskripsi / Kelebihan Barang:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(item.description, style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 20),
            const Text("Deskripsi Defektif (Kekurangan):", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red)),
            Text(item.defectDescription, style: const TextStyle(fontSize: 15, color: Colors.red)), // Atur text style
            
            const Divider(height: 40),

            // Kontrol Pengguna Manual (Hanya untuk Kategori Disassemble manual)
            SwitchListTile(
              title: const Text("Set Manual ke 'For Disassemble'"),
              subtitle: const Text("Khusus engineer pembongkar komponen aktif"),
              value: item.isManualDisassemble,
              activeColor: Colors.orange,
              onChanged: (bool value) {
                setState(() {
                  item.isManualDisassemble = value;
                });
              },
            ),

            const Divider(height: 40),
            
            // Simulator Sistem Jual Kembali (Star Categorize Testing)
            const Text("Simulator Sistem Jual Kembali (Star Categorize)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
            const SizedBox(height: 8),
            const Text("Uji pengurangan bintang sistem otomatis berdasarkan durasi penggunaan lama beli:", style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: () => _simulateReSell("sangat cepat"), child: const Text("Sangat Cepat (-2)")),
                ElevatedButton(onPressed: () => _simulateReSell("cukup lama"), child: const Text("Cukup Lama (-1)")),
                ElevatedButton(onPressed: () => _simulateReSell("sangat lama"), child: const Text("Sangat Lama (-2)")),
              ],
            )
          ],
        ),
      ),
    );
  }
}
