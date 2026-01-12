class Category {
  final int id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    // ĐÃ SỬA: Xóa bỏ "attributes" để đọc trực tiếp từ JSON
    return Category(
      id: json['id'],
      name: json['Name'] ?? 'Unnamed Category',
    );
  }
}
