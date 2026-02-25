import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/api_service.dart';
import '../routes.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/event_card.dart';
import '../widgets/city_selector.dart';
import '../widgets/event_search_bar.dart';
import 'package:intl/intl.dart';
import '../services/graphql_api.dart';

class AfishaScreen extends StatefulWidget {
  const AfishaScreen({Key? key}) : super(key: key);

  @override
  State<AfishaScreen> createState() => _AfishaScreenState();
}

class _AfishaScreenState extends State<AfishaScreen> {
  late Future<List<Event>> _futureEvents;
  String _selectedCity = 'Алматы';
  List<Event> _allEvents = [];
  String _currentFilter = 'none'; 

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents() async {
    // ignore: unused_local_variable
    final api = ApiService();

    setState(() {
      _futureEvents = GraphQLApi.instance.fetchEvents(city: _selectedCity);
    });

    final all = await GraphQLApi.instance.fetchEvents();
    setState(() {
      _allEvents = all;
    });
  }

  void _onCityChanged(String city) {
    setState(() {
      _selectedCity = city;
      _futureEvents = GraphQLApi.instance.fetchEvents(city: _selectedCity);
    });
  }

  void _applyFilter(List<Event> events) {
    if (_currentFilter == 'alphabetical') {
      events.sort((a, b) => a.title.compareTo(b.title));
    } else if (_currentFilter == 'date') {
      events.sort((a, b) {
        DateTime? dateA = _parseDate(a.date);
        DateTime? dateB = _parseDate(b.date);
        if (dateA == null || dateB == null) return 0;
        return dateA.compareTo(dateB);
      });
    }
  }

  DateTime? _parseDate(String input) {
    try {
      return DateFormat("yyyy-MM-dd'T'HH:mm:ss").parse(input);
    } catch (_) {
      try {
        return DateFormat('dd.MM.yyyy, HH:mm').parse(input);
      } catch (_) {
        try {
          return DateFormat('dd.MM.yyyy').parse(input);
        } catch (_) {
          return null;
        }
      }
    }
  }

  void _openFilterMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black.withOpacity(0.9),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Сортировать по:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.sort_by_alpha, color: Colors.white),
                title: const Text('Алфавиту (A–Z)',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  setState(() => _currentFilter = 'alphabetical');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.access_time_rounded, color: Colors.white),
                title: const Text('Дате (раньше сначала)',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  setState(() => _currentFilter = 'date');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.clear, color: Colors.white),
                title:
                    const Text('Без сортировки', style: TextStyle(color: Colors.white)),
                onTap: () {
                  setState(() => _currentFilter = 'none');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.JPEG'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Афиша',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      GestureDetector(
                        onTap: _openFilterMenu,
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                              )
                            ],
                          ),
                          child: const Icon(
                            Icons.filter_list_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: _allEvents.isNotEmpty
                            ? EventSearchBar(events: _allEvents)
                            : const SizedBox(),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        flex: 1,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: CitySelector(onCityChanged: _onCityChanged),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Expanded(
                    child: FutureBuilder<List<Event>>(
                      future: _futureEvents,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Ошибка: ${snapshot.error}',
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(
                            child: Text(
                              'Нет мероприятий в $_selectedCity',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          );
                        }

                        final events = [...snapshot.data!];
                        _applyFilter(events);

                        return GridView.builder(
                          padding: const EdgeInsets.only(top: 4, bottom: 140),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.65,
                          ),
                          itemCount: events.length,
                          itemBuilder: (context, index) {
                            final event = events[index];
                            return EventCardGrid(
                              event: event,
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
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: const BottomNavBar(currentIndex: 1),
          ),
        ],
      ),
    );
  }
}
