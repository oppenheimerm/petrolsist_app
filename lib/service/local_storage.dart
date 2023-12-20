
//  This service will use the Singleton pattern and instances will
//  be retrieved through a getInstance() static function. We’ll
//  keep a static instance of the SharedPreferences as well as the
//  instance for our service.
//
//  https://www.filledstacks.com/snippet/shared-preferences-service-in-flutter-for-code-maintainability/
import 'package:shared_preferences/shared_preferences.dart';
import '../app_constants.dart';
import '../models/user.dart';
import '../request_response/operation_status.dart';

class LocalStorageService {
  static LocalStorageService? _instance;
  static SharedPreferences? _preferences;


  //  Where '??=' is a null aware operator.  Dart offers
  //  this handy operators for dealing with values that
  //  might be null. The ??= assignment operator, which
  //  assigns a value to a variable only if that variable
  //  is currently null.  Not that our return type is
  //  also nullable(LocalStorageService?)
  //
  //  https://dart.dev/codelabs/dart-cheatsheet
  static Future<LocalStorageService?> getInstance() async {
    _instance ??= LocalStorageService();

    _preferences ??= await SharedPreferences.getInstance();

    return _instance;
  }

  //  Check valid parameters passed in debug
  /*static UserTokens getUserTokens(){
    var timeStamp = (( _preferences?.getString(AppConsts.loginTimeStamp) != null)
        ? DateTime.parse( _preferences!.getString( AppConsts.loginTimeStamp )! )
        : null);
    var refreshTokenExpiry = (( _preferences?.getString(AppConsts.refreshTokenExpiry) != null)
        ? DateTime.parse( _preferences!.getString( AppConsts.refreshTokenExpiry )! )
        : null);

    return UserTokens(
      (_preferences?.getString( AppConsts.jwtToken) ?? ""),
      timeStamp,
      _preferences?.getString( AppConsts.refreshToken),
      refreshTokenExpiry
    );
  }*/

  static Future<UserModel?> getUserFromDisk() async {
  try{
    //  To guard access to a property or method of an object that might be null,
    //  put a question mark (?) before the dot (.):

    var authStatus = ((_preferences?.getString( AppConsts.authStatus) != null)
        ? authStatusFromString( _preferences!.getString( AppConsts.authStatus)! )
        : AuthStatus.notSignedIn);

    var timeStamp = (( _preferences?.getString(AppConsts.loginTimeStamp) != null)
        ? DateTime.parse( _preferences!.getString( AppConsts.loginTimeStamp )! )
        : null);

    //var expTime =  _preferences?.getString(AppConsts.refreshTokenExpiry);
    var refreshTokenExpiry = (( _preferences?.getString(AppConsts.refreshTokenExpiry) != null)
        ? DateTime.parse( _preferences!.getString( AppConsts.refreshTokenExpiry )! )
        : null);

    var user = UserModel(
      (_preferences?.getString( AppConsts.userId) ?? "" ),
      (_preferences?.getString( AppConsts.firstName) ?? ""),
      (_preferences?.getString( AppConsts.lastName) ?? ""),
      (_preferences?.getString( AppConsts.jwtToken) ?? ""),
      (_preferences?.getString( AppConsts.initials) ?? ""),
      (_preferences?.getString( AppConsts.photo) ?? ""),
      (_preferences?.getString( AppConsts.emailAddress) ?? ""),
      authStatus,
      timeStamp,
      _preferences?.getString( AppConsts.refreshToken),
      refreshTokenExpiry,
    );

    return user;
  }catch(err){// Let's see what this error is before deleting the user...
    //  delete data, as it's probably corrupt or there's some other
    //  error.

    await deleteUser();
    return UserModel.getNullUser();
  }
  }



  static Future<OperationStatus> deleteUser() async {
    try {
      await _preferences?.remove( AppConsts.userId);
      await _preferences?.remove( AppConsts.firstName);
      await _preferences?.remove( AppConsts.lastName);
      await _preferences?.remove( AppConsts.jwtToken);
      await _preferences?.remove( AppConsts.initials);
      await _preferences?.remove( AppConsts.photo);
      await _preferences?.remove( AppConsts.emailAddress);
      await _preferences?.remove( AppConsts.authStatus);
      await _preferences?.remove( AppConsts.loginTimeStamp);
      await _preferences?.remove( AppConsts.refreshToken);
      await _preferences?.remove( AppConsts.refreshTokenExpiry);
      return OperationStatus(true, "Successfully deleted user.");
    } catch (err) {
      return OperationStatus(false, "Delete operation failed.");
    }
  }

  /*static Future<OperationStatus> updateRefreshTokensForUser(
      String jwtToken,
      DateTime loginTimeStamp,
      String refreshToken,
      DateTime refreshTokenExpiry
      ) async{
    try{
      await _preferences?.setString( AppConsts.jwtToken, jwtToken);
      await _preferences?.setString( AppConsts.loginTimeStamp, loginTimeStamp.toString());
      await _preferences?.setString( AppConsts.refreshToken, refreshToken);
      await _preferences?.setString( AppConsts.refreshTokenExpiry, AppConsts.refreshTokenExpiry.toString());

      return OperationStatus(true, 'Successfully updated refresh data.');
    }catch(err){
      return OperationStatus(false, 'Unable to refresh user data: $err.');
    }
  }*/

  static Future<OperationStatus> persistUser(UserModel userToSave) async {
    try {

      await _preferences?.setString( AppConsts.userId, userToSave.id);
      await _preferences?.setString( AppConsts.firstName, userToSave.firstName);
      await _preferences?.setString( AppConsts.lastName, userToSave.lastName);
      await _preferences?.setString( AppConsts.jwtToken, userToSave.jwtToken);
      await _preferences?.setString( AppConsts.initials, userToSave.initials);
      await _preferences?.setString( AppConsts.photo, userToSave.photo);
      await _preferences?.setString( AppConsts.emailAddress, userToSave.emailAddress);
      await _preferences?.setString( AppConsts.authStatus, userToSave.authStatus.toString());
      await _preferences?.setString( AppConsts.loginTimeStamp, userToSave.loginTimeStamp.toString());
      //  Mske ure below is not null
      await _preferences?.setString( AppConsts.refreshToken, userToSave.refreshToken.toString());
      await _preferences?.setString( AppConsts.refreshTokenExpiry, userToSave.refreshTokenExpiry.toString());

      return OperationStatus(true, 'Successfully saved user data.');
    } catch (err) {
      return OperationStatus(false, err.toString());
    }
  }

  static OperationStatus saveStringToDisk(String key, String content) {

    //_preferences.setString(UserKey, content);
    //  To guard access to a property or method of an object that might be null,
    //  put a question mark (?) before the dot (.):
    try {
      _preferences?.setString(key, content);
      return OperationStatus(true, 'Save user with $key and valie: $content');
    } catch (err) {
      return OperationStatus(false, 'Could not save data with $key.');
    }
  }
}