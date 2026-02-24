import 'dart:async';
import 'dart:convert';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../config/local_config.dart';
import '../models/seat.dart';

class WebsocketService {
  WebsocketService._();
  static final instance = WebsocketService._();

  StompClient? _client;
  bool _connected = false;
  bool _connecting = false;

  final Map<int, void Function(Seat)> _seatHandlers = {};
  final Map<int, StompUnsubscribe> _seatSubscriptions = {};

  bool get isConnected => _connected;

  void connect() {
    if (_connected || _connecting) return;
    _connecting = true;

    final base = LocalConfig.baseUrl.trim();

    final wsBase = base.startsWith('https://')
        ? base.replaceFirst('https://', 'wss://')
        : base.startsWith('http://')
            ? base.replaceFirst('http://', 'ws://')
            : 'ws://$base';

    final wsUrl = '$wsBase/ws';

    print('🔧 WS url: $wsUrl');

    _client = StompClient(
      config: StompConfig(
        url: wsUrl,
        useSockJS: false, 
        onConnect: (frame) {
          print('✅ STOMP connected');
          _connected = true;
          _connecting = false;
          _restoreSeatSubscriptions();
        },
        onWebSocketError: (dynamic error) {
          print('WebSocket error: $error');
          _connected = false;
          _connecting = false;
          _reconnect();
        },
        onDisconnect: (_) {
          print('disconnected');
          _connected = false;
          _connecting = false;
          _reconnect();
        },
        onStompError: (frame) => print('STOMP error: ${frame.body}'),
      ),
    );

    _client!.activate();
  }

  void subscribeToSeats(int eventId, void Function(Seat) onUpdate) {
    _seatHandlers[eventId] = onUpdate;
    if (!_connected) connect();
    if (_seatSubscriptions.containsKey(eventId) || !_connected) return;
    _subscribeSeatsInternal(eventId);
  }

  void _restoreSeatSubscriptions() {
    for (final eventId in _seatHandlers.keys) {
      _seatSubscriptions[eventId]?.call();
      _seatSubscriptions.remove(eventId);
      _subscribeSeatsInternal(eventId);
    }
  }

  void _subscribeSeatsInternal(int eventId) {
    final destination = '/topic/seats/$eventId';

    final unsub = _client?.subscribe(
      destination: destination,
      callback: (frame) {
        if (frame.body == null) return;
        final data = jsonDecode(frame.body!);
        final seat = Seat.fromJson(Map<String, dynamic>.from(data));
        _seatHandlers[eventId]?.call(seat);
      },
    );

    if (unsub != null) {
      _seatSubscriptions[eventId] = unsub;
      print('subscribed $destination');
    }
  }

  void unsubscribeFromSeats(int eventId) {
    _seatHandlers.remove(eventId);
    _seatSubscriptions[eventId]?.call();
    _seatSubscriptions.remove(eventId);
  }

  void _reconnect() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!_connected && !_connecting && _seatHandlers.isNotEmpty) {
        print('reconnecting...');
        connect();
      }
    });
  }
}