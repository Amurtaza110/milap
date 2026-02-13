import 'enums.dart';

class EventPackage {
  final String id;
  final String name; // e.g. "Early Bird", "VIP", "Couple Pass"
  final double price;
  final int? quantity;
  final bool? soldOut;
  final List<String> perks;

  EventPackage({
    required this.id,
    required this.name,
    required this.price,
    this.quantity,
    this.soldOut,
    required this.perks,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'soldOut': soldOut,
      'perks': perks,
    };
  }

  factory EventPackage.fromMap(Map<String, dynamic> map) {
    return EventPackage(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      quantity: map['quantity'],
      soldOut: map['soldOut'],
      perks: List<String>.from(map['perks'] ?? []),
    );
  }
}

class EventReview {
  final String id;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final int timestamp;

  EventReview({
    required this.id,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'timestamp': timestamp,
    };
  }

  factory EventReview.fromMap(Map<String, dynamic> map) {
    return EventReview(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      comment: map['comment'] ?? '',
      timestamp: map['timestamp'] ?? 0,
    );
  }
}

class SocialEvent {
  final String id;
  final String organizerId;
  final String organizerName;
  final String organizerAvatar;
  final double organizerRating;
  final String? organizerContact;
  final int? pastEventsCount;

  final String title;
  final EventType eventType;
  final EventEnvironment environment;
  final String location;
  final String date; // ISO date
  final String time;

  final String description;
  final List<String> rules;

  final List<String> media; // Photos/Videos

  final AccessLevel accessLevel;
  final double? goldDiscountPercent;
  final String? promoCode;
  final double? promoDiscount;
  final bool? isPromoted;
  final bool? allowGifting;

  final List<EventPackage> packages;
  final int attendeesCount;
  final String distance; // e.g. "2.5 km"

  final List<EventReview> reviews;

  SocialEvent({
    required this.id,
    required this.organizerId,
    required this.organizerName,
    required this.organizerAvatar,
    required this.organizerRating,
    this.organizerContact,
    this.pastEventsCount,
    required this.title,
    required this.eventType,
    required this.environment,
    required this.location,
    required this.date,
    required this.time,
    required this.description,
    required this.rules,
    required this.media,
    required this.accessLevel,
    this.goldDiscountPercent,
    this.promoCode,
    this.promoDiscount,
    this.isPromoted,
    this.allowGifting,
    required this.packages,
    required this.attendeesCount,
    required this.distance,
    required this.reviews,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'organizerId': organizerId,
      'organizerName': organizerName,
      'organizerAvatar': organizerAvatar,
      'organizerRating': organizerRating,
      'organizerContact': organizerContact,
      'pastEventsCount': pastEventsCount,
      'title': title,
      'eventType': eventType.index,
      'environment': environment.index,
      'location': location,
      'date': date,
      'time': time,
      'description': description,
      'rules': rules,
      'media': media,
      'accessLevel': accessLevel.index,
      'goldDiscountPercent': goldDiscountPercent,
      'promoCode': promoCode,
      'promoDiscount': promoDiscount,
      'isPromoted': isPromoted,
      'allowGifting': allowGifting,
      'packages': packages.map((x) => x.toMap()).toList(),
      'attendeesCount': attendeesCount,
      'distance': distance,
      'reviews': reviews.map((x) => x.toMap()).toList(),
    };
  }

  factory SocialEvent.fromMap(Map<String, dynamic> map) {
    return SocialEvent(
      id: map['id'] ?? '',
      organizerId: map['organizerId'] ?? '',
      organizerName: map['organizerName'] ?? '',
      organizerAvatar: map['organizerAvatar'] ?? '',
      organizerRating: (map['organizerRating'] ?? 0.0).toDouble(),
      organizerContact: map['organizerContact'],
      pastEventsCount: map['pastEventsCount'],
      title: map['title'] ?? '',
      eventType: EventType.values[map['eventType'] ?? 0],
      environment: EventEnvironment.values[map['environment'] ?? 0],
      location: map['location'] ?? '',
      date: map['date'] ?? '',
      time: map['time'] ?? '',
      description: map['description'] ?? '',
      rules: List<String>.from(map['rules'] ?? []),
      media: List<String>.from(map['media'] ?? []),
      accessLevel: AccessLevel.values[map['accessLevel'] ?? 0],
      goldDiscountPercent: (map['goldDiscountPercent']?.toDouble()),
      promoCode: map['promoCode'],
      promoDiscount: (map['promoDiscount']?.toDouble()),
      isPromoted: map['isPromoted'],
      allowGifting: map['allowGifting'],
      packages: List<EventPackage>.from(
          map['packages']?.map((x) => EventPackage.fromMap(x)) ?? []),
      attendeesCount: map['attendeesCount'] ?? 0,
      distance: map['distance'] ?? '',
      reviews: List<EventReview>.from(
          map['reviews']?.map((x) => EventReview.fromMap(x)) ?? []),
    );
  }
}
