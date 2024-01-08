import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:petrolsist_app/service/network_service.dart';
import '../../app_constants.dart';
import '../../models/login_model.dart';
import '../../models/user.dart';
import '../../request_response/authentication_request_response.dart';
import '../local_storage.dart';



abstract class AuthenticationServiceBase {
  Future<AuthenticationRequestResponse> requestLoginAPI(String username, String password);
  Future<AuthenticationRequestResponse> currentUser();
  Future<AuthenticationRequestResponse> refreshTokenForUser(UserModel savedUser);
}

class AuthenticationService implements AuthenticationServiceBase{

  final PSNetworkService _networkService = PSNetworkService();

  @override
  Future<AuthenticationRequestResponse> requestLoginAPI(String username, String password) async{

    var authResponse = AuthenticationRequestResponse(
        UserModel.getNullUser(),
        false,
        "Could not complete operation", AppConsts.COULD_NOT_PERSIST_USER
    );


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
      var user = _updateUser(userData,loginTimeStamp, rToken, tokenExpiry);

      await LocalStorageService.persistUser(user).then((value) async {
        if(value.success){
          authResponse = AuthenticationRequestResponse(user, true, "", AppConsts.PERSISTED_USER_TO_STORAGE);
        }else{
          debugPrint('Error: ${AppConsts.COULD_NOT_PERSIST_USER}');
         authResponse = AuthenticationRequestResponse(
              UserModel.getNullUser(),
              false,
              "Could not complete operation", AppConsts.COULD_NOT_PERSIST_USER);
        }
      });
    }else if(response.statusCode == 404){
      //  We could not contact the server, server down or wrong url
      debugPrint('Error: ${AppConsts.NOT_FOUND}');
      authResponse = AuthenticationRequestResponse(
          UserModel.getNullUser(),
          false,
          "Could not contact network",
          AppConsts.NOT_FOUND);
    }
    else{
      //  response will always be null if it is a error code: i.e. status 415
      //  We really need to catch all the types of responses and create a
      //  switch case and notify user of error.  For now just return null

      debugPrint('Error: ${AppConsts.COULD_NOT_AUTHENTICATE_USER}');
      authResponse = AuthenticationRequestResponse(
          UserModel.getNullUser(),
          false,
          "Unable to login",
          AppConsts.COULD_NOT_AUTHENTICATE_USER);
    }

