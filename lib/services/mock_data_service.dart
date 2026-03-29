import 'package:milap/models/notification.dart';
import 'package:milap/models/user_profile.dart';

class MockDataService {
  static final List<AppNotification> mockNotifications = [
    AppNotification(
      id: '1',
      type: NotificationType.match,
      title: 'New Match!',
      message: 'You and Sarah have matched.',
      imageUrl: 'https://randomuser.me/api/portraits/women/68.jpg',
      timestamp: DateTime.now().millisecondsSinceEpoch,
    ),
    AppNotification(
      id: '2',
      type: NotificationType.message,
      title: 'New Message from John',
      message: 'Hey, how are you?',
      imageUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
      timestamp: DateTime.now().millisecondsSinceEpoch,
    ),
    AppNotification(
      id: '3',
      type: NotificationType.alert,
      title: 'Profile Verification',
      message: 'Your profile has been successfully verified!',
      timestamp: DateTime.now().millisecondsSinceEpoch,
    ),
  ];

  static final List<UserProfile> mockProfiles = [
    UserProfile(
      id: '1',
      name: 'Sarah',
      age: 25,
      gender: Gender.Female,
      location: 'New York',
      bio: 'Love to travel and try new things.',
      interests: ['travel', 'food', 'movies'],
      photos: ['https://randomuser.me/api/portraits/women/68.jpg'],
      isOnline: true,
      rating: 4.5,
      reviewsCount: 10,
      isCouple: false,
      type: UserType.Individual,
      lookingForDates: true,
      isDeactivated: false,
      heartsBalance: 100,
      lastHeartRefill: DateTime.now().toIso8601String(), dob: '',
    ),
    UserProfile(
      id: '2',
      name: 'John',
      age: 28,
      gender: Gender.Male,
      location: 'San Francisco',
      bio: 'Software engineer and avid hiker.',
      interests: ['hiking', 'coding', 'music'],
      photos: ['https://randomuser.me/api/portraits/men/32.jpg'],
      isOnline: false,
      rating: 4.8,
      reviewsCount: 15,
      isCouple: false,
      type: UserType.Individual,
      lookingForDates: true,
      isDeactivated: false,
      heartsBalance: 100,
      lastHeartRefill: DateTime.now().toIso8601String(), dob: '',
    ),
  ];
}
