import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/local_config.dart';

class GraphQLService {
  GraphQLService._();
  static final instance = GraphQLService._();

  GraphQLClient? _client;

  Future<void> init({String? token}) async {
    await initHiveForFlutter();

    final httpLink = HttpLink('${LocalConfig.baseUrl}/graphql');

    Link link = httpLink;

    final t = (token ?? '').trim();
    if (t.isNotEmpty) {
      final authLink = AuthLink(getToken: () async => 'Bearer $t');
      link = authLink.concat(httpLink);
    }

    _client = GraphQLClient(
      link: link,
      cache: GraphQLCache(store: HiveStore()),
    );
  }

  /// Инициализация без токена (для гостя)
  Future<void> initAsGuest() => init(token: null);

  /// Инициализация с токеном, если он есть в SharedPreferences
  Future<void> initFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    await init(token: token);
  }

  bool get isReady => _client != null;

  GraphQLClient get client {
    if (_client == null) {
      throw Exception('GraphQLClient not initialized. Call GraphQLService.instance.init...() first.');
    }
    return _client!;
  }

  Future<QueryResult> query(String document, {Map<String, dynamic>? variables}) {
    return client.query(
      QueryOptions(
        document: gql(document),
        variables: variables ?? const {},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
  }

  Future<QueryResult> mutate(String document, {Map<String, dynamic>? variables}) {
    return client.mutate(
      MutationOptions(
        document: gql(document),
        variables: variables ?? const {},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
  }
}