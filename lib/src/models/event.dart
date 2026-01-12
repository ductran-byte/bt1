import 'dart:convert';

class Event {
  final int id;
  final String name;
  final String description;
  final DateTime? dateTime;
  final String? imageUrl;

  Event({
    required this.id,
    required this.name,
    required this.description,
    this.dateTime,
    this.imageUrl,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    // ĐÃ SỬA: Lấy URL ảnh trực tiếp từ danh sách Image (cấu trúc flattened)
    String? getImageUrl(Map<String, dynamic> json) {
      try {
        final images = json['Image'];
        if (images != null && images is List && images.isNotEmpty) {
          // Lấy trường 'url' trực tiếp từ phần tử đầu tiên
          return images[0]['url'];
        }
        return null;
      } catch (e) {
        return null;
      }
    }

    DateTime? parseDateTime(String? dateStr) {
      if (dateStr == null) return null;
      try {
        return DateTime.parse(dateStr);
      } catch (e) {
        return null;
      }
    }

    String parseRichText(dynamic descriptionJson) {
      if (descriptionJson == null || descriptionJson is! List) {
        return 'No Description';
      }
      try {
        StringBuffer buffer = StringBuffer();
        for (var block in descriptionJson) {
          if (block['type'] == 'paragraph') {
            for (var child in block['children']) {
              if (child['type'] == 'text') {
                buffer.write(child['text']);
              }
            }
            buffer.write('\n');
          }
        }
        return buffer.toString().trim();
      } catch (e) {
        return 'Error parsing description';
      }
    }

    return Event(
      id: json['id'],
      name: json['Name'] ?? 'No Name',
      description: parseRichText(json['Description']),
      dateTime: parseDateTime(json['StartTime']),
      imageUrl: getImageUrl(json),
    );
  }
}
