import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';

String formatShortDate(String fullDate) {
  DateTime? parsed;
  final possibleFormats = [
    DateFormat("yyyy-MM-dd'T'HH:mm:ss"),
    DateFormat('dd.MM.yyyy, HH:mm'),
    DateFormat('dd.MM.yyyy'),
  ];

  for (final format in possibleFormats) {
    try {
      parsed = format.parse(fullDate);
      break;
    } catch (_) {}
  }

  parsed ??= _tryParseIso(fullDate);
  if (parsed == null) return fullDate;

  return DateFormat('dd.MM').format(parsed);
}

DateTime? _tryParseIso(String input) {
  try {
    return DateTime.parse(input);
  } catch (_) {
    return null;
  }
}

class EventCardSlider extends StatelessWidget {
  final Event event;
  final double scale;
  final double translateY;
  final VoidCallback onTap;

  const EventCardSlider({
    Key? key,
    required this.event,
    required this.scale,
    required this.translateY,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final shortDate = formatShortDate(event.date);

    return Transform.translate(
      offset: Offset(0, translateY),
      child: Transform.scale(
        scale: scale,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 6), // 🔹 уменьшен отступ
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.45),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    event.bannerImagePath.isNotEmpty
                        ? event.bannerImagePath
                        : 'assets/images/default_banner.jpg',
                    height: double.infinity,
                    width: double.infinity,
                    fit: BoxFit.cover, 
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.85),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          event.title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.calendar_today_rounded,
                                color: Colors.white70, size: 16),
                            const SizedBox(width: 4),
                            Text(shortDate,
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 14)),
                            const SizedBox(width: 12),
                            const Icon(Icons.location_on,
                                color: Colors.white70, size: 16),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                event.venue,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class EventCardGrid extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;

  const EventCardGrid({
    Key? key,
    required this.event,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final shortDate = formatShortDate(event.date);

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Image.asset(
              event.bannerImagePath.isNotEmpty
                  ? event.bannerImagePath
                  : 'assets/images/default_banner.jpg',
              height: double.infinity,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.85)],
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          shortDate,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            event.venue,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
