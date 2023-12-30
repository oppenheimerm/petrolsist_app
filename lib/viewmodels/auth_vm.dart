import 'package:flutter/material.dart';
import '../app_constants.dart';
import '../request_response/operation_status.dart';
import '../service/authentication/authentication_service.dart';
import '../service/network_service.dart';



class AuthViewModel with ChangeNotifier {

  late final PSNetworkService _networkService = PSNetworkService();
  final AuthenticationService _authenticationService = AuthenticationService();

  bool _loginLoading = false;
  bool _signUpLoading = false;

  // Getter Methods
  bool get loginLoading => _loginLoading;
  bool get signUpLoading => _signUpLoading;

  // Setter Methods
  void setLoginLoading(bool newBool) {
    _loginLoading = newBool;
    notifyListeners();
  }

  void setSignUpLoading(bool newBool) {
    _signUpLoading = newBool;
    notifyListeners();
  }

  //  Future loginApi(dynamic data, BuildContext context) async
  Future<OperationStatus> authenticateUser(String username, String password) async {

    //  Do we have network connectivity?
    var status = await _networkService.psGetNetworkStatus();
    if (status == true) {
      // Set the login loading state to true to show the loading indicator.
      setLoginLoading(true);

      var authRequestResponse = await _authenticationService.requestLoginAPI(
          username, password);
      if (authRequestResponse.success) {
        //  head home
        setLoginLoading(false);
        return OperationStatus(
            true, "Login Successful", AppConsts.OPERATION_SUCCESS);
      } else {
        return OperationStatus(
            false, "", AppConsts.USER_NOT_FOUND
        );
      }
    }
    else{
      return OperationStatus(false, "Please check your network connection", AppConsts.NO_NETWORK_SERVICE);
    }


  }

  //  Future<OperationStatus> registerUser(){}
}