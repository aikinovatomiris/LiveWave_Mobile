import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/event.dart';
import '../routes.dart';

class EventSearchBar extends StatefulWidget {
  final List<Event> events;

  const EventSearchBar({Key? key, required this.events}) : super(key: key);

  @override
  State<EventSearchBar> createState() => _EventSearchBarState();
}

class _EventSearchBarState extends State<EventSearchBar> {
  final TextEditingController _controller = TextEditingController();
  List<Event> _filteredEvents = [];
  bool _isSearching = false;

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _isSearching = false;
        _filteredEvents = [];
      } else {
        _isSearching = true;
        _filteredEvents = widget.events
            .where((event) =>
                event.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _onEventTap(Event event) {
    FocusScope.of(context).unfocus();
    Navigator.pushNamed(context, Routes.eventDetail, arguments: event);
    setState(() {
      _isSearching = false;
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final availableHeight =
        MediaQuery.of(context).size.height - keyboardHeight - 180;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _controller,
                onChanged: _onSearchChanged,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
                cursorColor: Colors.white38,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.white,
                    size: 24,
                  ),
                  hintText: 'Поиск событий...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                ),
              ),
            ),
          ),
        ),

        if (_isSearching && _filteredEvents.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            constraints: BoxConstraints(
              maxHeight: availableHeight < 300 ? availableHeight : 300,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: _filteredEvents.length,
                  itemBuilder: (context, index) {
                    final event = _filteredEvents[index];
                    return ListTile(
                      title: Text(
                        event.title,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () => _onEventTap(event),
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }
}
