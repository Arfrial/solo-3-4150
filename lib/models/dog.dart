class Dog {
  final int? id;
  final String breed;
  final String imageUrl;
  final String savedAt;

  Dog({
    this.id,
    required this.breed,
    required this.imageUrl,
    required this.savedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'breed': breed,
      'imageUrl': imageUrl,
      'savedAt': savedAt,
    };
  }

  factory Dog.fromMap(Map<String, dynamic> map) {
    return Dog(
      id: map['id'],
      breed: map['breed'],
      imageUrl: map['imageUrl'],
      savedAt: map['savedAt'],
    );
  }
}