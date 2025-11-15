class SignUpResponse {
  final String userFirstName;
  final String userLastName;
  final String email;
  final bool emailVerified;
  final String id;
  final String refreshToken;
  final String accessToken;
  final bool? isAdmin;
  final bool? isSubscriber;

  SignUpResponse({
    required this.userFirstName,
    required this.userLastName,
    required this.email,
    required this.emailVerified,
    required this.id,
    required this.refreshToken,
    required this.accessToken,
    this.isAdmin,
    this.isSubscriber,
  });

  factory SignUpResponse.fromJson(Map<String, dynamic> json) {
    return SignUpResponse(
      userFirstName: json['userFirstName'],
      userLastName: json['userLastName'],
      email: json['email'],
      emailVerified: json['emailVerified'],
      id: json['_id'],
      refreshToken: json['refreshToken'],
      accessToken: json['accessToken'],
      isAdmin: json['isAdmin'],
      isSubscriber: json['isSubscriber'],
    );
  }
}