import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/bottom_nav_bar.dart';
import 'purchased_ticket_screen.dart';
import '../services/api_service.dart';
import 'dart:ui';

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({Key? key}) : super(key: key);

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  final ApiService _apiService = ApiService();
  bool isLoading = true;
  List<dynamic> tickets = [];

  @override
  void initState() {
    super.initState();
    _fetchTickets();
  }

  Future<void> _fetchTickets() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Пожалуйста, войдите в систему')),
        );
        Navigator.pushReplacementNamed(context, '/login');
      }
      return;
    }

    try {
      final data = await _apiService.fetchUserTickets(token);
      if (mounted) {
        setState(() {
          tickets = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    }
  }

  DateTime? _parseDate(String? raw) {
    if (raw == null) return null;
    raw = raw.trim();
    if (raw.isEmpty) return null;
    try {
      return DateTime.parse(raw);
    } catch (_) {}
    try {
      return DateFormat('dd.MM.yyyy, HH:mm').parse(raw);
    } catch (_) {}
    try {
      return DateFormat('dd.MM.yyyy').parse(raw);
    } catch (_) {}
    return null;
  }

  String _formatConcertDate(String? raw) {
    final dt = _parseDate(raw);
    if (dt == null) return raw ?? '';
    try {
      return DateFormat('d MMM yyyy, HH:mm', 'ru').format(dt);
    } catch (_) {
      return DateFormat('dd.MM.yyyy, HH:mm').format(dt);
    }
  }

  String _formatShortDate(String raw) {
    try {
      final parsed = DateTime.parse(raw);
      return DateFormat('dd.MM.yyyy, HH:mm').format(parsed);
    } catch (_) {
      try {
        final parsed = DateFormat('dd.MM.yyyy, HH:mm').parse(raw);
        return DateFormat('dd.MM.yyyy, HH:mm').format(parsed);
      } catch (_) {
        return raw;
      }
    }
  }

  DateTime? _getEventDateFromTicket(Map ticket) {
    final event = ticket['event'];
    if (event != null) {
      final raw = event['date'] as String?;
      final dt = _parseDate(raw);
      if (dt != null) return dt;
    }
    final purchaseRaw = ticket['purchaseDate'] as String?;
    return _parseDate(purchaseRaw);
  }

  DateTime? _getPurchaseDate(Map ticket) {
    final raw = ticket['purchaseDate'] as String?;
    return _parseDate(raw);
  }

  bool _isUpcoming(Map ticket) {
    final dt = _getEventDateFromTicket(ticket);
    if (dt == null) return false;
    return dt.isAfter(DateTime.now().subtract(const Duration(minutes: 1)));
  }

  void _openPurchasedTicket(Map ticket) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (context, animation, secondaryAnimation) =>
          PurchasedTicketScreen(ticket: Map<String, dynamic>.from(ticket)),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final fade = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          );

          final slide = Tween<Offset>(
            begin: const Offset(0, 0.05),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ));

          return FadeTransition(
            opacity: fade,
            child: SlideTransition(
              position: slide,
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double bottomNavHeight = 100.0;

    final upcomingTickets = tickets
        .whereType<Map>()
        .where((t) => _isUpcoming(t))
        .toList()
      ..sort((a, b) {
        final da = _getEventDateFromTicket(a) ?? DateTime.fromMillisecondsSinceEpoch(0);
        final db = _getEventDateFromTicket(b) ?? DateTime.fromMillisecondsSinceEpoch(0);
        return da.compareTo(db); 
      });

    final historyTickets = tickets
        .whereType<Map>()
        .toList()
      ..sort((a, b) {
        final pa = _getPurchaseDate(a) ?? _getEventDateFromTicket(a) ?? DateTime.fromMillisecondsSinceEpoch(0);
        final pb = _getPurchaseDate(b) ?? _getEventDateFromTicket(b) ?? DateTime.fromMillisecondsSinceEpoch(0);
        return pb.compareTo(pa); 
      });

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/background.JPEG',
                fit: BoxFit.cover,
              ),
            ),

            SafeArea(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Мои билеты',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.25),
                                    blurRadius: 20,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(color: Colors.white.withOpacity(0.25)),
                                    ),
                                    child: TabBar(
                                      indicator: BoxDecoration(
                                        color: Colors.white.withOpacity(0.35),
                                        borderRadius: BorderRadius.circular(30),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.white.withOpacity(0.25),
                                            blurRadius: 15,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      labelColor: Colors.white,
                                      unselectedLabelColor: Colors.white.withOpacity(0.85),
                                      labelStyle: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        letterSpacing: 0.5,
                                      ),
                                      tabs: const [
                                        Tab(text: 'Билеты'),
                                        Tab(text: 'История покупок'),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          const SizedBox(height: 12),

                          Expanded(
                            child: TabBarView(
                              children: [
                                upcomingTickets.isEmpty
                                    ? Center(
                                        child: Text(
                                          'Нет предстоящих билетов',
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                      )
                                    : ListView.builder(
                                        padding: EdgeInsets.only(bottom: bottomNavHeight + 24, top: 6),
                                        itemCount: upcomingTickets.length,
                                        itemBuilder: (context, index) {
                                          final ticket = upcomingTickets[index];
                                          final event = ticket['event'] ?? {};
                                          final title = event['title'] ?? 'Неизвестное событие';
                                          final venue = event['venue'] ?? event['city'] ?? '';
                                          final eventDateRaw = event['date'] ?? ticket['purchaseDate'] ?? '';
                                          final formattedConcertDate = _formatConcertDate(eventDateRaw);
                                          final seat = ticket['seatNumber'] ?? '—';
                                          final price = event['price'] ?? '-';

                                          return Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                            child: GestureDetector(
                                              onTap: () => _openPurchasedTicket(ticket),
                                              child: _TicketCard(
                                                title: title,
                                                venue: venue,
                                                date: formattedConcertDate,
                                                seat: seat,
                                                price: price,
                                              ),
                                            ),
                                          );
                                        },
                                      ),

                                historyTickets.isEmpty
                                    ? Center(
                                        child: Text(
                                          'История покупок пуста',
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                      )
                                    : ListView.builder(
                                        padding: EdgeInsets.only(bottom: bottomNavHeight + 24, top: 6),
                                        itemCount: historyTickets.length,
                                        itemBuilder: (context, index) {
                                          final ticket = historyTickets[index];
                                          final event = ticket['event'] ?? {};
                                          final title = event['title'] ?? 'Неизвестное событие';
                                          final venue = event['venue'] ?? event['city'] ?? '';
                                          final eventDateRaw = event['date'] ?? ticket['purchaseDate'] ?? '';
                                          final formattedConcertDate = _formatConcertDate(eventDateRaw);
                                          final seat = ticket['seatNumber'] ?? '—';
                                          final price = event['price'] ?? '-';
                                          final purchaseRaw = ticket['purchaseDate'] as String?;
                                          final purchaseFormatted = purchaseRaw != null ? _formatShortDate(purchaseRaw) : '';

                                          return Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                            child: GestureDetector(
                                              onTap: () => _openPurchasedTicket(ticket),
                                              child: Column(
                                                children: [
                                                  _TicketCard(
                                                    title: title,
                                                    venue: venue,
                                                    date: formattedConcertDate,
                                                    seat: seat,
                                                    price: price,
                                                  ),
                                                  if (purchaseFormatted.isNotEmpty)
                                                    Padding(
                                                      padding: const EdgeInsets.only(top: 6, left: 6, right: 6),
                                                      child: Row(
                                                        children: [
                                                          const Icon(Icons.history, size: 14, color: Colors.white54),
                                                          const SizedBox(width: 6),
                                                          Text(
                                                            'Куплено: $purchaseFormatted',
                                                            style: const TextStyle(color: Colors.white54, fontSize: 12),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ),

            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BottomNavBar(currentIndex: 2),
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final String title;
  final String venue;
  final String date;
  final String seat;
  final dynamic price;

  const _TicketCard({
    Key? key,
    required this.title,
    required this.venue,
    required this.date,
    required this.seat,
    required this.price,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      width: w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Container(width: 6, height: 120, color: const Color(0xFF10C7EF)),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                color: Colors.white.withOpacity(0.02),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${price.toString()} ₸',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                'Место $seat',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: Colors.white70),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            venue,
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.calendar_today, size: 14, color: Colors.white70),
                        const SizedBox(width: 6),
                        Text(
                          date,
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: Container(height: 1, color: Colors.white30)),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Электронный',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(width: 18, color: Colors.transparent),
          ],
        ),
      ),
    );
  }
}
