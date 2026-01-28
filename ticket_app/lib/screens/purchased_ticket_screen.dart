import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PurchasedTicketScreen extends StatelessWidget {
  final Map<String, dynamic> ticket;

  const PurchasedTicketScreen({Key? key, required this.ticket}) : super(key: key);

String _formatFullDate(String raw) {
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


  @override
  Widget build(BuildContext context) {
    final event = ticket['event'] ?? {};
    final title = event['title'] ?? 'Неизвестное событие';
    final venue = event['venue'] ?? event['city'] ?? '';
    final dateRaw = ticket['purchaseDate'] ?? event['date'] ?? '';
    final date = _formatFullDate(dateRaw);
    final selectedSeats = <String>[];
    final seat = ticket['seatNumber'];
    if (seat != null) selectedSeats.add(seat.toString());
    final price = event['price'] ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 10),

                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          style: const TextStyle(
                                            color: Colors.black87,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            const Icon(Icons.calendar_today, size: 14, color: Colors.black54),
                                            const SizedBox(width: 6),
                                            Text(
                                              date,
                                              style: const TextStyle(
                                                color: Colors.black54,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8F8F8),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '₸ ${price.toString()}',
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 14),
                              const Divider(height: 1, color: Color(0xFFE6E6E6)),
                              const SizedBox(height: 12),

                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 16, color: Colors.black54),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      venue,
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 14),

                              const Text(
                                'Выбранные места',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),

                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: selectedSeats.isNotEmpty
                                    ? selectedSeats.map((s) {
                                        return Chip(
                                          label: Text(
                                            s,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          backgroundColor: const Color(0xFFF3F3F3),
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        );
                                      }).toList()
                                    : [
                                        Chip(
                                          label: const Text('—'),
                                          backgroundColor: const Color(0xFFF3F3F3),
                                        )
                                      ],
                              ),

                              const SizedBox(height: 16),
                              const Divider(height: 1, color: Color(0xFFE6E6E6)),
                              const SizedBox(height: 12),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${selectedSeats.length} × мест',
                                        style: const TextStyle(
                                          color: Colors.black54,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      const Text(
                                        'Сервисный сбор',
                                        style: TextStyle(color: Colors.black54, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '₸ ${ (price * (selectedSeats.isEmpty ? 1 : selectedSeats.length)).toString() }',
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      const Text(
                                        '₸ 0',
                                        style: TextStyle(color: Colors.black54, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              const SizedBox(height: 18),

                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Это подтверждённый билет. Показав штрих-код на входе, вы пройдёте на мероприятие.',
                                      style: TextStyle(color: Colors.black54.withOpacity(0.95), fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 14),

                
                              Center(
                                child: Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8F8F8),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Image.asset(
                                    'assets/images/qr_code.png',
                                    width: double.infinity,      
                                    fit: BoxFit.fitWidth,        
                                  ),
                                ),
                              ),


                              const SizedBox(height: 6),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      Text(
                        'Пожалуйста, имейте этот билет при себе. Организаторы могут запросить удостоверение личности.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.5),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
