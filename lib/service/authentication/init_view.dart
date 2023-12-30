import 'package:petrolsist_app/service/authentication/authentication_service.dart';
import '../../models/user.dart';

class InitViewService{

  final AuthenticationService _authenticationService = AuthenticationService();


  // Concise way to define a getter method named "getUserData()" by calling the
  // "getUser()" method from an instance of the "UserViewModel" class
  Future<UserModel?> getUserData() async => await _authenticationService.currentUser();
}