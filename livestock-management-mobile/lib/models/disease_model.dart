class Disease {
  final String id;
  final String name;

  Disease({required this.id, required this.name});

  factory Disease.fromJson(Map<String, dynamic> json) {
    return Disease(
      id: json['id'],
      name: json['name'],
    );
  }
}

class Medicine {
  final String id;
  final String name;

  Medicine({required this.id, required this.name});

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id'],
      name: json['name'],
    );
  }
}
