import '../models/user_profile.dart';
import '../models/social_event.dart';
import '../models/status.dart';
import '../models/chat.dart';
import '../models/enums.dart';

class MockDataService {
  static const List<String> pakistaniCities = [
    'Lahore',
    'Karachi',
    'Islamabad',
    'Rawalpindi',
    'Faisalabad',
    'Multan',
    'Hyderabad',
    'Gujranwala',
    'Peshawar',
    'Quetta',
    'Sialkot',
    'Abbottabad',
    'Bahawalpur',
    'Sargodha',
    'Sukkur',
    'Larkana',
    'Sheikhupura',
    'Jhelum',
    'Rahim Yar Khan',
    'Gwadar'
  ];

  static const List<String> eventCategories = [
    'Nightlife',
    'Dining',
    'Concert',
    'Swimming',
    'Movie Night',
    'Adventure',
    'Workshop',
    'Chill',
    'Gaming',
    'Fitness'
  ];

  static List<UserProfile> get mockProfiles => [
        UserProfile(
          id: '1',
          name: 'Ayesha Khan',
          age: 24,
          gender: Gender.Female,
          dob: '2000-05-15',
          location: 'Lahore',
          bio:
              'Architecture student, coffee lover, and looking for someone who appreciates Sufi music and good food.',
          interests: ['Music', 'Art', 'Travel', 'Foodie'],
          photos: [
            'https://picsum.photos/id/64/800/1200',
            'https://picsum.photos/id/65/800/1200'
          ],
          isOnline: true,
          rating: 4.8,
          reviewsCount: 3,
          isCouple: false,
          type: UserType.Individual,
          isVerified: true,
          reviews: [
            UserReview(
                id: 'r1',
                reviewerName: 'Umar',
                rating: 5,
                comment: 'Very respectful and a great conversationalist!',
                date: DateTime.now()
                    .subtract(Duration(days: 5))
                    .millisecondsSinceEpoch),
            UserReview(
                id: 'r2',
                reviewerName: 'Sara',
                rating: 4,
                comment:
                    'Amazing personality, though she was a bit late for coffee.',
                date: DateTime.now()
                    .subtract(Duration(days: 12))
                    .millisecondsSinceEpoch),
            UserReview(
                id: 'r3',
                reviewerName: 'Ali',
                rating: 5,
                comment: 'Completely authentic and matches her profile.',
                date: DateTime.now()
                    .subtract(Duration(days: 20))
                    .millisecondsSinceEpoch),
          ],
          lookingForDates: true,
          isDeactivated: false,
          heartsBalance: 10,
          lastHeartRefill: '2023-10-27',
        ),
        UserProfile(
          id: '2',
          name: 'Zain & Sarah',
          age: 28,
          partner2Age: 26,
          gender: Gender.Male,
          partner2Gender: Gender.Female,
          dob: '1995-10-20',
          partner2Dob: '1997-12-15',
          location: 'Islamabad',
          bio:
              'Adventurous couple exploring the northern areas. Looking for like-minded friends or temporary partners for group trips.',
          interests: ['Hiking', 'Netflix', 'Photography'],
          photos: [
            'https://picsum.photos/id/177/800/1200',
            'https://picsum.photos/id/158/800/1200'
          ],
          isOnline: true,
          rating: 4.9,
          reviewsCount: 2,
          isCouple: true,
          type: UserType.Couple,
          isVerified: true,
          reviews: [
            UserReview(
                id: 'r4',
                reviewerName: 'Bilal',
                rating: 5,
                comment: 'Great couple to hang out with. Very welcoming!',
                date: DateTime.now()
                    .subtract(Duration(days: 2))
                    .millisecondsSinceEpoch),
            UserReview(
                id: 'r5',
                reviewerName: 'Mona',
                rating: 5,
                comment: 'Had a wonderful group trip. Highly reliable.',
                date: DateTime.now()
                    .subtract(Duration(days: 15))
                    .millisecondsSinceEpoch),
          ],
          lookingForDates: true,
          isDeactivated: false,
          heartsBalance: 10,
          lastHeartRefill: '2023-10-27',
        ),
        UserProfile(
          id: '3',
          name: 'Hamza Malik',
          age: 27,
          gender: Gender.Male,
          dob: '1996-08-10',
          location: 'Karachi',
          bio:
              'Software engineer by day, poet by night. Let’s talk about tech and Ghalib over chai.',
          interests: ['Coding', 'Poetry', 'Fitness'],
          photos: ['https://picsum.photos/id/91/800/1200'],
          isOnline: false,
          rating: 4.5,
          reviewsCount: 1,
          isCouple: false,
          type: UserType.Individual,
          isVerified: false,
          reviews: [
            UserReview(
                id: 'r6',
                reviewerName: 'Kashif',
                rating: 4,
                comment: 'Knowledgeable guy. Real poet indeed.',
                date: DateTime.now()
                    .subtract(Duration(days: 30))
                    .millisecondsSinceEpoch),
          ],
          lookingForDates: true,
          isDeactivated: false,
          heartsBalance: 10,
          lastHeartRefill: '2023-10-27',
        ),
      ];

