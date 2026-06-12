import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../auth/login_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final PageController _pageController = PageController();
  bool isLastPage = false;

  void _completeLanding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(bottom: 80),
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => isLastPage = index == 2);
          },
          children: [
            _buildPage(
              color: Colors.teal.shade100,
              title: "My Trash is Other's Treasure",
              subtitle: "Jangan buang barang tak terpakai Anda. Apa yang Anda anggap sampah bisa jadi harta karun bagi orang lain.",
              icon: Icons.delete_sweep,
            ),
            _buildPage(
              color: Colors.green.shade100,
              title: "Solusi Hemat & Tepat",
              subtitle: "Ingin coba pakai suatu barang tapi enggan beli baru? Temukan barang pre-loved dengan deskripsi penggunaan yang transparan hanya di sini.",
              icon: Icons.shopping_bag_outlined, // Gunakan ikon belanja yang sesuai
            ),
            _buildPage(
              color: Colors.red.shade100,
              title: "Surga Para Engineer",
              subtitle: "Butuh komponen kecil dari barang bekas untuk kanibalan proyek? Fitur 'For Disassemble' siap bantu anda berburu komponen aktif.",
              icon: Icons.construction,
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        height: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => _pageController.jumpToPage(2),
              child: const Text("SKIP"),
            ),
            Center(
              child: SmoothPageIndicator(
                controller: _pageController,
                count: 3,
                effect: const WormEffect(activeDotColor: Colors.teal),
              ),
            ),
            isLastPage
                ? TextButton(
                    onPressed: _completeLanding,
                    child: const Text("MULAI"),
                  )
                : TextButton(
                    onPressed: () => _pageController.nextPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    ),
                    child: const Text("LANJUT"),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage({required Color color, required String title, required String subtitle, required IconData icon}) {
    return Container(
      color: color,
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 100, color: Colors.teal.shade800),
          const SizedBox(height: 40),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
