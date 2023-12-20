// Login server response
class LoginModel {
  String id;
  String firstName;
  String lastName;
  String jwtToken;
  String initials;
  String photo;
  String emailAddress;

  LoginModel(
      this.id,
      this.firstName,
      this.lastName,
      this.jwtToken,
      this.initials,
      this.photo,
      this.emailAddress
      );

  LoginModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        firstName = json['firstName'],
        lastName = json['lastName'],
        jwtToken = json['jwtToken'],
        initials = json['initials'],
        photo = json['photo'],
        emailAddress = json['emailAddress'];

  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'jwtToken' : jwtToken,
        'initials' : initials,
        'photo' : photo,
        'emailAddress' : emailAddress,
      };
}