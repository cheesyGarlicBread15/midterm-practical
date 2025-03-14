import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:midterm_practice/screens/home_screen.dart';
import 'package:midterm_practice/screens/login_screen.dart';
import 'package:midterm_practice/screens/register_screen.dart';
import 'package:midterm_practice/screens/set_details_screen.dart';

class AppRoutes {
  static Route? onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/set-details':
        if (args is User) {
          return MaterialPageRoute(builder: (context) => SetDetailsScreen(user: args));
        }
      default:
        return null;
    }
    return null;
  }

  static Route _errorRoute(String? name) {
    return MaterialPageRoute(builder: (context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: Center(
          child: Text('No route defined for $name'),
        ),
      );
    });
  }
}
