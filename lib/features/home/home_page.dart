import 'package:flutter/material.dart';
import 'item_model.dart';
import '../item_detail/item_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _carouselController = PageController();
  final Color primaryColor = const Color(0xFF5DB075);

  final List<Item> items = [
    Item(id: "1", name: "Monitor LCD 19 Inch", description: "Monitor kantor normal", defectDescription: "Ada baret halus di stand belakang", stars: 5),
    Item(id: "2", name: "Mouse Logi B100", description: "Mouse kabel USB", defectDescription: "Klik kiri agak keras", stars: 3),
    Item(id: "3", name: "Printer HP InkTank (Rusak)", description: "Mati total, board aman", defectDescription: "Head mampet, dinamo mati", stars: 1), 
    Item(id: "4", name: "Adaptor Laptop Asus 19V", description: "Kabel terkelupas sedikit", defectDescription: "Kabel dekat jack disolasi", stars: 4, isManualDisassemble: true), 
  ];

  @override
  void dispose() {
    _carouselController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Treasure Trash Market",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: primaryColor,
        elevation: 2,
        actions: [
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
      body: CustomScrollView(
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
                          MaterialPageRoute(builder: (context) => ItemDetailPage(item: item)),
                        );
                        setState(() {}); 
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 90,
                              decoration: BoxDecoration(
                                color: isDisassemble ? Colors.orange.shade200 : primaryColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Icon(
                                  isDisassemble ? Icons.developer_board : Icons.devices,
                                  size: 40,
                                  color: isDisassemble ? Colors.orange.shade800 : primaryColor,
                                ),
                              ),
                            ),
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
