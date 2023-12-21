
enum AuthStatus {
  notDetermined,
  notSignedIn,
  signedIn,
}

enum ApiRequestType{
  login,
  register,
  refreshToken
}


AuthStatus getStatus(String authStatus)
{
  var status = AuthStatus.notDetermined;

  switch(authStatus)
  {
    case 'notDetermined':
      status = AuthStatus.notDetermined;
      break;
    case 'notSignedIn':
      status = AuthStatus.signedIn;
      break;
    case 'signedIn':
      status = AuthStatus.signedIn;
      break;
  }

  return status;
}

String authStatusToString(AuthStatus authStatus)
{
  String status = "notDetermined";

  switch(authStatus)
  {
    case AuthStatus.notDetermined:
      status = "notDetermined";
      break;
    case AuthStatus.notSignedIn:
      status = "notSignedIn";
      break;
    case AuthStatus.signedIn:
      status = "signedIn";
      break;
  }

  return status;
}

AuthStatus authStatusFromString(String string){
  AuthStatus status = AuthStatus.notSignedIn;

  switch(string){
    case "notDetermined":
      status = AuthStatus.notDetermined;
      break;
    case "notSignedIn":
      status = AuthStatus.notSignedIn;
      break;
    case "signedIn":
      status = AuthStatus.signedIn;
      break;
    case "AuthStatus.signedIn":
      status = AuthStatus.signedIn;
      break;
    case "AuthStatus.notDetermined":
      status = AuthStatus.notDetermined;
      break;
    case "AuthStatus.notSignedIn":
      status = AuthStatus.notSignedIn;
      break;
  }

  return status;
}


class AppConsts{
  //static const String baseUrl = "https://psusersapi.azurewebsites.net";
  //static const String baseUrl = "http://192.168.1.152:8000";
  static const String baseUrl = "http://10.0.2.2:5281";

  //  Keys
  //    UserModel keys for storage
  static const String userId = 'id';
  static const String firstName = 'firstName';
  static const String lastName = 'lastName';
  static const String jwtToken = 'jwtToken';
  static const String initials = 'initials';
  static const String photo = 'photo';
  static const String emailAddress = 'emailAddress';
  static const String authStatus = 'authStatus';
  static const String loginTimeStamp = 'loginTimeStamp';
  static const String refreshToken = 'refreshToken';
  static const String refreshTokenExpiry = 'refreshTokenExpiry';

  //  const message types
  //    3000 range Errors
  static const int NO_SAVED_USER_INSTANCE = 3000;


  static String? getUrl(ApiRequestType request){
    var requestType = request.name;
    switch(requestType){
      case 'login' :
        return "$baseUrl/api/1/users/authenticate";
      case 'refreshToken':
        return "$baseUrl/api/1/users/refresh-token";
      default:
        throw const FormatException('Invalid ApiRequestType!');
    }
  }
}
