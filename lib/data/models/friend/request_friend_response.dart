class RFriendResponse {
  final String requestId;
  final String status;

  RFriendResponse({this.requestId = "", this.status = ""});

  factory RFriendResponse.fromJson(Map<String,dynamic> json) => RFriendResponse(
    requestId: json["requestId"].toString(),
    status: json["status"].toString()
  );
}