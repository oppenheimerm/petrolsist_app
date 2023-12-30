import 'package:flutter/material.dart';
import 'package:petrolsist_app/app_constants.dart';

import '../models/user.dart';
import '../service/authentication/authentication_service.dart';

class UserViewModel with ChangeNotifier {

  final AuthenticationService _authenticationService = AuthenticationService();

  Future<UserModel?> getCurrentUser() async{
    return await _authenticationService.currentUser();
  }

  void checkAuthentication(BuildContext context) async{
    await getCurrentUser().then((value) async {

      //  TODO
      //  This function should be waiting until the token refresh
      //  attempt is made, but it is NOT??

      if (value?.authStatus == AuthStatus.notSignedIn || value?.authStatus == AuthStatus.notSignedIn
      || value?.jwtToken == null || value?.jwtToken == "") {
        //  We're logged in, redirect to login page
        await Navigator.pushReplacementNamed(context, AppConsts.rootLogin);
      } else {
        await Navigator.pushReplacementNamed(context, AppConsts.rootHome);
      }
    }).onError((error, stackTrace) => throw Exception(error.toString()));
  }

  void logout(){
    _authenticationService.signOut();
  }
}