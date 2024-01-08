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
  Future<OperationStatus?> authenticateUser(
      String username,
      String password) async {

    OperationStatus status = OperationStatus(false, "Could not complete login", AppConsts.COULD_NOT_AUTHENTICATE_USER);
    //  Do we have network connectivity?
    await _networkService.psGetNetworkStatus().then((value) async {

      if(value){
        //  Connection Ok, send login
        await _authenticationService.requestLoginAPI
          (username, password).then((value) {
          status = value;
        });

      }
      else{
        // Could not connect to network
        status = OperationStatus(false, "Could not detect network", AppConsts.NO_NETWORK_SERVICE);
        debugPrint('Could not detect network while attempting to login: ${AppConsts.NO_NETWORK_SERVICE}');
      }

    });
    return status;

  }
  //  Future<OperationStatus> registerUser(){}
}