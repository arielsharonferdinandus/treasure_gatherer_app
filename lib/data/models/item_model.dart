class Item {
  final String id;
  final String name;
  final String description;
  final String thumbnailUrl;
  final double price;

  String defectDescription;
  int stars;
  bool isManualDisassemble;

  Item({
    required this.id,
    required this.name,
    required this.description,
    this.thumbnailUrl = '',
    this.price = 0,
    this.defectDescription = "Belum ada catatan kondisi barang.",
    this.stars = 5,
    this.isManualDisassemble = false,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'].toString(),
      name: json['name'] as String? ?? 'Tanpa Nama',
      description: json['description'] as String? ?? '',
      thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      defectDescription: json['defectDescription'] as String? ??
          "Belum ada catatan kondisi barang.",
      stars: (json['stars'] as num?)?.toInt() ?? 5,
      isManualDisassemble: json['isManualDisassemble'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "description": description,
      "thumbnailUrl": thumbnailUrl,
      "price": price,
      "defectDescription": defectDescription,
      "stars": stars,
      "isManualDisassemble": isManualDisassemble,
    };
  }

  // ---------- Star/disassemble system ----------

  void processReSell(String usageDuration) {
    if (usageDuration == "sangat cepat") {
      stars -= 2;
    } else if (usageDuration == "cukup lama") {
      stars -= 1;
    } else if (usageDuration == "sangat lama") {
      stars -= 2;
    }
    if (stars < 0) stars = 0;
  }

  bool get isForDisassemble => (stars <= 1) || isManualDisassemble;
}
