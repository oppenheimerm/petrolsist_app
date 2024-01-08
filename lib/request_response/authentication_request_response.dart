
import 'package:petrolsist_app/models/user.dart';
import 'operation_status.dart';

class AuthenticationRequestResponse extends OperationStatus{
  UserModel? user;
  AuthenticationRequestResponse(UserModel user, super.success, super.errorMessage, super.errorType);
}