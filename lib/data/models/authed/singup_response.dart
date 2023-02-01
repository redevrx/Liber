class SingUpResponse {
  final String userId;
  final String accessToken;
  final String refreshToken;

  SingUpResponse(
      { this.userId = "",
       this.accessToken = "",
       this.refreshToken = ""});

  factory SingUpResponse.fromJson(Map<String, dynamic> json) => SingUpResponse(
      accessToken: json["accessToken"],
      refreshToken: json["refreshToken"],
      userId: json["userId"]);
}