  static List<Status> get mockStatuses => [
        Status(
          id: 's1',
          userId: '1',
          userName: 'Ayesha',
          userAvatar: 'https://picsum.photos/id/64/100/100',
          mediaUrl: 'https://picsum.photos/id/10/800/1200',
          type: 'image',
          timestamp: DateTime.now()
              .subtract(Duration(hours: 1))
              .millisecondsSinceEpoch,
          isSeen: false,
          caption: 'Lovely weather in Lahore today! 🌧️',
        ),
      ];

  static List<Chat> get mockChats => [
        Chat(
          id: 'c1',
          participants: [mockProfiles[1]],
          lastMessage: 'Searching for soul connections...',
          unreadCount: 2,
          autoDeleteHours: 24,
        ),
        Chat(
          id: 'c2',
          participants: [mockProfiles[2]],
          lastMessage: 'Hey! Hope you are doing well.',
          unreadCount: 0,
          autoDeleteHours: 24,
        ),
      ];

  static List<SocialEvent> get mockEvents => [
        SocialEvent(
          id: 'e1',
          organizerId: '101',
          organizerName: 'Lahore Social Club',
          organizerAvatar: 'https://picsum.photos/id/102/100/100',
          organizerRating: 4.9,
          organizerContact: '+92 300 1234567',
          pastEventsCount: 24,
          title: 'Qawwali Night & Bonfire',
          eventType: EventType.Chill,
          environment: EventEnvironment.Outdoor,
          location: 'DHA Phase 6, Lahore',
          date: '2023-11-15',
          time: '08:00 PM',
          description:
              'Experience a soulful evening with live Qawwali performance under the stars. Traditional tea and snacks included.',
          rules: [
            'No alcohol',
            'Couples & Families only',
            'Dress code: Eastern'
          ],
          media: [
            'https://picsum.photos/id/145/800/600',
            'https://picsum.photos/id/149/800/600'
          ],
          accessLevel: AccessLevel.Public,
          allowGifting: true,
          packages: [
            EventPackage(
                id: 'p1',
                name: 'General Admission',
                price: 1500,
                perks: ['Entry', 'Chai'],
                quantity: 100,
                soldOut: false),
            EventPackage(
                id: 'p2',
                name: 'VIP Lounge',
                price: 3500,
                perks: ['Front Row', 'Dinner Buffet', 'Meet the Artist'],
                quantity: 20,
                soldOut: false),
          ],
          attendeesCount: 124,
          distance: '3.2 km',
          reviews: [
            EventReview(
                id: 'er1',
                userId: 'u1',
                userName: 'Ali K.',
                rating: 5,
                comment: 'Best Qawwali setup in Lahore!',
                timestamp: DateTime.now()
                    .subtract(Duration(days: 30))
                    .millisecondsSinceEpoch),
            EventReview(
                id: 'er2',
                userId: 'u2',
                userName: 'Sana M.',
                rating: 4,
                comment: 'Great vibes but parking was tough.',
                timestamp: DateTime.now()
                    .subtract(Duration(days: 35))
                    .millisecondsSinceEpoch),
          ],
        ),
        SocialEvent(
          id: 'e2',
          organizerId: '102',
          organizerName: 'Milap Gold Exclusive',
          organizerAvatar: 'https://picsum.photos/id/103/100/100',
          organizerRating: 5.0,
          organizerContact: 'Premium Support Line',
          pastEventsCount: 12,
          title: 'Neon Rooftop Party',
          eventType: EventType.Party,
          environment: EventEnvironment.Indoor,
          location: 'Secret Location, Islamabad',
          date: '2023-11-20',
          time: '10:00 PM',
          description:
              'An exclusive gathering for Milap Gold members. Top DJ lineup, neon aesthetics, and premium vibes.',
          rules: ['Gold Members Only', 'Age 21+', 'Strict Security Check'],
          media: ['https://picsum.photos/id/453/800/600'],
          accessLevel: AccessLevel.Gold,
          allowGifting: false,
          packages: [
            EventPackage(
                id: 'p1',
                name: 'Gold Pass',
                price: 5000,
                perks: ['All Access', 'Complimentary Drinks', 'After Party'],
                quantity: 50,
                soldOut: false),
          ],
          attendeesCount: 45,
          distance: '15.0 km',
          reviews: [
            EventReview(
                id: 'er3',
                userId: 'u3',
                userName: 'Bilal',
                rating: 5,
                comment: 'Insane energy! Worth the gold membership.',
                timestamp: DateTime.now()
                    .subtract(Duration(days: 10))
                    .millisecondsSinceEpoch),
          ],
        ),
        SocialEvent(
          id: 'e3',
          organizerId: '103',
          organizerName: 'Milap Promos',
          organizerAvatar: 'https://picsum.photos/id/104/100/100',
          organizerRating: 4.8,
          organizerContact: 'Promo Team',
          pastEventsCount: 50,
          title: 'Mega Concert 2024',
          eventType: EventType.Concert,
          environment: EventEnvironment.Outdoor,
          location: 'National Stadium, Karachi',
          date: '2024-01-01',
          time: '06:00 PM',
          description: 'The biggest concert of the year featuring top artists!',
          rules: ['No outside food', 'Ticket required'],
          media: ['https://picsum.photos/id/200/800/600'],
          accessLevel: AccessLevel.Public,
          allowGifting: true,
          isPromoted: true,
          packages: [
            EventPackage(
                id: 'p1',
                name: 'Early Bird',
                price: 2500,
                perks: ['Entry'],
                quantity: 500,
                soldOut: false),
          ],
          attendeesCount: 2000,
          distance: '5.0 km',
          reviews: [],
        ),
      ];

  static List<SentRequest> get mockSentRequests => [
        SentRequest(
            id: 'req1',
            targetUserId: '2',
            targetName: 'Zain & Sarah',
            targetPhoto: 'https://picsum.photos/id/177/100/100',
            status: RequestStatus.Pending,
            timestamp: DateTime.now()
                .subtract(Duration(hours: 1))
                .millisecondsSinceEpoch),
        SentRequest(
            id: 'req2',
            targetUserId: '3',
            targetName: 'Hamza Malik',
            targetPhoto: 'https://picsum.photos/id/91/100/100',
            status: RequestStatus.Accepted,
            timestamp: DateTime.now()
                .subtract(Duration(days: 1))
                .millisecondsSinceEpoch),
        SentRequest(
            id: 'req3',
            targetUserId: '4',
            targetName: 'Unknown Soul',
            targetPhoto: 'https://picsum.photos/id/55/100/100',
            status: RequestStatus.Rejected,
            timestamp: DateTime.now()
                .subtract(Duration(days: 2))
                .millisecondsSinceEpoch),
      ];

  List<UserProfile> getSocialFeed() => mockProfiles;
  List<SocialEvent> getMockEvents() => mockEvents;
  List<SentRequest> getSentRequests() => mockSentRequests;
}
