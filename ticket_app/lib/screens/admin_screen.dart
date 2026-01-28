import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/event.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _cityController = TextEditingController();
  final _venueController = TextEditingController();
  final _rowsController = TextEditingController();
  final _colsController = TextEditingController();

  DateTime? _selectedDateTime;
  String? _token;
  List<Event> _events = [];

  @override
  void initState() {
    super.initState();
    _loadTokenAndEvents();
  }

  Future<void> _loadTokenAndEvents() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('jwt_token');
    if (_token != null) {
      final events = await _api.fetchAdminEvents(_token!);
      setState(() => _events = events);
    }
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Colors.deepPurpleAccent,
            surface: Colors.black,
          ),
        ),
        child: child!,
      ),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 18, minute: 0),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Colors.deepPurpleAccent,
          ),
        ),
        child: child!,
      ),
    );
    if (time == null) return;

    setState(() {
      _selectedDateTime =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _addEvent() async {
    if (!_formKey.currentState!.validate() || _token == null) return;
    if (_selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите дату и время')),
      );
      return;
    }

    final success = await _api.createEvent(_token!, {
      'title': _titleController.text.trim(),
      'description': _descController.text.trim(),
      'date': DateFormat("yyyy-MM-dd'T'HH:mm").format(_selectedDateTime!),
      'price': double.tryParse(_priceController.text) ?? 0.0,
      'city': _cityController.text.trim(),
      'venue': _venueController.text.trim(),
      'rows': int.tryParse(_rowsController.text) ?? 0,
      'cols': int.tryParse(_colsController.text) ?? 0,
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Мероприятие добавлено (зал сгенерирован)')),
      );
      _formKey.currentState!.reset();
      _selectedDateTime = null;
      _loadTokenAndEvents();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка добавления')),
      );
    }
  }

  Future<void> _deleteEvent(int id) async {
    if (_token == null) return;
    final success = await _api.deleteEvent(_token!, id);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Удалено')),
      );
      _loadTokenAndEvents();
    }
  }

  void _showEditDialog(Event event) {
    final titleController = TextEditingController(text: event.title);
    final descController = TextEditingController(text: event.description);
    final priceController = TextEditingController(text: event.price.toString());
    final cityController = TextEditingController(text: event.city);
    final venueController = TextEditingController(text: event.venue);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Редактировать событие',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputStyle('Название'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputStyle('Описание'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: priceController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputStyle('Цена'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: cityController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputStyle('Город'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: venueController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputStyle('Место проведения'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_token == null) return;
                final success = await _api.updateEvent(_token!, event.id, {
                  'title': titleController.text.trim(),
                  'description': descController.text.trim(),
                  'price': double.tryParse(priceController.text) ?? 0,
                  'city': cityController.text.trim(),
                  'venue': venueController.text.trim(),
                });

                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Событие обновлено')),
                  );
                  _loadTokenAndEvents();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ошибка при обновлении')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Сохранить', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  InputDecoration _inputStyle(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.grey[850],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.deepPurpleAccent, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  void _safePop() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white),
                    onPressed: _safePop,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Админ-панель',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: _inputStyle('Название'),
                      validator: (v) => v!.isEmpty ? 'Введите название' : null,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _descController,
                      decoration: _inputStyle('Описание мероприятия'),
                      validator: (v) => v!.isEmpty ? 'Введите описание' : null,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: _inputStyle('Цена (тенге)'),
                      validator: (v) => v!.isEmpty ? 'Введите цену' : null,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _cityController,
                      decoration: _inputStyle('Город'),
                      validator: (v) => v!.isEmpty ? 'Введите город' : null,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _venueController,
                      decoration: _inputStyle('Место проведения'),
                      validator: (v) => v!.isEmpty ? 'Введите место' : null,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _rowsController,
                      keyboardType: TextInputType.number,
                      decoration: _inputStyle('Количество рядов'),
                      validator: (v) =>
                          v!.isEmpty ? 'Введите количество рядов' : null,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _colsController,
                      keyboardType: TextInputType.number,
                      decoration: _inputStyle('Количество мест в ряду'),
                      validator: (v) =>
                          v!.isEmpty ? 'Введите количество мест' : null,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedDateTime == null
                                ? 'Дата не выбрана'
                                : DateFormat('dd.MM.yyyy HH:mm')
                                    .format(_selectedDateTime!),
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                        TextButton(
                          onPressed: _pickDateTime,
                          child: const Text(
                            'Выбрать дату',
                            style: TextStyle(color: Colors.deepPurpleAccent),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _addEvent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'Добавить событие',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              const Divider(color: Colors.white24),

              _events.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Center(
                        child: Text(
                          'Нет событий',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                    )
                  : ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: _events.length,
                      itemBuilder: (context, i) {
                        final e = _events[i];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            title: Text(
                              e.title,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              '${e.city}, ${e.date}\n${e.venue}\n${e.price.toStringAsFixed(0)} ₸',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.amberAccent),
                                  onPressed: () => _showEditDialog(e),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.redAccent),
                                  onPressed: () => _deleteEvent(e.id),
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
      ),
    );
  }
}
