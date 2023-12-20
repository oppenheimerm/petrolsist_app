import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../app_constants.dart';
import '../../models/login_model.dart';
import '../../models/user.dart';
import '../../request_response/operation_status.dart';
import '../../request_response/parsed_response.dart';
import '../local_storage.dart';


abstract class AuthenticationServiceBase {
  Future<ParsedResponse<UserModel>> requestLoginAPI(String username, String password);
  Future<UserModel?> currentUser();
  refreshTokenForUser(UserModel savedUser);
}

class AuthenticationService implements AuthenticationServiceBase{
  final int NO_INTERNET = 404;

  @override
  Future<ParsedResponse<UserModel>> requestLoginAPI(String username, String password) async{

    var body = json.encode(<String, String>{
      "emailAddress": username,
      'password': password,
    });


    var url = AppConsts.getUrl(ApiRequestType.login).toString();
    var loginTimeStamp = DateTime.now();
    final response = await http.post(
      /*
          If you’re sure an expression with a nullable type doesn’t
          equal null, you can use the null assertion operator (!) to
          make Dart treat it as non-nullable.
      */
        Uri.parse(url),
        body: body,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          }
    );

    if (response.statusCode == 200) {
      //  Get cookie data
      //https://stackoverflow.com/questions/58378960/cant-access-cookie-in-http-response-with-flutter
      String rawCookie = response.headers['set-cookie']!;
      int index = rawCookie.indexOf(';');
      String refreshToken = (index == -1) ? rawCookie : rawCookie.substring(0, index);
      ////  refreshToken=4uRZ2lORFcpGNeuZhTvUWiC0cW7yPi2jhTutKjlmvadypNJhWo3AY4tUETncao5%2FAh2S%2BSPo5rYE%2B7CgMEzPEw%3D%3D; expires=Tue, 14 Nov 2023 17:54:02 GMT; path=/; httponly
      int idx = refreshToken.indexOf("=");
      var rToken = refreshToken.substring(idx+1).trim();
      var tokenExpiry = getTokenExpiry(rawCookie);
      final responseJson = json.decode(response.body);
      var userData = LoginModel.fromJson(responseJson);


      // Before calling below we nee:
      //    RefreshTokenExpiry
      var user = UserModel(
        userData.id,
          userData.firstName,
          userData.lastName,
          userData.jwtToken,/* short lived JWT access token */
          userData.initials,
          userData.photo,
          userData.emailAddress,
          AuthStatus.signedIn,
          loginTimeStamp,/* login timestamp */
          rToken, /* refreshToken*/
          tokenExpiry,/* RefreshToken expiry */);

      //  Delete stale data
      //LocalStorageService.deleteUser();
      var saveUserStatus = await LocalStorageService.persistUser(user);
      // Should be good to go here!
      return ParsedResponse(response.statusCode, user);

    }else{
      //  response will always be null if it is a error code: i.e. status 415
      //  We really need to catch all the types of responses and create a
      //  switch case and notify user of error.  For now just return null

      return ParsedResponse(NO_INTERNET, UserModel.getNullUser());
    }
  }

  @override
  Future<UserModel?> currentUser() async {

    var user = await LocalStorageService.getUserFromDisk();
    if(user != null && user.authStatus == AuthStatus.signedIn && user.loginTimeStamp != null)
      {
        //  Check Last login and token expiry
        var lastLogin = user.loginTimeStamp;
        var timeNow = DateTime.now();
        var duration = timeNow.difference(lastLogin!);
        var minElapsed = duration.inMinutes;
        if (minElapsed > 15) /* actual 20 */
          {
            //  perform token refresh
            await refreshTokenForUser(user);
          }
          else{
            return user;
        }
        return user;
      }else{
      //  handle not logged in / timestamp empty
      // assume user is not logged in
      return UserModel.getNullUser();
    }
    return null;
  }

  @override
  Future<OperationStatus> refreshTokenForUser(UserModel savedUser) async {

    if(( savedUser.loginTimeStamp == null
        || ( savedUser.refreshTokenExpiry == null)
        || (savedUser.refreshToken == null || savedUser.refreshToken!.isEmpty)
        || (savedUser.jwtToken.isEmpty)
        || (savedUser.loginTimeStamp == null)
        )){
            return OperationStatus(false, AppConsts.NO_SAVED_USER_INSTANCE.toString());
    }else{
      // now we have the user tokens
      var refreshTimestamp = DateTime.now();
      var url = AppConsts.getUrl(ApiRequestType.refreshToken).toString();

      var loginTimeStamp = DateTime.now();
      final response = await http.post(
          Uri.parse(url),
          headers: {
            HttpHeaders.authorizationHeader: savedUser.jwtToken,
            'Cookie':  "refreshToken=${savedUser.refreshToken}"
          }
      );

      if (response.statusCode == 200) {
        String rawCookie = response.headers['set-cookie']!;
        int index = rawCookie.indexOf(';');
        String refreshToken = (index == -1) ? rawCookie : rawCookie.substring(0, index);
        ////  refreshToken=4uRZ2lORFcpGNeuZhTvUWiC0cW7yPi2jhTutKjlmvadypNJhWo3AY4tUETncao5%2FAh2S%2BSPo5rYE%2B7CgMEzPEw%3D%3D; expires=Tue, 14 Nov 2023 17:54:02 GMT; path=/; httponly
        int idx = refreshToken.indexOf("=");
        var rToken = refreshToken.substring(idx+1).trim();
        var tokenExpiry = getTokenExpiry(rawCookie);
        final responseJson = json.decode(response.body);
        var userData = LoginModel.fromJson(responseJson);


        // Update fields,
        savedUser.loginTimeStamp = loginTimeStamp;
        savedUser.refreshToken = rToken;
        savedUser.refreshTokenExpiry = tokenExpiry;

        //  save the data by calling persistUser(), which
        //  will overwrite the stale values with the fresh
        //  ones above.
        var updateStatus = await LocalStorageService.persistUser(savedUser);


        if(updateStatus.success)
          {
            return OperationStatus(true, "Successfully refreshed tokens for user.");
          }
        else{
          return OperationStatus(false, "Could refresh user tokens");
        }
      }
      else{
        // Really need to catch other errors from server like 500, which could
        //  could be transitory.
        return OperationStatus(false, "Could not contact server");
      }
    }
    //
  }

  //  We're using jwt tokens, which is stateless, we just need to remove the
  //  stored token and clear all settings
  UserModel signOut()  {
    LocalStorageService.deleteUser();
    return UserModel.getNullUser();
  }

  int getMonthFromString(String month){
    //  [1]expires=Thu, 21 Dec 2023 19:48:17 GMT;
    // from asp.net / C#
    //  https://learn.microsoft.com/en-us/dotnet/api/system.globalization.datetimeformatinfo.abbreviatedmonthnames?view=net-8.0
    //   "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct",
    //  Dart DateTime.month - [1..12].
    int? monthAsInt = 0;
    switch(month){
      case 'Jan':
        monthAsInt = 1;
      case 'Feb':
        monthAsInt = 2;
      case 'Mar':
        monthAsInt = 3;
      case 'Apr':
        monthAsInt = 4;
      case 'May':
        monthAsInt = 5;
      case 'Jun':
        monthAsInt = 6;
      case 'Jul':
        monthAsInt = 7;
      case 'Aug':
        monthAsInt = 8;
      case 'Sep':
        monthAsInt = 9;
      case 'Oct':
        monthAsInt = 10;
      case 'Nov':
        monthAsInt = 11;
      case 'Dec':
        monthAsInt = 12;
      }

      return monthAsInt;
  }

  DateTime getTokenExpiry(String rawTokenString){
    /*
        [0]refreshToken=ZEvge5nm7%2BDPN1c1kAwr4LjVkRt9gid6cV1Kic8oT8OTLhyOIbNKQvglsL6k4YkccgKSbKvESaPYOavnhtyk%2Bw%3D%3D;
        [1]expires=Thu, 21 Dec 2023 19:48:17 GMT;
        [2]path=/;
        [3]httponly,ARRAffinity=79e06db539acb57119e709978d2cf1da299e8341753d6f6345007fcab3f69bc5;Path=/;HttpOnly;Secure;Domain=psusersapi.azurewebsites.net,ARRAffinitySameSite=79e06db539acb57119e709978d2cf1da299e8341753d6f6345007fcab3f69bc5;Path=/;HttpOnly;SameSite=None;Secure;Domain=psusersapi.azurewebsites.net
    * */
    var firstParse = rawTokenString.split(";");
    //  we want [2]
    var secondParse = firstParse[1];
    //  We now should have
    //  expires=Thu, 21 Dec 2023 19:48:17 GMT;
    var thirdParse = secondParse.split("=");
    //  [0]expires=
    //  [1]Thu, 21 Dec 2023 19:48:17 GMT;

    //   We need to put this in a format that DateTime.parse() can use
    var fourthParse = thirdParse[1].split(" ");
    //[0]Thu,
    // [1]21
    // [2]Dec
    // [3]2023
    // [4]19:48:17
    // [5]GMT;
    var hourMinSecs = fourthParse[4].split(":");

    var expiryDate = DateTime(
        int.parse(fourthParse[3]),//Year
        getMonthFromString(fourthParse[2]),//Month
        int.parse(fourthParse[1]),// Day
        int.parse(hourMinSecs[0]),// Hour
        int.parse(hourMinSecs[1]),// Minute
        int.parse(hourMinSecs[2]),// Second
        0 );// millisecond
    return expiryDate;
  }
}