enum Gender { Male, Female, Other }

enum UserType { Individual, Couple }

enum HookupIntent { Casual, Fantasies, Chatting, Secret }

enum RelationshipStatus { Single, Taken, Engaged, Married, Complicated }

enum RequestStatus { Pending, Accepted, Rejected }

class SentRequest {
  final String id;
  final String targetUserId;
  final String targetName;
  final String targetPhoto;
  final RequestStatus status;
  final int timestamp;

  SentRequest({
    required this.id,
    required this.targetUserId,
    required this.targetName,
    required this.targetPhoto,
    required this.status,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'targetUserId': targetUserId,
      'targetName': targetName,
      'targetPhoto': targetPhoto,
      'status': status.index,
      'timestamp': timestamp,
    };
  }

  factory SentRequest.fromMap(Map<String, dynamic> map) {
    return SentRequest(
      id: map['id'] ?? '',
      targetUserId: map['targetUserId'] ?? '',
      targetName: map['targetName'] ?? '',
      targetPhoto: map['targetPhoto'] ?? '',
      status: RequestStatus.values[map['status'] ?? 0],
      timestamp: map['timestamp'] ?? 0,
    );
  }
}

class PrivateFolder {
  final String id;
  final String name;
  final List<String> assetIds;
  final List<String> sharedWith;

  PrivateFolder({
    required this.id,
    required this.name,
    required this.assetIds,
    required this.sharedWith,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'assetIds': assetIds,
      'sharedWith': sharedWith,
    };
  }

  factory PrivateFolder.fromMap(Map<String, dynamic> map) {
    return PrivateFolder(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      assetIds: List<String>.from(map['assetIds'] ?? []),
      sharedWith: List<String>.from(map['sharedWith'] ?? []),
    );
  }
}

class PrivateAsset {
  final String id;
  final String url;
  final String type; // 'photo' | 'video'
  final int addedAt;

  PrivateAsset({
    required this.id,
    required this.url,
    required this.type,
    required this.addedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'url': url,
      'type': type,
      'addedAt': addedAt,
    };
  }

  factory PrivateAsset.fromMap(Map<String, dynamic> map) {
    return PrivateAsset(
      id: map['id'] ?? '',
      url: map['url'] ?? '',
      type: map['type'] ?? 'photo',
      addedAt: map['addedAt'] ?? 0,
    );
  }
}

class UserReview {
  final String id;
  final String reviewerName;
  final double rating;
  final String comment;
  final int date;

  UserReview({
    required this.id,
    required this.reviewerName,
    required this.rating,
    required this.comment,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reviewerName': reviewerName,
      'rating': rating,
      'comment': comment,
      'date': date,
    };
  }

  factory UserReview.fromMap(Map<String, dynamic> map) {
    return UserReview(
      id: map['id'] ?? '',
      reviewerName: map['reviewerName'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      comment: map['comment'] ?? '',
      date: map['date'] ?? 0,
    );
  }
}

class ProfileVisitor {
  final String userId;
  final String name;
  final String photo;
  final int timestamp;

  ProfileVisitor({
    required this.userId,
    required this.name,
    required this.photo,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'photo': photo,
      'timestamp': timestamp,
    };
  }

  factory ProfileVisitor.fromMap(Map<String, dynamic> map) {
    return ProfileVisitor(
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      photo: map['photo'] ?? '',
      timestamp: map['timestamp'] ?? 0,
    );
  }
}

class Relationship {
  final RelationshipStatus status;
  final String? partnerName;
  final String? startDate;
  final bool isVisible;

  Relationship({
    required this.status,
    this.partnerName,
    this.startDate,
    required this.isVisible,
  });

  Map<String, dynamic> toMap() {
    return {
      'status': status.index,
      'partnerName': partnerName,
      'startDate': startDate,
      'isVisible': isVisible,
    };
  }

  factory Relationship.fromMap(Map<String, dynamic> map) {
    return Relationship(
      status: RelationshipStatus.values[map['status'] ?? 0],
      partnerName: map['partnerName'],
      startDate: map['startDate'],
      isVisible: map['isVisible'] ?? true,
    );
  }
}

class StatusPrivacy {
  final List<String> hideFrom;
  final List<String> showOnlyTo;

  StatusPrivacy({required this.hideFrom, required this.showOnlyTo});