    return authResponse;
    
  }

  @override
  Future<AuthenticationRequestResponse> currentUser() async {

    AuthenticationRequestResponse authenticationRequestResponse
    = AuthenticationRequestResponse(UserModel.getNullUser(),
        false,
        "Failed to authenticate.",
        AppConsts.REFRESHED_TOKENS_FOR_USER_FAIL
    );

    var currentUser = LocalStorageService.getUserFromDisk();
    if(currentUser != null && currentUser.authStatus == AuthStatus.signedIn && currentUser.loginTimeStamp != null)
    {
      //  Check Last login and token expiry
      var lastLogin = currentUser.loginTimeStamp;
      var timeNow = DateTime.now();
      var duration = timeNow.difference(lastLogin!);
      var minElapsed = duration.inMinutes;
      //if (minElapsed > 15) /* actual 20 */
      if (minElapsed > 25) /* actual 30 */
      {
        //  perform token refresh
        await refreshTokenForUser(currentUser).then((refreshValue) async {
          // If there was an error performing a refresh, we will ve sent and nul UserModel.
          // So ust return refreshValue;
          authenticationRequestResponse = refreshValue;
          //return refreshValue;
        });
      }
      else{
        //  Token is within the refresh time window, so just
        authenticationRequestResponse = AuthenticationRequestResponse(
            currentUser,
            true,
            "",
            AppConsts.OPERATION_SUCCESS
        );
        authenticationRequestResponse;
      }
    }
    else{
      authenticationRequestResponse = AuthenticationRequestResponse(UserModel.getNullUser(),
          false, "Could not find stored user credentials", AppConsts.NO_SAVED_USER_INSTANCE);
    }

    return authenticationRequestResponse;
  }

  //  TODO handle 401 error case - re-authenticate user
  @override
  Future<AuthenticationRequestResponse> refreshTokenForUser(UserModel savedUser) async {

    AuthenticationRequestResponse authenticationRequestResponse
    = AuthenticationRequestResponse(UserModel.getNullUser(),
        false,
        "Failed to authenticate.",
        AppConsts.REFRESHED_TOKENS_FOR_USER_FAIL
    );

    // Check network
    await _networkService.psGetNetworkStatus().then((value) async{
      if(value){
        // Good to Go
        var url = AppConsts.getUrl(ApiRequestType.refreshToken).toString();
        var loginTimeStamp = DateTime.now();
        final response = await http.post(
            Uri.parse(url),
            headers: {
              HttpHeaders.authorizationHeader: savedUser.jwtToken,
              'Cookie': "refreshToken=${savedUser.refreshToken}"
            });

        if (response.statusCode == 200) {
          String rawCookie = response.headers['set-cookie']!;
          int index = rawCookie.indexOf(';');
          String refreshToken = (index == -1) ? rawCookie : rawCookie.substring(
              0, index);
          ////  refreshToken=4uRZ2lORFcpGNeuZhTvUWiC0cW7yPi2jhTutKjlmvadypNJhWo3AY4tUETncao5%2FAh2S%2BSPo5rYE%2B7CgMEzPEw%3D%3D; expires=Tue, 14 Nov 2023 17:54:02 GMT; path=/; httponly
          int idx = refreshToken.indexOf("=");
          var rToken = refreshToken.substring(idx + 1).trim();
          var tokenExpiry = getTokenExpiry(rawCookie);
          final responseJson = json.decode(response.body);

          // Update fields,
          savedUser.loginTimeStamp = loginTimeStamp;
          savedUser.refreshToken = rToken;
          savedUser.refreshTokenExpiry = tokenExpiry;

          await LocalStorageService.persistUser(savedUser)
              .then((updateStatusValue) async {
            if (updateStatusValue.success) {
              authenticationRequestResponse = AuthenticationRequestResponse(
                  savedUser,
                  true,
                  "",
                  AppConsts.OPERATION_SUCCESS
              );
              //return authenticationRequestResponse;
            }
            else {
              authenticationRequestResponse = AuthenticationRequestResponse(
                  UserModel.getNullUser(),
                  false,
                  "Could not authenticate",
                  AppConsts.REFRESHED_TOKENS_FOR_USER_FAIL
              );
              debugPrint("Could not refresh token for user. ErrorType: ${AppConsts
                  .REFRESHED_TOKENS_FOR_USER_FAIL} ");
              //return authenticationRequestResponse;
            }
          });
        }
        else if (response.statusCode == 500) {
          //  Internal server error

          authenticationRequestResponse = AuthenticationRequestResponse(
              UserModel.getNullUser(),
              false,
              "Could not complete network request.",
              AppConsts.NO_SAVED_USER_INSTANCE
          );
          debugPrint("Internal server fault. ErrorType: ${AppConsts
              .INTERNAL_SERVER_ERROR} ");
          //return authenticationRequestResponse;
        }
        else if (response.statusCode == 401) {
          //  Not authorized
          //  TODO re-authenticate user here
          authenticationRequestResponse = AuthenticationRequestResponse(
              UserModel.getNullUser(),
              false,
              "Unauthorized request.",
              AppConsts.UNAUTHORIZED
          );
          debugPrint("User not authorized. ErrorType: ${AppConsts.UNAUTHORIZED} ");
          //return authenticationRequestResponse;
        }
        else {
          //  Catch all other errors
          authenticationRequestResponse = AuthenticationRequestResponse(
              UserModel.getNullUser(),
              false,
              "Failed to authenticate user.",
              AppConsts.REFRESHED_TOKENS_FOR_USER_FAIL
          );
          debugPrint(
              "Unable to complete network refresh token for user. ErrorType: ${AppConsts
                  .REFRESHED_TOKENS_FOR_USER_FAIL} ");
          //return authenticationRequestResponse;
        }
      }else{
        // No network detected
        authenticationRequestResponse = AuthenticationRequestResponse(UserModel.getNullUser(),
            false,
            "Please check network",
            AppConsts.NO_NETWORK_SERVICE
        );
        debugPrint('Could not detect network while attempting to login: ${AppConsts.NO_NETWORK_SERVICE}');
      }
    });

    return authenticationRequestResponse;
  }



  //  We're using jwt tokens, which is stateless, we just need to remove the
  //  stored token and clear all settings

  UserModel _updateUser(
      LoginModel userData,
      DateTime loginTimeStamp,
      String rToken,
      DateTime tokenExpiry){
    var user = UserModel(
      userData.id,
      userData.firstName,
      userData.lastName,
      userData.jwtToken,/* short lived JWT access token */
      userData.photo,
      userData.emailAddress,
      userData.mobileNumber,
      userData.distanceUnit,
      AuthStatus.signedIn,
      loginTimeStamp,/* login timestamp */
      rToken, /* refreshToken*/
      tokenExpiry,/* RefreshToken expiry */);
    return user;
  }

  /// Sign out current user is not null and is logged in.
  /// Removes stored token and clears local storage
  Future<void> signOut()  async{
    // This is a future that is not being handled correctly
    await LocalStorageService.deleteUser();
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