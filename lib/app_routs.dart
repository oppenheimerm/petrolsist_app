import 'package:flutter/material.dart';
import 'package:petrolsist_app/app_constants.dart';
import 'package:petrolsist_app/views/home_view.dart';
import 'package:petrolsist_app/views/login_view.dart';
import 'package:petrolsist_app/views/route_not_found.dart';
import 'package:petrolsist_app/views/signup_view.dart';
import 'package:petrolsist_app/views/splash_view.dart';


class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppConsts.rootSplash:
        return MaterialPageRoute(
          builder: (context) => const SplashView(),
        );
      case AppConsts.rootLogin:
        return MaterialPageRoute(
          builder: (context) => const LoginView(),
        );
      case AppConsts.rootHome:
        return MaterialPageRoute(
          builder: (context) => const HomeView(),
        );
      case AppConsts.rootSignup:
        return MaterialPageRoute(
          builder: (context) => const SignUpView(),
        );
      default:
        return MaterialPageRoute(
          builder: (context) => const NotFoundView(),
        );
    }
  }
}