  Map<String, dynamic> toMap() {
    return {
      'hideFrom': hideFrom,
      'showOnlyTo': showOnlyTo,
    };
  }

  factory StatusPrivacy.fromMap(Map<String, dynamic> map) {
    return StatusPrivacy(
      hideFrom: List<String>.from(map['hideFrom'] ?? []),
      showOnlyTo: List<String>.from(map['showOnlyTo'] ?? []),
    );
  }
}

class SocialLinks {
  final String? instagram;
  final String? twitter;
  final String? tiktok;

  SocialLinks({this.instagram, this.twitter, this.tiktok});

  Map<String, dynamic> toMap() {
    return {
      'instagram': instagram,
      'twitter': twitter,
      'tiktok': tiktok,
    };
  }

  factory SocialLinks.fromMap(Map<String, dynamic> map) {
    return SocialLinks(
      instagram: map['instagram'],
      twitter: map['twitter'],
      tiktok: map['tiktok'],
    );
  }
}

class MatchRequest {
  final String userId;
  final String name;
  final String photo;
  final int timestamp;

  MatchRequest({
    required this.userId,
    required this.name,
    required this.photo,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'photo': photo,
      'timestamp': timestamp,
    };
  }

  factory MatchRequest.fromMap(Map<String, dynamic> map) {
    return MatchRequest(
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      photo: map['photo'] ?? '',
      timestamp: map['timestamp'] ?? 0,
    );
  }
}

class UserProfile {
  final String id;
  final String name;
  final String? partner2Name;
  final int age;
  final int? partner2Age;
  final Gender gender;
  final Gender? partner2Gender;
  final String dob;
  final String? partner2Dob;
  final String location;
  final String bio;
  final List<String> interests;
  final List<String> photos;
  final List<String>? videos;
  final List<String>? hiddenMediaIds;
  final bool isOnline;
  final double rating;
  final int reviewsCount;
  final bool isCouple;
  final UserType type;
  final bool isMilapGold;
  final bool? hookupActive;
  final HookupIntent? hookupIntent;
  final List<PrivateAsset>? vaultAssets;
  final List<PrivateFolder>? vaultFolders;
  final String? vaultPin;
  final bool? isVerified;
  final List<UserReview>? reviews;
  final bool lookingForDates;
  final bool isDeactivated;
  final List<String>? blockedUserIds;
  final StatusPrivacy? statusPrivacy;

  // Country Discovery
  final String? country;

  // Economy
  final int heartsBalance;
  final String lastHeartRefill;

  // Relationship
  final Relationship? relationship;

  // Social
  final List<ProfileVisitor>? profileVisitors;
  final SocialLinks? socialLinks;
  final List<MatchRequest>? matchRequests;

  // Security
  final int? screenshotWarnings;
  final int? suspendedUntil;
  final bool? privacyGuardEnabled;
  final String? appPin;
  final bool notificationsEnabled;
  final bool notificationsMuted;

