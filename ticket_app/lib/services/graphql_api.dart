import '../models/event.dart';
import '../models/seat.dart';
import 'api_service.dart';
import 'graphql_service.dart';
import 'graphql_queries.dart';

class GraphQLApi {
  GraphQLApi._();
  static final instance = GraphQLApi._();

  final _rest = ApiService();

  Future<List<Event>> fetchEvents({String? city}) async {
    // Если GraphQL ещё не инициализирован — не ломаемся, идём в REST
    if (!GraphQLService.instance.isReady) {
      return _rest.fetchEvents(city: city);
    }

    try {
      final result = await GraphQLService.instance.query(
        GraphQLQueries.events,
        variables: {
          'city': (city != null && city.trim().isNotEmpty) ? city.trim() : null,
          'limit': 200,
          'offset': 0,
        },
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      final List list = result.data?['events'] ?? [];
      return list.map((e) => Event.fromJson(e)).toList();
    } catch (_) {
      // fallback
      return _rest.fetchEvents(city: city);
    }
  }

  Future<List<Seat>> getSeatsByEvent(int eventId) async {
    if (!GraphQLService.instance.isReady) {
      return _rest.getSeatsByEvent(eventId);
    }

    try {
      final result = await GraphQLService.instance.query(
        GraphQLQueries.seats,
        variables: {'eventId': eventId.toString()},
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      final List list = result.data?['seats'] ?? [];
      return list.map((e) => Seat.fromJson(e)).toList();
    } catch (_) {
      return _rest.getSeatsByEvent(eventId);
    }
  }

  Future<Map<String, dynamic>> buyTicketsGraphQL({
    required int eventId,
    required List<String> seatNumbers,
  }) async {
    final result = await GraphQLService.instance.mutate(
      GraphQLQueries.buyTickets,
      variables: {
        'eventId': eventId.toString(),
        'seatNumbers': seatNumbers,
      },
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    return result.data?['buyTickets'] ?? {};
  }
}