import 'dart:async';
import 'package:http/http.dart' as http;

class RetryConfig {
  final int maxRetries;
  
  final Duration initialDelay;
  
  final double backoffMultiplier;
  
  final Duration maxDelay;
  
  final List<int> retryableStatusCodes;
  
  final Duration requestTimeout;

  RetryConfig({
    this.maxRetries = 3,
    this.initialDelay = const Duration(milliseconds: 500),
    this.backoffMultiplier = 2.0,
    this.maxDelay = const Duration(seconds: 10),
    this.retryableStatusCodes = const [408, 429, 500, 502, 503, 504],
    this.requestTimeout = const Duration(seconds: 30),
  });
}

/// Кастомное исключение для сетевых ошибок
class NetworkException implements Exception {
  final String message;
  final int? statusCode;
  final Object? originalException;

  NetworkException({
    required this.message,
    this.statusCode,
    this.originalException,
  });

  @override
  String toString() => 'NetworkException: $message${statusCode != null ? ' (HTTP $statusCode)' : ''}';
}

/// Обработчик retry с экспоненциальным отступом
class RetryHandler {
  final RetryConfig config;

  RetryHandler({RetryConfig? config}) : config = config ?? RetryConfig();

  Future<T> execute<T>(
    Future<T> Function() operation, {
    String? operationName,
  }) async {
    int attempt = 0;
    Duration delay = config.initialDelay;

    while (true) {
      try {
        attempt++;
        
        return await operation().timeout(
          config.requestTimeout,
          onTimeout: () => throw TimeoutException(
            'Request timeout after ${config.requestTimeout.inSeconds}s',
          ),
        );
      } on TimeoutException catch (e) {
        if (attempt >= config.maxRetries) {
          throw NetworkException(
            message: 'Timeout after $attempt attempts',
            originalException: e,
          );
        }
        _logRetry(
          operationName,
          attempt,
          'Timeout',
          delay,
        );
        await Future.delayed(delay);
        delay = _calculateNextDelay(delay);
      } on Exception catch (e) {
        if (attempt >= config.maxRetries) {
          throw NetworkException(
            message: 'Failed after $attempt attempts: $e',
            originalException: e,
          );
        }
        _logRetry(
          operationName,
          attempt,
          e.toString(),
          delay,
        );
        await Future.delayed(delay);
        delay = _calculateNextDelay(delay);
      }
    }
  }

  /// Выполняет HTTP запрос с retry логикой
  Future<http.Response> executeRequest(
    Future<http.Response> Function() requestFn, {
    String? operationName,
  }) async {
    int attempt = 0;
    Duration delay = config.initialDelay;

    while (true) {
      try {
        attempt++;

        final response = await requestFn().timeout(
          config.requestTimeout,
          onTimeout: () => throw TimeoutException(
            'Request timeout after ${config.requestTimeout.inSeconds}s',
          ),
        );

        if (response.statusCode < 400 ||
            !config.retryableStatusCodes.contains(response.statusCode)) {
          return response;
        }

        if (attempt >= config.maxRetries) {
          throw NetworkException(
            message: 'HTTP Error after $attempt attempts',
            statusCode: response.statusCode,
          );
        }

        _logRetry(
          operationName,
          attempt,
          'HTTP ${response.statusCode}',
          delay,
        );
        await Future.delayed(delay);
        delay = _calculateNextDelay(delay);
      } on TimeoutException catch (e) {
        if (attempt >= config.maxRetries) {
          throw NetworkException(
            message: 'Timeout after $attempt attempts',
            originalException: e,
          );
        }
        _logRetry(
          operationName,
          attempt,
          'Timeout',
          delay,
        );
        await Future.delayed(delay);
        delay = _calculateNextDelay(delay);
      } on Exception catch (e) {
        if (attempt >= config.maxRetries) {
          throw NetworkException(
            message: 'Network error after $attempt attempts: $e',
            originalException: e,
          );
        }
        _logRetry(
          operationName,
          attempt,
          e.toString(),
          delay,
        );
        await Future.delayed(delay);
        delay = _calculateNextDelay(delay);
      }
    }
  }

  /// Вычисляет следующую задержку с экспоненциальным отступом
  Duration _calculateNextDelay(Duration currentDelay) {
    final nextDelay = Duration(
      milliseconds: (currentDelay.inMilliseconds * config.backoffMultiplier).toInt(),
    );
    return nextDelay.compareTo(config.maxDelay) > 0
        ? config.maxDelay
        : nextDelay;
  }

  /// Логирует retry попытку
  void _logRetry(
    String? operationName,
    int attempt,
    String error,
    Duration nextDelay,
  ) {
    print(
      '[RETRY] Operation: ${operationName ?? 'unknown'} | '
      'Attempt: $attempt/${config.maxRetries} | '
      'Error: $error | '
      'Next retry in: ${nextDelay.inMilliseconds}ms',
    );
  }
}

/// Fallback механизм для кэширования данных
class CacheManager {
  final Map<String, CacheEntry> _cache = {};
  final Duration defaultTtl;

  CacheManager({this.defaultTtl = const Duration(minutes: 5)});

  /// Сохраняет данные в кэш
  void set<T>(String key, T value, {Duration? ttl}) {
    _cache[key] = CacheEntry<T>(
      value: value,
      expiresAt: DateTime.now().add(ttl ?? defaultTtl),
    );
    print('[CACHE] Cached: $key');
  }

  /// Получает данные из кэша, если они не истекли
  T? get<T>(String key) {
    final entry = _cache[key];
    if (entry != null && !entry.isExpired) {
      print('[CACHE] Hit: $key');
      return entry.value as T?;
    }
    if (entry != null && entry.isExpired) {
      _cache.remove(key);
      print('[CACHE] Expired: $key');
    }
    return null;
  }

  /// Очищает весь кэш
  void clear() {
    _cache.clear();
    print('[CACHE] Cache cleared');
  }

  /// Удаляет конкретный ключ
  void remove(String key) {
    _cache.remove(key);
    print('[CACHE] Removed: $key');
  }
}

/// Запись в кэше
class CacheEntry<T> {
  final T value;
  final DateTime expiresAt;

  CacheEntry({required this.value, required this.expiresAt});

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// Стратегия обработки ошибок с fallback
class ErrorRecoveryStrategy {
  final Future<T> Function<T>()? getFallbackValue;
  
  final bool allowPartialCache;

  ErrorRecoveryStrategy({
    this.getFallbackValue,
    this.allowPartialCache = false,
  });
}
