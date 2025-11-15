class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final bool isAdmin;
  final bool emailVerified;
  final bool isSubscriber;
  final bool hasActiveTrial;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.isAdmin = false,
    this.emailVerified = false,
    this.isSubscriber = false,
    this.hasActiveTrial = false
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      email: json['email'],
      firstName: json['userFirstName'],
      lastName: json['userLastName'],
      isAdmin: json['isAdmin'] ?? false,
      emailVerified: json['emailVerified'] ?? false,
      isSubscriber: json['isSubscriber'] ?? false,
      hasActiveTrial: json['hasActiveTrial'] ?? false
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'userFirstName': firstName,
      'userLastName': lastName,
      'isAdmin': isAdmin,
      'emailVerified': emailVerified,
      'isSubscriber': isSubscriber,
      'hasActiveTrial': hasActiveTrial
    };
  }
}