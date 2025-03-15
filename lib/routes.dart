import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:midterm_practice/model/profile_model.dart';
import 'package:midterm_practice/screens/forgot_password_screen.dart';
import 'package:midterm_practice/screens/home_screen.dart';
import 'package:midterm_practice/screens/login_screen.dart';
import 'package:midterm_practice/screens/profile_screen.dart';
import 'package:midterm_practice/screens/register_screen.dart';
import 'package:midterm_practice/screens/set_details_screen.dart';

class AppRoutes {
  static Route? onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/register':
        if (args == true) {
          return MaterialPageRoute(builder: (context) => const RegisterScreen(addUser: true,));
        } else {
          return MaterialPageRoute(builder: (context) => const RegisterScreen(addUser: false,));
        }
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/set-details':
        if (args is User) {
          return MaterialPageRoute(builder: (context) => SetDetailsScreen(user: args));
        }
      case '/profile-screen':
        if (args is ProfileModel) {
          return MaterialPageRoute(builder: (context) => ProfileScreen(profileModel: args,));
        }
      case '/forgot-password':
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
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
