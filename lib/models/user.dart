import '../app_constants.dart';

class UserModel {
  String id;
  String firstName;
  String lastName;
  String jwtToken;
  String initials;
  String photo;
  String emailAddress;
  AuthStatus authStatus;
  DateTime? loginTimeStamp;
  String? refreshToken;
  DateTime? refreshTokenExpiry;

  UserModel(

      this.id,
      this.firstName,
      this.lastName,
      this.jwtToken,
      this.initials,
      this.photo,
      this.emailAddress,
      this.authStatus,
      this.loginTimeStamp,
      this.refreshToken,
      this.refreshTokenExpiry,
      );


  static AuthStatus getStatusFromString(String authStatusAsString){
    var authStatus = AuthStatus.notDetermined;

    switch(authStatusAsString){
      case 'notDetermined':
      authStatus = AuthStatus.notDetermined;
      case 'notSignedIn':
  authStatus = AuthStatus.notSignedIn;
      case 'signedIn':
  authStatus = AuthStatus.signedIn;
    }

    return authStatus;
  }

  // just returns a empty instance of a UserModel
  static getNullUser(){
    return UserModel(
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        AuthStatus.notSignedIn,
        null,
        null,
        null,
        );
  }

  UserModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        firstName = json['firstName'],
        lastName = json['lastName'],
        jwtToken = json['jwtToken'],
        initials = json['initials'],
        photo = json['photo'],
        emailAddress = json['emailAddress'],
        authStatus = getStatusFromString(json['authStatus']),
        loginTimeStamp = DateTime.parse(json['loginTimeStamp']),
        refreshTokenExpiry = DateTime.parse(json['refreshTokenExpiry']),
        refreshToken = json['refreshToken'];

  Map<String, dynamic> toJson() {
    // Remove unnecessary 'new' and use a collection literal instead
    //final Map<String, dynamic> data = new Map<String, dynamic>();
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['jwtToken'] = jwtToken;
    data['initials'] = initials;
    data['photo'] = photo;
    data['emailAddress'] = emailAddress;
    data['authStatus'] = authStatus.toString();
    data['loginTimeStamp'] = loginTimeStamp.toString();
    data['refreshTokenExpiry'] = refreshTokenExpiry.toString();
    data['refreshToken'] = refreshToken;
    return data;
  }

}