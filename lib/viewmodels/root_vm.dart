import 'package:flutter/foundation.dart';
import 'package:petrolsist_app/models/user.dart';

import '../app_constants.dart';

class RootPageVM extends ChangeNotifier{

  AuthStatus _authStatus = AuthStatus.notDetermined;
  late final UserModel? _user;

  void setUser(UserModel? user){
    _user = user;
    _user?.authStatus = (_user.jwtToken.isEmpty  || _user.id.isEmpty) ? AuthStatus.notSignedIn : AuthStatus.signedIn;
    notifyListeners();
  }

  UserModel? getUser(){
    return _user;
  }

  AuthStatus getUserAuthStatus(){
    return _authStatus;
  }

  void signedIn() {
    _authStatus = AuthStatus.signedIn;
    //  notifies UI that some variable is changed, and rebuild your UI, according to the changes.
    notifyListeners();
  }

  void signedOut() {
    _authStatus = AuthStatus.notSignedIn;
    notifyListeners();
  }

  // Set status
  /*void setStatus(UserModel? user){
    var status =  (user?.id == null  || user!.id.isEmpty) ? AuthStatus.notSignedIn : AuthStatus.signedIn;
    notifyListeners();
  }*/

  AuthStatus getUserStatus(){
    return _authStatus;
  }


}