import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/item_model.dart';
import '../../providers/item_provider.dart';
import '../../providers/auth_provider.dart';
import '../../data/services/notification_service.dart';
import '../../core/shared_widgets/item_image.dart';
import 'edit_page.dart';

class ProductPage extends StatelessWidget {
  final Item item;
  const ProductPage({super.key, required this.item});

  final Color primaryColor = const Color(0xFF5DB075);

  void _showMockSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _formatPrice(double price) {
    final str = price.toInt().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      final posFromEnd = str.length - i;
      buffer.write(str[i]);
      if (posFromEnd > 1 && posFromEnd % 3 == 1) buffer.write('.');
    }
    return "Rp$buffer";
  }

  Future<void> _startPurchaseFlow(BuildContext context, Item currentItem) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _PurchaseCountdownDialog(itemName: currentItem.name),
    );

    if (!context.mounted) return;

    final itemProvider = context.read<ItemProvider>();
    final authProvider = context.read<AuthProvider>();

    final deleted = await itemProvider.deleteItem(currentItem.id);
    if (deleted) {
      await authProvider.recordPurchase(currentItem.name);
    }

    if (!context.mounted) return;

    if (!deleted) {
      _showMockSnack(context, itemProvider.errorMessage ?? "Pembelian gagal, coba lagi.");
      return;
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: primaryColor, size: 64),
            const SizedBox(height: 16),
            const Text(
              "Pembelian Berhasil",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "${currentItem.name} telah berhasil dibeli.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("OK", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );

    await NotificationService().showPurchaseSuccessNotification(currentItem.name);

    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final currentItem = context.watch<ItemProvider>().getById(item.id) ?? item;
    final bool isDisassemble = currentItem.isForDisassemble;

    return Scaffold(
      appBar: AppBar(
        title: Text(currentItem.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            tooltip: "Edit Barang",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditPage(item: currentItem)),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroImage(currentItem, isDisassemble),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Chip(
                        label: Text(
                          isDisassemble ? "Kategori: For Disassemble" : "Kategori: Laman Utama",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: isDisassemble ? Colors.orange.shade600 : primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide.none,
                        ),
                      ),
                      Row(
                        children: List.generate(5, (index) => Icon(
                          index < currentItem.stars ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                        )),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(currentItem.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(
                    _formatPrice(currentItem.price),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor),
                  ),
                  const SizedBox(height: 20),
                  const Text("Deskripsi / Kelebihan Barang:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(currentItem.description, style: const TextStyle(fontSize: 15, color: Colors.black87)),
                  const SizedBox(height: 20),
                  const Text("Deskripsi Defektif (Kekurangan):", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red)),
                  const SizedBox(height: 4),
                  Text(currentItem.defectDescription, style: const TextStyle(fontSize: 15, color: Colors.red)),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBuyBar(context, currentItem),
    );
  }

  Widget _buildHeroImage(Item currentItem, bool isDisassemble) {
    return ItemImage(
      source: currentItem.thumbnailUrl,
      height: 240,
      width: double.infinity,
      placeholderIcon: isDisassemble ? Icons.developer_board : Icons.devices,
      placeholderColor: isDisassemble ? Colors.orange.shade800 : primaryColor,
      placeholderBackground: isDisassemble ? Colors.orange.shade100 : primaryColor.withOpacity(0.15),
    );
  }

  Widget _buildBuyBar(BuildContext context, Item currentItem) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showMockSnack(context, "${currentItem.name} ditambahkan ke keranjang"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  side: BorderSide(color: primaryColor),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text("Keranjang"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _startPurchaseFlow(context, currentItem),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.shopping_bag, color: Colors.white),
                label: const Text("Beli Sekarang", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PurchaseCountdownDialog extends StatefulWidget {
  final String itemName;
  const _PurchaseCountdownDialog({required this.itemName});

  @override
  State<_PurchaseCountdownDialog> createState() => _PurchaseCountdownDialogState();
}

class _PurchaseCountdownDialogState extends State<_PurchaseCountdownDialog> {
  int _secondsLeft = 5;
  final Color primaryColor = const Color(0xFF5DB075);

  @override
  void initState() {
    super.initState();
    _tick();
  }

  void _tick() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) {
        Navigator.of(context).pop();
      } else {
        _tick();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: primaryColor),
          const SizedBox(height: 20),
          const Text(
            "Memproses Pembelian...",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            "Menyimulasikan pembelian ${widget.itemName}",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Text(
            "$_secondsLeft",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor),
          ),
        ],
      ),
    );
  }
}