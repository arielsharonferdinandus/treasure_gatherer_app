class Item {
  final String id;
  final String name;
  final String description;
  final String defectDescription;
  int stars;
  bool isManualDisassemble; // Diatur manual oleh pengguna

  Item({
    required this.id,
    required this.name,
    required this.description,
    required this.defectDescription,
    this.stars = 5,
    this.isManualDisassemble = false,
  });

  // System Automatic Star Categorize Logic
  void processReSell(String usageDuration) {
    if (usageDuration == "sangat cepat") {
      stars -= 2; // mengecewakan langsung dijual lagi
    } else if (usageDuration == "cukup lama") {
      stars -= 1; // pemakaian memuaskan hingga tuntas
    } else if (usageDuration == "sangat lama") {
      stars -= 2; // penggunaan lama meningkatkan deffektifitas
    }
    
    if (stars < 0) stars = 0;
  }

  // Menentukan apakah barang masuk kategori disassemble (Otomatis jika star < 1, atau Manual oleh user)
  bool get isForDisassemble => (stars <= 1) || isManualDisassemble;
}