  UserProfile({
    required this.id,
    required this.name,
    this.partner2Name,
    required this.age,
    this.partner2Age,
    required this.gender,
    this.partner2Gender,
    required this.dob,
    this.partner2Dob,
    required this.location,
    required this.bio,
    required this.interests,
    required this.photos,
    this.videos,
    this.hiddenMediaIds,
    required this.isOnline,
    required this.rating,
    required this.reviewsCount,
    required this.isCouple,
    required this.type,
    this.isMilapGold = false,
    this.hookupActive,
    this.hookupIntent,
    this.vaultAssets,
    this.vaultFolders,
    this.vaultPin,
    this.isVerified,
    this.reviews,
    required this.lookingForDates,
    required this.isDeactivated,
    this.blockedUserIds,
    this.statusPrivacy,
    this.country,
    required this.heartsBalance,
    required this.lastHeartRefill,
    this.relationship,
    this.profileVisitors,
    this.socialLinks,
    this.matchRequests,
    this.screenshotWarnings,
    this.suspendedUntil,
    this.privacyGuardEnabled,
    this.appPin,
    this.notificationsEnabled = true,
    this.notificationsMuted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'partner2Name': partner2Name,
      'age': age,
      'partner2Age': partner2Age,
      'gender': gender.index,
      'partner2Gender': partner2Gender?.index,
      'dob': dob,
      'partner2Dob': partner2Dob,
      'location': location,
      'bio': bio,
      'interests': interests,
      'photos': photos,
      'videos': videos,
      'hiddenMediaIds': hiddenMediaIds,
      'isOnline': isOnline,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'isCouple': isCouple,
      'type': type.index,
      'isMilapGold': isMilapGold,
      'hookupActive': hookupActive,
      'hookupIntent': hookupIntent?.index,
      'vaultAssets': vaultAssets?.map((x) => x.toMap()).toList(),
      'vaultFolders': vaultFolders?.map((x) => x.toMap()).toList(),
      'vaultPin': vaultPin,
      'isVerified': isVerified,
      'reviews': reviews?.map((x) => x.toMap()).toList(),
      'lookingForDates': lookingForDates,
      'isDeactivated': isDeactivated,
      'blockedUserIds': blockedUserIds,
      'statusPrivacy': statusPrivacy?.toMap(),
      'country': country,
      'heartsBalance': heartsBalance,
      'lastHeartRefill': lastHeartRefill,
      'relationship': relationship?.toMap(),
      'profileVisitors': profileVisitors?.map((x) => x.toMap()).toList(),
      'socialLinks': socialLinks?.toMap(),
      'matchRequests': matchRequests?.map((x) => x.toMap()).toList(),
      'screenshotWarnings': screenshotWarnings,
      'suspendedUntil': suspendedUntil,
      'privacyGuardEnabled': privacyGuardEnabled,
      'appPin': appPin,
      'notificationsEnabled': notificationsEnabled,
      'notificationsMuted': notificationsMuted,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      partner2Name: map['partner2Name'],
      age: map['age'] ?? 0,
      partner2Age: map['partner2Age'],
      gender: Gender.values[map['gender'] ?? 0],
      partner2Gender: map['partner2Gender'] != null
          ? Gender.values[map['partner2Gender']]
          : null,
      dob: map['dob'] ?? '',
      partner2Dob: map['partner2Dob'],
      location: map['location'] ?? '',
      bio: map['bio'] ?? '',
      interests: List<String>.from(map['interests'] ?? []),
      photos: List<String>.from(map['photos'] ?? []),
      videos: map['videos'] != null ? List<String>.from(map['videos']) : null,
      hiddenMediaIds: map['hiddenMediaIds'] != null
          ? List<String>.from(map['hiddenMediaIds'])
          : null,
      isOnline: map['isOnline'] ?? false,
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewsCount: map['reviewsCount'] ?? 0,
      isCouple: map['isCouple'] ?? false,
      type: UserType.values[map['type'] ?? 0],
      isMilapGold: map['isMilapGold'] ?? false,
      hookupActive: map['hookupActive'],
      hookupIntent: map['hookupIntent'] != null
          ? HookupIntent.values[map['hookupIntent']]
          : null,
      vaultAssets: map['vaultAssets'] != null
          ? List<PrivateAsset>.from(
              map['vaultAssets'].map((x) => PrivateAsset.fromMap(x)))
          : null,
      vaultFolders: map['vaultFolders'] != null
          ? List<PrivateFolder>.from(
              map['vaultFolders'].map((x) => PrivateFolder.fromMap(x)))
          : null,
      vaultPin: map['vaultPin'],
      isVerified: map['isVerified'],
      reviews: map['reviews'] != null
          ? List<UserReview>.from(
              map['reviews'].map((x) => UserReview.fromMap(x)))
          : null,
      lookingForDates: map['lookingForDates'] ?? true,
      isDeactivated: map['isDeactivated'] ?? false,
      blockedUserIds: map['blockedUserIds'] != null
          ? List<String>.from(map['blockedUserIds'])
          : null,
      statusPrivacy: map['statusPrivacy'] != null
          ? StatusPrivacy.fromMap(map['statusPrivacy'])
          : null,
      country: map['country'],
      heartsBalance: map['heartsBalance'] ?? 0,
      lastHeartRefill: map['lastHeartRefill'] ?? '',
      relationship: map['relationship'] != null
          ? Relationship.fromMap(map['relationship'])
          : null,
      profileVisitors: map['profileVisitors'] != null
          ? List<ProfileVisitor>.from(
              map['profileVisitors'].map((x) => ProfileVisitor.fromMap(x)))
          : null,
      socialLinks: map['socialLinks'] != null
          ? SocialLinks.fromMap(map['socialLinks'])
          : null,
      matchRequests: map['matchRequests'] != null
          ? List<MatchRequest>.from(
              map['matchRequests'].map((x) => MatchRequest.fromMap(x)))
          : null,
      screenshotWarnings: map['screenshotWarnings'],
      suspendedUntil: map['suspendedUntil'],
      privacyGuardEnabled: map['privacyGuardEnabled'],
      appPin: map['appPin'],
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      notificationsMuted: map['notificationsMuted'] ?? false,
    );
  }

