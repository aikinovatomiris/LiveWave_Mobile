import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event.dart';
import '../services/api_service.dart';
import '../routes.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/event_carousel.dart';
import '../widgets/event_card.dart';
import '../widgets/city_selector.dart';
import '../widgets/event_search_bar.dart';
import '../services/graphql_api.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Event>> _futureEventsByCity;
  late Future<List<Event>> _allEventsFuture;

  String _selectedCity = 'Алматы';
  List<Event> _allEvents = [];

  String _userName = 'Гость';
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadEvents();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? 'Гость';
      _isLoadingUser = false;
    });
  }

  void _loadEvents() async {
    // ignore: unused_local_variable
    final api = ApiService();

    setState(() {
      _futureEventsByCity = GraphQLApi.instance.fetchEvents(city: _selectedCity);
      _allEventsFuture = GraphQLApi.instance.fetchEvents();
    });

    final all = await _allEventsFuture;
    setState(() {
      _allEvents = all;
    });
  }

  void _onCityChanged(String city) {
    setState(() {
      _selectedCity = city;
      _futureEventsByCity = GraphQLApi.instance.fetchEvents(city: _selectedCity);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.JPEG'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 0, 
                right: 0, 
                bottom: 12,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Добро пожаловать,',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isLoadingUser ? 'Загрузка...' : _userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                          shadows: [
                            Shadow(
                              offset: Offset(1, 1),
                              blurRadius: 3,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
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
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FutureBuilder<List<Event>>(
                  future: _futureEventsByCity,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Ошибка: ${snapshot.error}',
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                          'Нет мероприятий в $_selectedCity',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      );
                    }

                    final events = snapshot.data!;
                    final mostAwaited =
                        events.length >= 3 ? events.sublist(0, 3) : events;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Популярное',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          EventCarousel(events: mostAwaited),
                          const SizedBox(height: 24),
                          const Text(
                            'Интересное',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
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
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  Routes.eventDetail,
                                  arguments: event,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }
}
