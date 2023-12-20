import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
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

  //Kew Gardens / TW9 3JR (51.4777125 , -0.2882984)
  static const CameraPosition _keyGardens = CameraPosition(
    target: LatLng(51.4777125 , -0.2882984),
    zoom: 14.4746,
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
