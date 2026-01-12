import 'dart:convert';

class Registration {
  final String name; 
  final String email;
  final String phone;
  final int? eventId;

  Registration({required this.name, required this.email, required this.phone, this.eventId});

  Map<String, dynamic> toJson() => {
    'data': {
      // ĐÃ SỬA: Dùng đúng tên trường từ Strapi: FullName, PhoneNumber
      'FullName': name,
      'Email': email,
      'PhoneNumber': phone,
      // Đảm bảo tên trường quan hệ "events_lists" là chính xác
      'events_lists': eventId == null ? [] : [eventId],
    }
  };
}
