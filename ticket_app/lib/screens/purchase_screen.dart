import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event.dart';
import '../services/api_service.dart';
import '../widgets/app_button.dart';
import '../routes.dart';

class PurchaseScreen extends StatefulWidget {
  final Event event;
  final List<String> selectedSeats;

  const PurchaseScreen({
    Key? key,
    required this.event,
    required this.selectedSeats,
  }) : super(key: key);

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  bool isLoading = false;

  Future<void> _purchaseSeats() async {
  setState(() => isLoading = true);

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('jwt_token');

  if (token == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Пожалуйста, войдите в систему')),
    );
    Navigator.pushReplacementNamed(context, '/login');
    return;
  }

  try {
    final response =
        await ApiService().bookSeats(token, widget.event.id, widget.selectedSeats);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Покупка успешна!')),
      );

      Future.delayed(const Duration(milliseconds: 600), () {
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.home,
          (route) => false, 
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ошибка: ${response.statusCode} — ${response.reasonPhrase}',
          ),
        ),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ошибка: $e')),
    );
  } finally {
    setState(() => isLoading = false);
  }
}


  String _formatFullDate(String raw) {
    try {
      final parsed = DateTime.parse(raw);
      return DateFormat('d MMM yyyy, HH:mm', 'ru').format(parsed);
    } catch (_) {
      try {
        final parsed = DateFormat('dd.MM.yyyy, HH:mm').parse(raw);
        return DateFormat('d MMM yyyy, HH:mm', 'ru').format(parsed);
      } catch (_) {
        return raw;
      }
    }
  }

@override
Widget build(BuildContext context) {
  final totalPrice = widget.event.price * widget.selectedSeats.length;
  final formattedDate = _formatFullDate(widget.event.date);

  return Scaffold(
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
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 55.0, 16.0, 16.0),
                child: SingleChildScrollView(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Column(
                        children: [
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
                                              widget.event.title,
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
                                                  formattedDate,
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
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF8F8F8),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '₸ ${widget.event.price.toStringAsFixed(0)}',
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
                                          widget.event.venue.isNotEmpty
                                              ? widget.event.venue
                                              : widget.event.city,
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
                                    children: widget.selectedSeats.map((s) {
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
                                    }).toList(),
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
                                            '${widget.selectedSeats.length} × мест',
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
                                            '₸ ${totalPrice.toStringAsFixed(0)}',
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
                                          'Проверьте данные перед покупкой. Билеты придут в ваш профиль.',
                                          style: TextStyle(
                                            color: Colors.black54.withOpacity(0.9),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 14),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          Text(
                            'Нажимая «Подтвердить покупку», вы соглашаетесь с правилами возврата и правилами площадки.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
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
      ],
    ),

    bottomNavigationBar: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: AppButton(
          text: 'Подтвердить покупку',
          isLoading: isLoading,
          onPressed: isLoading ? null : _purchaseSeats,
        ),
      ),
    ),
  );
}
}