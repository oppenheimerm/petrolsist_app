
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

  //  Routes
  static const String rootSplash = "/splash";
  static const String rootLogin = "/login";
  static const String rootHome = "/home";
  static const String rootSignup = "/signup";

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

  static const int OPERATION_SUCCESS = 0;
  static const int REFRESHED_TOKENS_FOR_USER = 1;
  static const int PERSISTED_USER_TO_STORAGE = 2;
  //  const message types
  //    3000 range Errors
  static const int NO_SAVED_USER_INSTANCE = 3000;
  static const int COULD_NOT_AUTHENTICATE_USER = 3001;
  static const int REFRESHED_TOKENS_FOR_USER_FAIL = 3002;
  static const int COULD_NOT_COMPLETE_NETWORK_REQEST = 3003;
  static const int COULD_NOT_DELETE_STORED_USER = 3004;
  static const int COULD_NOT_PERSIST_USER = 3005;
  static const int COULD_NOT_PERSIST_KEYVALUE = 3006;


  //  const network Errors
  static const int USER_NOT_FOUND = 404;
  //  503 Service Unavailable
  static const int NO_NETWORK_SERVICE = 503;


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
