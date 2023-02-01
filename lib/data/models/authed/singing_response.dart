class SingInResponse {
  final String accessToken;
  final String refreshToken;
  final String userId;

  SingInResponse({this.accessToken = "", this.refreshToken = "",this.userId = ""});

  factory SingInResponse.fromJson(Map<String, dynamic> json) => SingInResponse(
      accessToken: json["accessToken"], refreshToken: json["refreshToken"],userId: json["userId"]);
}
