import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:midterm_practice/model/profile_model.dart';
import 'package:midterm_practice/repository/profile_repository.dart';

class AuthService {
  final _profileRepository = ProfileRepository();

  Future<(bool, String?)> register({
    required ProfileModel profile,
  }) async {
    try {
      // Auth
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: profile.email, password: profile.password);

      // Firestore
      await ProfileRepository().createProfile(profile);
      return (true, null);
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'The account already exists for that email';
          break;
        case 'weak-password':
          message = 'The password provided is too weak';
          break;
        case 'invalid-email':
          message = 'The email address is not valid';
          break;
        default:
          message = 'An error occurred: ${e.code}';
      }
      print(message);
      return (false, message);
    } catch (e) {
      print(e.toString());
      return (false, 'Failed to create profile: ${e.toString()}');
    }
  }

  Future<(bool, String?)> login({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      return (true, null);
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'user-not-found') {
        message = 'No user found for that email';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided for that user';
      }
      print(message);
      return (false, message);
    }
  }

  Future<void> signout({
    required BuildContext context
  }) async {
    await FirebaseAuth.instance.signOut();
  }
}
