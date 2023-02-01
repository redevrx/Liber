class SingInRequest {
   String email;
   String password;

  SingInRequest({this.email = "", this.password = ""});

  SingInRequest fromJson(Map<String, dynamic> json) =>
      SingInRequest(email: json["email"], password: json["password"]);

  Map<String, String> toJson() =>
      Map.of({"email": email, "password": password});
}
