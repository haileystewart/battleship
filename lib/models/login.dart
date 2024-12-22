class LoginResponse {
  final String message;
  final String accessToken;

  LoginResponse({
    required this.message,
    required this.accessToken,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      message: json['message'],
      accessToken: json['access_token'],
    );
  }
}
