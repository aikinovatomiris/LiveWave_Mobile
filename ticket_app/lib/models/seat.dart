class Seat {
  final int id;
  final String seatNumber;
  final int rowNum;
  final int colNum;
  final int? eventId; 
  final bool isBooked; 

  Seat({
    required this.id,
    required this.seatNumber,
    required this.rowNum,
    required this.colNum,
    this.eventId,
    required this.isBooked,
  });

  factory Seat.fromJson(Map<String, dynamic> json) {
    return Seat(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      seatNumber: json['seatNumber'] ?? json['seat_number'] ?? '',
      rowNum: json['rowNum'] ?? json['row_num'] ?? 0,
      colNum: json['colNum'] ?? json['col_num'] ?? 0,
      eventId: json['eventId'] ?? json['event_id'],
      isBooked: json['booked'] == true || json['isBooked'] == true,
    );
  }
}
