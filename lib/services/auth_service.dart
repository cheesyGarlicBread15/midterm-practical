import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:midterm_practice/model/profile_model.dart';
import 'package:midterm_practice/repository/profile_repository.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final _profileRepository = ProfileRepository();
  static String? currentEmail, currentPassword;

  Future<(bool, String?)> register({
    required ProfileModel profile,
  }) async {
    try {
      // Auth
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: profile.email, password: profile.password);

      // Add uid to profile
      final updatedProfile = profile.copyWith(
        uid: userCredential.user?.uid, // Get uid from auth
      );

      // Firestore
      await _profileRepository.createProfile(updatedProfile);
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

  Future<(bool, String?)> logout() async {
    try {
      // Sign out from Firebase
      await _firebaseAuth.signOut();

      // Sign out from Google
      final GoogleSignIn googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }

      // Sign out from Facebook
      final AccessToken? fbAccessToken =
          await FacebookAuth.instance.accessToken;
      if (fbAccessToken != null) {
        await FacebookAuth.instance.logOut();
      }
      return (true, null);
    } catch (e) {
      print('Error during sign out: $e');
      return (false, 'Failed to sign out: ${e.toString()}');
    }
  }

  Future<(bool, String?, UserCredential?)> signInWithGoogle() async {
    try {
      // Start Google Sign In process
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

      // User canceled the sign-in
      if (gUser == null) {
        return (false, 'Sign in canceled by user', null);
      }

      // Get auth details
      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      // Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      return (true, null, userCredential);
    } on FirebaseAuthException catch (e) {
      String message = 'Google sign in failed: ${e.message}';
      print(message);
      return (false, message, null);
    } catch (e) {
      String message = 'Unexpected error during Google sign in: $e';
      print(message);
      return (false, message, null);
    }
  }

  Future<(bool, String?, UserCredential?)> signInWithFacebook() async {
    try {
      await FacebookAuth.instance.logOut();
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;
        final AuthCredential credential =
            FacebookAuthProvider.credential(accessToken.tokenString);

        final userCredential =
            await _firebaseAuth.signInWithCredential(credential);
        return (true, null, userCredential);
      } else {
        return (false, 'Facebook sign in failed: ${result.message}', null);
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Facebook sign in failed: ${e.message}';
      print(message);
      return (false, message, null);
    } catch (e) {
      String message = 'Unexpected error during Facebook sign in: $e';
      print(message);
      return (false, message, null);
    }
  }

  Future<(bool, String?, UserCredential?)> signInWithGithub() async {
    try {
      await _firebaseAuth.signOut();

      // Create a GitHub auth provider
      GithubAuthProvider githubAuthProvider = GithubAuthProvider();

      // Sign in with GitHub
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithProvider(githubAuthProvider);

      return (true, null, userCredential);
    } on FirebaseAuthException catch (e) {
      return (false, e.message, null);
    } catch (e) {
      return (false, 'Unexpected error during GitHub sign in: $e', null);
    }
  }
}
