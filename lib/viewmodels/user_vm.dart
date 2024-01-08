import 'package:flutter/material.dart';
import 'package:petrolsist_app/app_constants.dart';
import 'package:petrolsist_app/request_response/authentication_request_response.dart';

import '../models/user.dart';
import '../service/authentication/authentication_service.dart';
import '../utilities/utils.dart';

class UserViewModel with ChangeNotifier {

  final AuthenticationService _authenticationService = AuthenticationService();

  Future<AuthenticationRequestResponse> getCurrentUser() async{
    return await _authenticationService.currentUser();
  }

  void checkAuthentication(BuildContext context) async{
    await getCurrentUser().then((value) async {

      //  TODO
      //  This function should be waiting until the token refresh
      //  attempt is made, but it is NOT??
      if(value.success)
        {
          await Navigator.pushReplacementNamed(context, AppConsts.rootHome);
        }
      else{
        var errorMessage = (value.errorMessage != null) ? value.errorMessage : "Please login.";
        Utils.snackBar(errorMessage!, context);
        await Navigator.pushReplacementNamed(context, AppConsts.rootLogin);
      }
    }).onError((error, stackTrace) => throw Exception(error.toString()));
  }

  void logout(){
    _authenticationService.signOut();
  }
}