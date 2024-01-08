import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:petrolsist_app/app_constants.dart';
import 'package:petrolsist_app/service/authentication/authentication_service.dart';

import '../helpers.dart';

class HomeViewModel with ChangeNotifier{

  MapStyleTheme mapStyleTheme;
  final AuthenticationService _authenticationService = AuthenticationService();
  bool _loadingMap = true;

  HomeViewModel(
    [this.mapStyleTheme = MapStyleTheme.night]
);


  void setGoogleMapStyle(String googleMapStyle, GoogleMapController controller){
    controller.setMapStyle(googleMapStyle);
    notifyListeners();
  }

  void updateMapTheme(GoogleMapController controller) async {
    try{
      /*
                await rootBundle.loadString(source).then((value) async {
              return value;
          });
      * */
      //Helpers.getThemeFile(mapStyleTheme).then((value) => setGoogleMapStyle(value, controller));


      await Helpers.getThemeFile(mapStyleTheme).then((value) {
        if(value != null)
          {
            setGoogleMapStyle(value, controller);
            notifyListeners();
          }
      });
    }
    catch(err){
      debugPrint('Error in home_vm.dart, line: 26: ${err.toString()}');
    }
  }

  void setLoadingState(bool state){
    _loadingMap = state;
    notifyListeners();
  }

  bool getLoadingState(){
    return _loadingMap;
  }

  void logout(BuildContext context) async{
    await _authenticationService.signOut().then((value) {
      Navigator.pushReplacementNamed(context, AppConsts.rootLogin);
    });
  }

}