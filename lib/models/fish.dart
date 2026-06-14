class Fish {
  final int? id;
  final String name;
  final String imageUrl;
  final String savedAt;

  Fish({
    this.id,
    required this.name,
    required this.imageUrl,
    required this.savedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'savedAt': savedAt,
    };
  }

  factory Fish.fromMap(Map<String, dynamic> map) {
    return Fish(
      id: map['id'],
      name: map['name'],
      imageUrl: map['imageUrl'],
      savedAt: map['savedAt'],
    );
  }
}