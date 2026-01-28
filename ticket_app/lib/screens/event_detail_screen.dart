import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';
import '../models/event.dart';
import '../routes.dart';
import '../widgets/app_button.dart';


class EventDetailScreen extends StatelessWidget {
  final Event event;

  const EventDetailScreen({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String formattedDate;
    try {
      final parsedDate = DateTime.parse(event.date);
      formattedDate = DateFormat('d MMMM y, HH:mm', 'ru').format(parsedDate);
    } catch (_) {
      formattedDate = event.date; 
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final desiredHeight = math.min(screenHeight * 0.52, screenWidth * (4 / 3));
    final fadeStart = (desiredHeight / screenHeight).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Colors.black, 
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: screenWidth,
                height: desiredHeight,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(0),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        event.bannerImagePath.isNotEmpty
                            ? event.bannerImagePath
                            : 'assets/images/default_banner.jpg',
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.95),
                            ],
                            stops: const [0.55, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black,
                  ],
                  stops: [fadeStart, 1.0],
                ),
              ),
            ),
          ),

          DraggableScrollableSheet(
            initialChildSize: 0.55,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 0, 0, 0),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 60,
                          height: 5,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white70,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${event.price.toStringAsFixed(0)} ₸ / 1 человек',
                        style: const TextStyle(
                            fontSize: 16, color: Colors.white70),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              color: Colors.white70, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            formattedDate,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              color: Colors.white70, size: 20),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              event.venue.isNotEmpty
                                  ? event.venue
                                  : 'Место проведения уточняется',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Описание:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        event.description.isNotEmpty
                            ? event.description
                            : 'Описание мероприятия будет добавлено позже.',
                        style:
                            const TextStyle(color: Colors.white70, height: 1.4),
                      ),
                      const SizedBox(height: 40),
                      AppButton(
                        text: 'Купить билеты',
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            Routes.seatSelection,
                            arguments: event,
                          );
                        },
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              );
            },
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
    );
  }
}
