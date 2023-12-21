import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../app_constants.dart';
import '../helpers.dart';
import '../service/authentication/auth_provider.dart';
import 'login_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.onSignedOut, required this.authStatus});

  final VoidCallback onSignedOut;
  final AuthStatus? authStatus;


  @override
  State<MainPage> createState() => _MainPageState();


  void _signOut(BuildContext context) async {
    try {
      var auth = AuthProvider.of(context).auth;
      auth.signOut();
      onSignedOut();
    } catch (e) {
      print(e);
    }
  }
}


class _MainPageState extends State<MainPage> {

  AuthStatus authStatus = AuthStatus.notDetermined;
  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();
  MapStyleTheme mapStyleTheme = MapStyleTheme.night;
  bool isAppInitialized = false;
  Position? currentPositionOfUser;

  //Kew Gardens / TW9 3JR (51.4777125 , -0.2882984)
  static const CameraPosition _keyGardens = CameraPosition(
    target: LatLng(51.4777125 , -0.2882984),
    zoom: 15.0,
  );


  //  Called when a dependency of this State object changes.  For
  //  example, if the previous call to build referenced an
  //  InheritedWidget that later changed, the framework would call
  //  this method to notify this object about the change.
  //
  //  https://api.flutter.dev/flutter/widgets/State/didChangeDependencies.html
  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    var auth = AuthProvider
        .of(context)
        .auth;
    auth.currentUser().then((user) {
      setState(() {
        authStatus = (user?.id == null  || user!.id.isEmpty) ? AuthStatus.notSignedIn : AuthStatus.signedIn;
      });
    });
  }

  void updateMapTheme(GoogleMapController controller){
    Helpers.getThemeFile(mapStyleTheme).then((value) => setGoogleMapStyle(value!, controller));
  }

  void _signedIn() {
    setState(() {
      authStatus = AuthStatus.signedIn;
    });
  }

  // Allow user to change map style
  Future<void> _updateMapStyle(MapStyleTheme mapStyle, GoogleMapController controller) async {

    var newStyle = mapStyle;
    Helpers.getThemeFile(newStyle).then((value) => setGoogleMapStyle(value!, controller));
    // update view
    //mapStyleTheme
    setState(() {
      mapStyleTheme = newStyle;
    });
  }

  void setGoogleMapStyle(String googleMapStyle, GoogleMapController controller){
    controller.setMapStyle(googleMapStyle);
  }

  /*getUserCurrentLiveLocation() async{
    //  should test if location services are enabled:
    //  https://pub.dev/packages/geolocator
    var positionOfUser = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPositionOfUser = positionOfUser;

    LatLng latLngPositionOfUser = LatLng(currentPositionOfUser!.latitude, currentPositionOfUser!.longitude);
    //  animate the map to the current position of the user
    CameraPosition cameraPosition = CameraPosition(target: latLngPositionOfUser);
    _mapController
  }*/


  //  Can't call async methods in Build()
  Future<CameraPosition>getUserCurrentLocation(double zoomLevel) async{
    //  TODO
    //  should test if location services are enabled:
    //  https://pub.dev/packages/geolocator
    var positionOfUser = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPositionOfUser = positionOfUser;
    LatLng latLngPositionOfUser = LatLng(currentPositionOfUser!.latitude, currentPositionOfUser!.longitude);
    return CameraPosition(target: latLngPositionOfUser, zoom: zoomLevel);
  }

  /*setCurrentCameraPosition(LatLng target, double zoomLevel){
    return CameraPosition(target: target, zoom: zoomLevel);
  }*/


  @override
  Widget build(BuildContext context) {
    if (authStatus == AuthStatus.signedIn) {
      return Scaffold(
        body: Stack(
          children: <Widget>[
            GoogleMap(
              mapType: MapType.normal,
              myLocationButtonEnabled: true,
              initialCameraPosition: _keyGardens,
              onMapCreated: (GoogleMapController controller){
                updateMapTheme(controller);
                _mapController.complete(controller);
              },
            ),
          ],
        ),
      );
    }
    else {
      return LoginPage(
        onSignedIn: _signedIn,
      );
    }
  }
}
