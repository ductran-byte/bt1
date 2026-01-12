import 'dart:convert';
import 'package:bt1/src/models/registration.dart';
import 'package:http/http.dart' as http;
import '../models/category.dart';
import '../models/event.dart';

// Lớp để chứa cả dữ liệu sự kiện và thông tin phân trang
class PaginatedEvents {
  final List<Event> events;
  final int pageCount;
  final int total;

  PaginatedEvents({required this.events, required this.pageCount, required this.total});
}

class ApiService {
  static const String _strapiUrl = 'http://10.24.32.193:1337';
  static const String _baseUrl = '$_strapiUrl/api';

  Future<PaginatedEvents> fetchEvents({int page = 1, int pageSize = 10, int? categoryId}) async {
    String url = '$_baseUrl/events-lists?populate=*&pagination[page]=$page&pagination[pageSize]=$pageSize';
    
    if (categoryId != null) {
      url += '&filters[events_category][id][\$eq]=$categoryId';
    }

    print('Fetching events from: $url');
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List eventsData = data['data'] as List;
      final meta = data['meta']['pagination'];

      return PaginatedEvents(
        events: eventsData.map((json) => Event.fromJson(json)).toList(),
        pageCount: meta['pageCount'],
        total: meta['total'],
      );
    } else {
      throw Exception('Failed to load events');
    }
  }

  Future<List<Category>> fetchCategories() async {
    final url = '$_baseUrl/events-categories';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return (data['data'] as List).map((json) => Category.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<void> submitRegistration(String name, String email, String phone, int? eventId) async {
    final registration = Registration(name: name, email: email, phone: phone, eventId: eventId);
    final response = await http.post(
      Uri.parse('$_baseUrl/registrations'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(registration.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to submit registration');
    }
  }

  static String getFullImageUrl(String? relativePath) {
    if (relativePath == null) return 'https://via.placeholder.com/150';
    if (relativePath.startsWith('http')) return relativePath;
    return _strapiUrl + relativePath;
  }
}
