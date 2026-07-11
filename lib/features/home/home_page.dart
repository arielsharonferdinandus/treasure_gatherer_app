import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/item_provider.dart';
import '../../data/models/item_model.dart';
import '../product/product_page.dart';
import '../product/register_page.dart';
import '../../core/shared_widgets/item_image.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _carouselController = PageController();
  final Color primaryColor = const Color(0xFF5DB075);

  @override
  void initState() {
    super.initState();
    // Fetch items from the API
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ItemProvider>().fetchItems();
    });
  }

  @override
  void dispose() {
    _carouselController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemProvider = context.watch<ItemProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Treasure Trash Market",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: primaryColor,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => context.read<ItemProvider>().refresh(),
            tooltip: "Muat ulang data",
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Menu $value dipilih")),
              );
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(value: "Pengaturan", child: Text("Pengaturan")),
                const PopupMenuItem(value: "Tentang", child: Text("Tentang Aplikasi")),
              ];
            },
          ),
        ],
      ),
      body: _buildBody(itemProvider),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RegisterPage()),
          );
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Jual Barang", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildBody(ItemProvider itemProvider) {
    // Initial load
    if (itemProvider.isLoading && itemProvider.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Load failed and nothing to show
    if (itemProvider.errorMessage != null && itemProvider.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(
                itemProvider.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.read<ItemProvider>().fetchItems(),
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                child: const Text("Coba Lagi", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    final items = itemProvider.items;

    return RefreshIndicator(
      onRefresh: () => context.read<ItemProvider>().refresh(),
      color: primaryColor,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16.0),
              height: 180,
              child: PageView(
                controller: _carouselController,
                children: [
                  _buildAdBanner(),
                  _buildYoutubeBanner(),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                "Semua Harta Karun (Item Pool)",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey),
              ),
            ),
          ),
          if (items.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(child: Text("Belum ada barang tersedia.")),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = items[index];
                    final bool isDisassemble = item.isForDisassemble;

                    return Card(
                      color: isDisassemble ? Colors.orange.shade50 : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isDisassemble ? Colors.orange.shade200 : primaryColor.withOpacity(0.4),
                          width: 1,
                        ),
                      ),
                      elevation: 3,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ProductPage(item: item)),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildThumbnail(item, isDisassemble),
                              const SizedBox(height: 8),
                              Text(
                                item.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: List.generate(5, (starIndex) {
                                  return Icon(
                                    starIndex < item.stars ? Icons.star : Icons.star_border,
                                    color: Colors.amber,
                                    size: 14,
                                  );
                                }),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Defect: ${item.defectDescription}",
                                style: const TextStyle(fontSize: 11, color: Colors.redAccent),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isDisassemble ? Colors.orange.shade700 : primaryColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  isDisassemble ? "Disassemble" : "Layak Pakai",
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: items.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildThumbnail(Item item, bool isDisassemble) {
    return ItemImage(
      source: item.thumbnailUrl,
      height: 90,
      width: double.infinity,
      borderRadius: BorderRadius.circular(8),
      placeholderIcon: isDisassemble ? Icons.developer_board : Icons.devices,
      placeholderColor: isDisassemble ? Colors.orange.shade800 : primaryColor,
      placeholderBackground: isDisassemble ? Colors.orange.shade200 : primaryColor.withOpacity(0.15),
    );
  }

  Widget _buildAdBanner() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.red.shade800,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: const [
                Icon(Icons.warning, color: Colors.amber, size: 20),
                SizedBox(width: 8),
                Text(
                  "INFO PENTING",
                  style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              "Jangan mau ditipu sama Oknum Rayap!!",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            const Text(
              "Konsultasikan nilai jual harta usang mu sebelum dijual dengan penilaian objektif oleh konsultan resmi kami.",
              style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.3),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYoutubeBanner() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.grey.shade900,
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.25,
              child: Container(
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.laptop_mac, size: 100, color: Colors.white),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    const Icon(Icons.play_circle_fill, color: Colors.red, size: 24),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
                      child: const Text(
                        "YOUTUBE TUTORIAL",
                        style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  "Learn how to disassemble Any Laptop easily | How to Take Apart and Clean a laptop",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                const Text(
                  "Channel: Electronics Repair Basics_ERB\nYuk tonton langkah taktis mempreteli casing & motherboard komputer buat kanibalan project engineer mu!",
                  style: TextStyle(color: Colors.grey, fontSize: 10, height: 1.3),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}