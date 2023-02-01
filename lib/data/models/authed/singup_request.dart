class SingUpRequest {
  String userName;
  String aliasName;
  int age;
  String phoneNumber;
  int sex;
  String email;
  String password = "1";
  String confirmPassword = "1";
  bool isCall = true;

  SingUpRequest(
      {this.userName = "",
      this.aliasName = "",
      this.age = 1,
      this.phoneNumber = "",
      this.sex = 1,
      this.email = "",
      this.password = "1",
      this.confirmPassword = "1",
      this.isCall = true});

  Map<String, dynamic> toJson() => Map.of({
        "userName": userName,
        "aliasName": aliasName,
        "age": age,
        "phoneNumber": phoneNumber,
        "sex": sex,
        "email": email,
        "password": password
      });

  int isValidPassword() => password.compareTo(confirmPassword);

  bool valid() => (password == confirmPassword &&
      userName != "" &&
      age >= 1 &&
      phoneNumber.isNotEmpty &&
      email.isNotEmpty);
}
