import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event.dart';
import '../models/seat.dart';
import 'retry_handler.dart';
import '../config/local_config.dart';


class ApiService {
  static const String baseUrl = LocalConfig.baseUrl;
  
  late final RetryHandler _retryHandler;
  late final CacheManager _cacheManager;
  
  ApiService() {
    _retryHandler = RetryHandler();
    _cacheManager = CacheManager();
  }


  Future<List<Event>> fetchEvents({String? city}) async {
    final cacheKey = 'events_${city ?? 'all'}';
    
    // Проверяем кэш
    final cachedData = _cacheManager.get<List<Event>>(cacheKey);
    if (cachedData != null) {
      return cachedData;
    }

    Uri uri;
    if (city != null && city.isNotEmpty) {
      uri = Uri.parse('$baseUrl/events?city=$city');
    } else {
      uri = Uri.parse('$baseUrl/events');
    }

    try {
      final response = await _retryHandler.executeRequest(
        () => http.get(uri),
        operationName: 'fetchEvents${city != null ? '?city=$city' : ''}',
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final events = jsonData.map((e) => Event.fromJson(e)).toList();
        
        // Сохраняем в кэш
        _cacheManager.set(cacheKey, events);
        
        return events;
      } else {
        throw NetworkException(
          message: 'Ошибка загрузки событий',
          statusCode: response.statusCode,
        );
      }
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        message: 'Ошибка загрузки событий: $e',
        originalException: e,
      );
    }
  }

  Future<List<Seat>> getSeatsByEvent(int eventId) async {
    final cacheKey = 'seats_$eventId';
    
    // Проверяем кэш
    final cachedData = _cacheManager.get<List<Seat>>(cacheKey);
    if (cachedData != null) {
      return cachedData;
    }

    try {
      final response = await _retryHandler.executeRequest(
        () => http.get(Uri.parse('$baseUrl/seats/$eventId')),
        operationName: 'getSeatsByEvent($eventId)',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final seats = data.map((e) => Seat.fromJson(e)).toList();
        
        // Сохраняем в кэш
        _cacheManager.set(cacheKey, seats);
        
        return seats;
      } else {
        throw NetworkException(
          message: 'Ошибка загрузки мест',
          statusCode: response.statusCode,
        );
      }
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        message: 'Ошибка загрузки мест: $e',
        originalException: e,
      );
    }
  }

  /// Авторизация
  Future<http.Response> login(String email, String password) {
    final uri = Uri.parse('$baseUrl/login');
    return _retryHandler.executeRequest(
      () => http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ),
      operationName: 'login',
    );
  }

  /// Регистрация
  Future<http.Response> register(String name, String email, String password) {
    final uri = Uri.parse('$baseUrl/register');
    return _retryHandler.executeRequest(
      () => http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      ),
      operationName: 'register',
    );
  }

  /// Бронирование мест
  Future<http.Response> bookSeats(String token, int eventId, List<String> seatNumbers) {
    final uri = Uri.parse('$baseUrl/seats/book');
    return _retryHandler.executeRequest(
      () => http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'eventId': eventId,
          'seatNumbers': seatNumbers,
        }),
      ),
      operationName: 'bookSeats',
    );
  }

  /// Запрос на сброс пароля 
  Future<String?> requestPasswordReset(String email) async {
    final uri = Uri.parse('$baseUrl/forgot-password');
    try {
      final response = await _retryHandler.executeRequest(
        () => http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email}),
        ),
        operationName: 'requestPasswordReset',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['token'];
      } else {
        print('Ошибка сброса: ${response.statusCode}, тело: ${response.body}');
        return null;
      }
    } on NetworkException catch (e) {
      print('Ошибка сброса пароля: $e');
      return null;
    }
  }

  /// Отправка нового пароля
  Future<bool> resetPassword(String token, String newPassword) async {
    final uri = Uri.parse('$baseUrl/reset-password');
    try {
      final response = await _retryHandler.executeRequest(
        () => http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'token': token, 'newPassword': newPassword}),
        ),
        operationName: 'resetPassword',
      );

      return response.statusCode == 200;
    } on NetworkException catch (e) {
      print('Ошибка сброса пароля: $e');
      return false;
    }
  }
  
    Future<Map<String, dynamic>?> fetchUserProfile(String token) async {
    final cacheKey = 'profile_$token';
    
    // Проверяем кэш
    final cachedData = _cacheManager.get<Map<String, dynamic>>(cacheKey);
    if (cachedData != null) {
      return cachedData;
    }

    final uri = Uri.parse('$baseUrl/profile');
    try {
      final response = await _retryHandler.executeRequest(
        () => http.get(
          uri,
          headers: {'Authorization': 'Bearer $token'},
        ),
        operationName: 'fetchUserProfile',
      );

      if (response.statusCode == 200) {
        final profile = json.decode(response.body) as Map<String, dynamic>;
        
        // Сохраняем в кэш
        _cacheManager.set(cacheKey, profile);
        
        return profile;
      } else {
        return null;
      }
    } on NetworkException catch (e) {
      print('Ошибка загрузки профиля: $e');
      return null;
    }
  }

  /// Получить билеты пользователя
  Future<List<dynamic>> fetchUserTickets(String token) async {
    final cacheKey = 'tickets_$token';
    
    // Проверяем кэш
    final cachedData = _cacheManager.get<List<dynamic>>(cacheKey);
    if (cachedData != null) {
      return cachedData;
    }

    final uri = Uri.parse('$baseUrl/myTickets');
    try {
      final response = await _retryHandler.executeRequest(
        () => http.get(
          uri,
          headers: {'Authorization': 'Bearer $token'},
        ),
        operationName: 'fetchUserTickets',
      );

      if (response.statusCode == 200) {
        final tickets = jsonDecode(response.body) as List<dynamic>;
        
        _cacheManager.set(cacheKey, tickets, ttl: const Duration(minutes: 2));
        
        return tickets;
      } else {
        throw NetworkException(
          message: 'Ошибка загрузки билетов',
          statusCode: response.statusCode,
        );
      }
    } on NetworkException {
      rethrow;
    }
  }

  /// Получить все события для админ панели
  Future<List<Event>> fetchAdminEvents(String token) async {
    final cacheKey = 'admin_events_$token';
    
    // Проверяем кэш
    final cachedData = _cacheManager.get<List<Event>>(cacheKey);
    if (cachedData != null) {
      return cachedData;
    }

    final uri = Uri.parse('$baseUrl/admin/events');
    try {
      final response = await _retryHandler.executeRequest(
        () => http.get(uri, headers: {
          'Authorization': 'Bearer $token',
        }),
        operationName: 'fetchAdminEvents',
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final events = jsonData.map((e) => Event.fromJson(e)).toList();
        
        // Сохраняем в кэш
        _cacheManager.set(cacheKey, events);
        
        return events;
      } else {
        throw NetworkException(
          message: 'Ошибка загрузки событий (админ)',
          statusCode: response.statusCode,
        );
      }
    } on NetworkException {
      rethrow;
    }
  }
  

  /// Добавить новое событие
  Future<bool> createEvent(String token, Map<String, dynamic> data) async {
    final uri = Uri.parse('$baseUrl/admin/events');
    try {
      final response = await _retryHandler.executeRequest(
        () => http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(data),
        ),
        operationName: 'createEvent',
      );
      
      // Очищаем кэш администратора
      _cacheManager.remove('admin_events_$token');
      
      return response.statusCode == 200 || response.statusCode == 201;
    } on NetworkException catch (e) {
      print('Ошибка создания события: $e');
      return false;
    }
  }

  /// Удалить событие
  Future<bool> deleteEvent(String token, int id) async {
    final uri = Uri.parse('$baseUrl/admin/events/$id');
    try {
      final response = await _retryHandler.executeRequest(
        () => http.delete(
          uri,
          headers: {'Authorization': 'Bearer $token'},
        ),
        operationName: 'deleteEvent($id)',
      );
      
      // Очищаем кэш администратора
      _cacheManager.remove('admin_events_$token');
      
      return response.statusCode == 200;
    } on NetworkException catch (e) {
      print('Ошибка удаления события: $e');
      return false;
    }
  }

  /// Обновить событие
  Future<bool> updateEvent(String token, int id, Map<String, dynamic> data) async {
    final uri = Uri.parse('$baseUrl/admin/events/$id');
    try {
      final response = await _retryHandler.executeRequest(
        () => http.put(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(data),
        ),
        operationName: 'updateEvent($id)',
      );
      
      // Очищаем кэш администратора
      _cacheManager.remove('admin_events_$token');
      
      return response.statusCode == 200;
    } on NetworkException catch (e) {
      print('Ошибка обновления события: $e');
      return false;
    }
  }

  /// Обновление профиля пользователя 
  Future<Map<String, dynamic>?> updateUserProfile(String token, Map<String, String> updates) async {
    final url = Uri.parse('$baseUrl/users/update');

    try {
      final response = await _retryHandler.executeRequest(
        () => http.put(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(updates),
        ),
        operationName: 'updateUserProfile',
      );

      if (response.statusCode == 200) {
        // Очищаем кэш профиля
        _cacheManager.remove('profile_$token');
        
        return jsonDecode(response.body);
      } else {
        print('Ошибка обновления профиля: ${response.body}');
        return null;
      }
    } on NetworkException catch (e) {
      print('Ошибка обновления профиля: $e');
      return null;
    }
  }

  // Отправка FCM токена на сервер
  Future<bool> sendFcmToken(String jwtToken, String token) async {
    final uri = Uri.parse('$baseUrl/users/fcm-token');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: jsonEncode({
          'fcmToken': token   
        }),
      );

      print("FCM RESPONSE STATUS: ${response.statusCode}");
      print("FCM RESPONSE BODY: ${response.body}");

      return response.statusCode == 200;

    } catch (e) {
      print('Ошибка отправки FCM токена: $e');
      return false;
    }
  }

}
