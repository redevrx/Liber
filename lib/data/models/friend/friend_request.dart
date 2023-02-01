class FriendRequest {
  final String fromId;
  final String toId;
  final String createAt;
  final String relation;
  final String status;

  FriendRequest(
      {this.fromId = "",
      this.toId = "",
      this.createAt = "",
      this.relation = "",
      this.status = ""});

  factory FriendRequest.fromJson(Map<String,String> json) => FriendRequest(
    fromId: json["fromId"].toString(),
    toId: json["toId"].toString(),
    createAt: json["createAt"].toString(),
    relation: json["relation"].toString(),
    status: json["status"].toString()
  );

  Map<String, String> toJson() => Map.of({
        "fromId": fromId,
        "toId": toId,
        "createAt": createAt,
        "relation": relation,
        "status": status
      });
}
