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
  final Color primaryColor = const Color(0xFF5DB075);

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
              backgroundColor: primaryColor,
              textColor: Colors.white,
              iconColor: Colors.white,
              title: "My Trash is Other's Treasure",
              subtitle: "Jangan buang barang tak terpakai Anda. Apa yang Anda anggap sampah bisa jadi harta karun bagi orang lain.",
              icon: Icons.delete_sweep,
            ),
            _buildPage(
              backgroundColor: Colors.white,
              textColor: Colors.black87,
              iconColor: primaryColor,
              title: "Solusi Hemat & Tepat",
              subtitle: "Ingin mencoba pakai suatu barang tapi enggan beli baru? Temukan barang pre-loved dengan deskripsi penggunaan yang transparan hanya di sini.",
              icon: Icons.shopping_bag_outlined,
            ),
            _buildPage(
              backgroundColor: primaryColor,
              textColor: Colors.white,
              iconColor: Colors.white,
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
        color: Colors.white, // PERBAIKAN: Menggunakan color, bukan backgroundColor
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => _pageController.jumpToPage(2),
              child: Text("SKIP", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
            ),
            Center(
              child: SmoothPageIndicator(
                controller: _pageController,
                count: 3,
                effect: WormEffect(activeDotColor: primaryColor, dotColor: primaryColor.withOpacity(0.3)),
              ),
            ),
            isLastPage
                ? TextButton(
                    onPressed: _completeLanding,
                    child: Text("MULAI", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                  )
                : TextButton(
                    onPressed: () => _pageController.nextPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    ),
                    child: Text("LANJUT", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage({
    required Color backgroundColor,
    required Color textColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 100, color: iconColor),
          const SizedBox(height: 40),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 20),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: textColor.withOpacity(0.8), height: 1.4),
          ),
        ],
      ),
    );
  }
}
