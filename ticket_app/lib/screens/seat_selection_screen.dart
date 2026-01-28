import 'package:flutter/material.dart';
import '../models/event.dart';
import '../models/seat.dart';
import '../services/api_service.dart';
import '../widgets/app_button.dart';

class SeatSelectionScreen extends StatefulWidget {
  final Event event;

  const SeatSelectionScreen({Key? key, required this.event}) : super(key: key);

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  late Future<List<Seat>> _futureSeats;
  final Set<String> selectedSeatNumbers = {};

  @override
  void initState() {
    super.initState();
    _futureSeats = ApiService().getSeatsByEvent(widget.event.id);
  }

  void toggleSeat(Seat seat) {
    if (seat.isBooked) return; 
    setState(() {
      if (selectedSeatNumbers.contains(seat.seatNumber)) {
        selectedSeatNumbers.remove(seat.seatNumber);
      } else {
        selectedSeatNumbers.add(seat.seatNumber);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 50.0, 16.0, 16.0), 
              child: FutureBuilder<List<Seat>>(
                future: _futureSeats,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
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

                  final seats = snapshot.data!;
                  if (seats.isEmpty) {
                    return const Center(
                      child: Text(
                        'Нет доступных мест',
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  final maxCol =
                      seats.map((s) => s.colNum).reduce((a, b) => a > b ? a : b);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8), 
                      Text(
                        widget.event.title,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 18), 
                      Text(
                        '₸ ${widget.event.price.toStringAsFixed(0)} за место',
                        style: const TextStyle(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20), 

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: const [
                            _LegendItem(color: Colors.redAccent, label: 'Свободно'),
                            _LegendItem(color: Colors.green, label: 'Выбрано'),
                            _LegendItem(color: Colors.grey, label: 'Выкуплено'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28), 

                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: maxCol,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: seats.length,
                          itemBuilder: (context, index) {
                            final seat = seats[index];
                            final isSelected = selectedSeatNumbers.contains(seat.seatNumber);
                            final isBooked = seat.isBooked;

                            Color seatColor;
                            if (isBooked) {
                              seatColor = Colors.grey[600]!;
                            } else if (isSelected) {
                              seatColor = Colors.green;
                            } else {
                              seatColor = Colors.redAccent;
                            }

                            return GestureDetector(
                              onTap: () => toggleSeat(seat),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: seatColor,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    if (!isBooked)
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.4),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                  ],
                                  border: Border.all(
                                    color: isSelected ? Colors.white : Colors.transparent,
                                    width: 1.5,
                                  ),
                                ),
                                child: const SizedBox.expand(),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 12),
                      AppButton(
                        text: selectedSeatNumbers.isEmpty ? 'Выберите места' : 'Купить (${selectedSeatNumbers.length})',
                        isDisabled: selectedSeatNumbers.isEmpty,
                        onPressed: selectedSeatNumbers.isEmpty ? null : () {
                          Navigator.pushNamed(context, '/purchase', arguments: {
                            'event': widget.event,
                            'selectedSeats': selectedSeatNumbers.toList(),
                          });
                        },
                      ),
                    ],
                  );
                },
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
     );
   }
 }

 class _LegendItem extends StatelessWidget {
   final Color color;
   final String label;

   const _LegendItem({required this.color, required this.label});

   @override
   Widget build(BuildContext context) {
     return Row(
       children: [
         Container(
           width: 18,
           height: 18,
           decoration: BoxDecoration(
             color: color,
             borderRadius: BorderRadius.circular(4),
           ),
         ),
         const SizedBox(width: 6),
         Text(
           label,
           style: const TextStyle(color: Colors.white70, fontSize: 12),
         ),
       ],
     );
   }
 }
