// Etiquetas disponibles para posts
class PostTag {
  final String id;
  final String name;
  final String emoji;

  const PostTag({required this.id, required this.name, required this.emoji});

  String get displayName => '$emoji $name';

  static const List<PostTag> availableTags = [
    PostTag(id: 'dog', name: 'Perrito', emoji: '🐶'),
    PostTag(id: 'cat', name: 'Gatito', emoji: '🐱'),
    PostTag(id: 'rabbit', name: 'Conejito', emoji: '🐰'),
    PostTag(id: 'bird', name: 'Pajarito', emoji: '🦜'),
    PostTag(id: 'hamster', name: 'Hámster', emoji: '🐹'),
    PostTag(id: 'fish', name: 'Pececito', emoji: '🐠'),
    PostTag(id: 'turtle', name: 'Tortuga', emoji: '🐢'),
    PostTag(id: 'horse', name: 'Caballo', emoji: '🐴'),
    PostTag(id: 'pig', name: 'Cerdito', emoji: '🐷'),
    PostTag(id: 'other', name: 'Otra Mascota', emoji: '🐾'),
  ];

  static PostTag fromId(String? id) {
    if (id == null) return availableTags.last; // 'other' tag
    try {
      return availableTags.firstWhere(
        (tag) => tag.id == id,
        orElse: () => availableTags.last,
      );
    } catch (e) {
      return availableTags.last;
    }
  }
}
