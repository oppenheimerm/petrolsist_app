import 'package:flutter/material.dart';

import '../app_constants.dart';
import '../service/authentication/auth_provider.dart';
import 'login_page.dart';
import 'main_page.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<StatefulWidget> createState() => _RootPageState();
}


class _RootPageState extends State<RootPage> {
  //  init page
  AuthStatus authStatus = AuthStatus.notDetermined;


  //  Called when a dependency of this State object changes
  //  see: https://docs.flutter.io/flutter/widgets/SingleTickerProviderStateMixin/didChangeDependencies.html
  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    var auth = AuthProvider.of(context).auth;
    auth.currentUser().then((user) {
      setState(() {
        authStatus = (user?.id == null  || user!.id.isEmpty) ? AuthStatus.notSignedIn : AuthStatus.signedIn;
      });
    });
  }

  void _signedIn() {
    setState(() {
      authStatus = AuthStatus.signedIn;
    });
  }

  void _signedOut() {
    setState(() {
      authStatus = AuthStatus.notSignedIn;
    });
  }


  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.notDetermined:
        return _buildWaitingScreen();
      case AuthStatus.notSignedIn:
        return LoginPage(
            onSignedIn: _signedIn
        );
      case AuthStatus.signedIn:
        return MainPage(
          onSignedOut: _signedOut,
          authStatus: AuthStatus.signedIn,
        );
    }
  }

  Widget _buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      ),
    );
  }
}