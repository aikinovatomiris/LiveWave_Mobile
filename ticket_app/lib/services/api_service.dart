import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event.dart';
import '../models/seat.dart';

class ApiService {
  static const String baseUrl = "http://192.168.0.101:8080";
  // static const String baseUrl = "http://172.20.10.3:8080";


  Future<List<Event>> fetchEvents({String? city}) async {
    Uri uri;
    if (city != null && city.isNotEmpty) {
      uri = Uri.parse('$baseUrl/events?city=$city');
    } else {
      uri = Uri.parse('$baseUrl/events');
    }

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((e) => Event.fromJson(e)).toList();
    } else {
      throw Exception('Ошибка загрузки событий: ${response.statusCode}');
    }
  }

  Future<List<Seat>> getSeatsByEvent(int eventId) async {
    final response = await http.get(Uri.parse('$baseUrl/seats/$eventId'));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Seat.fromJson(e)).toList();
    } else {
      throw Exception('Ошибка загрузки мест: ${response.statusCode}');
    }
  }

  /// Авторизация
  Future<http.Response> login(String email, String password) {
    final uri = Uri.parse('$baseUrl/login');
    return http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
  }

  /// Регистрация
  Future<http.Response> register(String name, String email, String password) {
    final uri = Uri.parse('$baseUrl/register');
    return http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
  }

  /// Бронирование мест
  Future<http.Response> bookSeats(String token, int eventId, List<String> seatNumbers) {
    final uri = Uri.parse('$baseUrl/seats/book');
    return http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'eventId': eventId,
        'seatNumbers': seatNumbers,
      }),
    );
  }

    /// Запрос на сброс пароля 
  Future<String?> requestPasswordReset(String email) async {
  final uri = Uri.parse('$baseUrl/forgot-password');
  final response = await http.post(
    uri,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'email': email}),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['token'];
  } else {
    print('Ошибка сброса: ${response.statusCode}, тело: ${response.body}');
    return null;
  }
}

  /// Отправка нового пароля
  Future<bool> resetPassword(String token, String newPassword) async {
    final uri = Uri.parse('$baseUrl/reset-password');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': token, 'newPassword': newPassword}),
    );

    return response.statusCode == 200;
  }
  
    Future<Map<String, dynamic>?> fetchUserProfile(String token) async {
    final uri = Uri.parse('$baseUrl/profile');
    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  Future<List<dynamic>> fetchUserTickets(String token) async {
    final uri = Uri.parse('$baseUrl/myTickets');
    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Ошибка загрузки билетов: ${response.statusCode}');
    }
  }

   /// Получить все события для админ панели
  Future<List<Event>> fetchAdminEvents(String token) async {
    final uri = Uri.parse('$baseUrl/admin/events');
    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((e) => Event.fromJson(e)).toList();
    } else {
      throw Exception('Ошибка загрузки событий (админ): ${response.statusCode}');
    }
  }
  

  /// Добавить новое событие
  Future<bool> createEvent(String token, Map<String, dynamic> data) async {
    final uri = Uri.parse('$baseUrl/admin/events');
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  /// Удалить событие
  Future<bool> deleteEvent(String token, int id) async {
    final uri = Uri.parse('$baseUrl/admin/events/$id');
    final response = await http.delete(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );
    return response.statusCode == 200;
  }

  /// Обновить событие
  Future<bool> updateEvent(String token, int id, Map<String, dynamic> data) async {
    final uri = Uri.parse('$baseUrl/admin/events/$id');
    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    return response.statusCode == 200;
  }

    /// Обновление профиля пользователя 
  Future<Map<String, dynamic>?> updateUserProfile(String token, Map<String, String> updates) async {
    final url = Uri.parse('$baseUrl/users/update'); 

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(updates),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Ошибка обновления профиля: ${response.body}');
      return null;
    }
  }


}
