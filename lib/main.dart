
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:petrolsist_app/pages/page_root.dart';
import 'package:petrolsist_app/service/authentication/auth_provider.dart';
import 'package:petrolsist_app/service/authentication/authentication_service.dart';
import 'package:petrolsist_app/service/locator.dart';



Future<void> requestMapsPermission() async{
  await Permission.locationWhenInUse.isDenied.then((value) {
    // if denied vale == true
    if(value){
      Permission.locationWhenInUse.request();
    }
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //setupLocator();
  await setupLocator();
  await requestMapsPermission();
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return AuthProvider(
      auth: AuthenticationService(),
      key: key,
      child: MaterialApp(
        title: 'PetrolSist',
        //  hide Banner
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          primarySwatch: Colors.blue,
        ),
        home: const RootPage(),
      ),
    );
  }
}