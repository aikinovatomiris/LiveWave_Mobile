import 'package:flutter/material.dart';
import '../models/event.dart';
import '../routes.dart';
import 'event_card.dart';

class EventCarousel extends StatefulWidget {
  final List<Event> events;

  const EventCarousel({Key? key, required this.events}) : super(key: key);

  @override
  State<EventCarousel> createState() => _EventCarouselState();
}

class _EventCarouselState extends State<EventCarousel> {
  late final PageController _pageController;
  double _currentPage = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.78)
      ..addListener(() {
        setState(() {
          _currentPage = _pageController.page ?? 0.0;
        });
      });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 380,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.events.length,
        physics: const PageScrollPhysics(),
        itemBuilder: (context, index) {
          final event = widget.events[index];
          final double distance = (_currentPage - index).abs();
          final double scale = 1 - (distance * 0.15).clamp(0.0, 0.15);
          final double translateY = 30 * distance;

          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              return EventCardSlider(
                event: event,
                scale: scale,
                translateY: translateY,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    Routes.eventDetail,
                    arguments: event,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
