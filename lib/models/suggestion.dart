class Suggestion {
  final String kdBarang;
  final String namaBarang;
  final String brand;

  Suggestion({
    this.kdBarang,
    this.namaBarang,
    this.brand,
  });

  factory Suggestion.fromJson(Map<String, dynamic> json) {
    return Suggestion(
      kdBarang: json['kdBarang'],
      namaBarang: json['namaBarang'],
      brand: json['brand'],
    );
  }
}