  UserProfile copyWith({
    String? name,
    String? partner2Name,
    int? age,
    int? partner2Age,
    Gender? gender,
    Gender? partner2Gender,
    String? dob,
    String? partner2Dob,
    String? location,
    String? bio,
    List<String>? interests,
    List<String>? photos,
    List<String>? videos,
    List<String>? hiddenMediaIds,
    bool? isOnline,
    double? rating,
    int? reviewsCount,
    bool? isCouple,
    UserType? type,
    bool? isMilapGold,
    bool? hookupActive,
    HookupIntent? hookupIntent,
    List<PrivateAsset>? vaultAssets,
    List<PrivateFolder>? vaultFolders,
    String? vaultPin,
    bool? isVerified,
    List<UserReview>? reviews,
    bool? lookingForDates,
    bool? isDeactivated,
    List<String>? blockedUserIds,
    StatusPrivacy? statusPrivacy,
    String? country,
    int? heartsBalance,
    String? lastHeartRefill,
    Relationship? relationship,
    List<ProfileVisitor>? profileVisitors,
    SocialLinks? socialLinks,
    List<MatchRequest>? matchRequests,
    int? screenshotWarnings,
    int? suspendedUntil,
    bool? privacyGuardEnabled,
    String? appPin,
    bool? notificationsEnabled,
    bool? notificationsMuted,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      partner2Name: partner2Name ?? this.partner2Name,
      age: age ?? this.age,
      partner2Age: partner2Age ?? this.partner2Age,
      gender: gender ?? this.gender,
      partner2Gender: partner2Gender ?? this.partner2Gender,
      dob: dob ?? this.dob,
      partner2Dob: partner2Dob ?? this.partner2Dob,
      location: location ?? this.location,
      bio: bio ?? this.bio,
      interests: interests ?? this.interests,
      photos: photos ?? this.photos,
      videos: videos ?? this.videos,
      hiddenMediaIds: hiddenMediaIds ?? this.hiddenMediaIds,
      isOnline: isOnline ?? this.isOnline,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      isCouple: isCouple ?? this.isCouple,
      type: type ?? this.type,
      isMilapGold: isMilapGold ?? this.isMilapGold,
      hookupActive: hookupActive ?? this.hookupActive,
      hookupIntent: hookupIntent ?? this.hookupIntent,
      vaultAssets: vaultAssets ?? this.vaultAssets,
      vaultFolders: vaultFolders ?? this.vaultFolders,
      vaultPin: vaultPin ?? this.vaultPin,
      isVerified: isVerified ?? this.isVerified,
      reviews: reviews ?? this.reviews,
      lookingForDates: lookingForDates ?? this.lookingForDates,
      isDeactivated: isDeactivated ?? this.isDeactivated,
      blockedUserIds: blockedUserIds ?? this.blockedUserIds,
      statusPrivacy: statusPrivacy ?? this.statusPrivacy,
      country: country ?? this.country,
      heartsBalance: heartsBalance ?? this.heartsBalance,
      lastHeartRefill: lastHeartRefill ?? this.lastHeartRefill,
      relationship: relationship ?? this.relationship,
      profileVisitors: profileVisitors ?? this.profileVisitors,
      socialLinks: socialLinks ?? this.socialLinks,
      matchRequests: matchRequests ?? this.matchRequests,
      screenshotWarnings: screenshotWarnings ?? this.screenshotWarnings,
      suspendedUntil: suspendedUntil ?? this.suspendedUntil,
      privacyGuardEnabled: privacyGuardEnabled ?? this.privacyGuardEnabled,
      appPin: appPin ?? this.appPin,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationsMuted: notificationsMuted ?? this.notificationsMuted,
    );
  }
}
