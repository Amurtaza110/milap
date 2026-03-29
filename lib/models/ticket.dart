enum TicketStatus { confirmed, used, cancelled }

class Ticket {
  final String id;
  final String userId;
  final String eventId;
  final String eventTitle;
  final String eventDate;
  final String eventLocation;
  final String packageId;
  final String packageName;
  final double price;
  final TicketStatus status;
  final int timestamp;
  final String qrCode;

  Ticket({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.eventTitle,
    required this.eventDate,
    required this.eventLocation,
    required this.packageId,
    required this.packageName,
    required this.price,
    this.status = TicketStatus.confirmed,
    required this.timestamp,
    required this.qrCode,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'eventId': eventId,
      'eventTitle': eventTitle,
      'eventDate': eventDate,
      'eventLocation': eventLocation,
      'packageId': packageId,
      'packageName': packageName,
      'price': price,
      'status': status.name,
      'timestamp': timestamp,
      'qrCode': qrCode,
    };
  }

  factory Ticket.fromMap(Map<String, dynamic> map) {
    return Ticket(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      eventId: map['eventId'] ?? '',
      eventTitle: map['eventTitle'] ?? '',
      eventDate: map['eventDate'] ?? '',
      eventLocation: map['eventLocation'] ?? '',
      packageId: map['packageId'] ?? '',
      packageName: map['packageName'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      status: TicketStatus.values.firstWhere((e) => e.name == map['status'], orElse: () => TicketStatus.confirmed),
      timestamp: map['timestamp'] ?? 0,
      qrCode: map['qrCode'] ?? '',
    );
  }

  Ticket copyWith({
    String? id,
    String? userId,
    String? eventId,
    String? eventTitle,
    String? eventDate,
    String? eventLocation,
    String? packageId,
    String? packageName,
    double? price,
    TicketStatus? status,
    int? timestamp,
    String? qrCode,
  }) {
    return Ticket(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      eventId: eventId ?? this.eventId,
      eventTitle: eventTitle ?? this.eventTitle,
      eventDate: eventDate ?? this.eventDate,
      eventLocation: eventLocation ?? this.eventLocation,
      packageId: packageId ?? this.packageId,
      packageName: packageName ?? this.packageName,
      price: price ?? this.price,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      qrCode: qrCode ?? this.qrCode,
    );
  }
}
