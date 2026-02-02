import 'package:intl/intl.dart';

class Event {
  final int id;
  final String title;
  final String description;
  final String date; 
  final double price;
  final String city;
  final String venue;
  final String imageKey;
  final String bannerImagePath;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.price,
    required this.city,
    required this.venue,
    required this.imageKey,
    required this.bannerImagePath,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    final key = (json['imageKey'] ?? '').toString().toLowerCase();
    final imagePath = key.isNotEmpty
        ? 'assets/images/${key}_banner.jpg'
        : 'assets/images/default_event.jpg';

    String formattedDate = '';
    if (json['date'] != null && json['date'].toString().isNotEmpty) {
      try {
        final parsed = DateTime.parse(json['date'].toString());
        formattedDate = DateFormat('dd.MM.yyyy, HH:mm').format(parsed);
      } catch (_) {
        formattedDate = json['date'].toString();
      }
    }

    return Event(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: formattedDate, 
      price: (json['price'] ?? 0).toDouble(),
      city: json['city'] ?? '',
      venue: json['venue'] ?? '',
      imageKey: key,
      bannerImagePath: imagePath,
    );
  }
}