import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

class AuthService extends GetxService {
  // Use a getter for FirebaseAuth to prevent access before initialization
  FirebaseAuth get _auth {
    try {
      return FirebaseAuth.instance;
    } catch (e) {
      debugPrint(
        'FirebaseAuth.instance accessed before initialization or failed: $e',
      );
      rethrow;
    }
  }

  late final GoogleSignIn _googleSignIn;
  Rx<User?> user = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();

    // Platform protection: Only initialize on supported platforms
    if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
      _googleSignIn = GoogleSignIn();
    }

    // Safety check: only bind if Firebase is actually initialized
    try {
      user.bindStream(_auth.authStateChanges());
    } catch (e) {
      debugPrint('Could not bind auth state stream: $e');
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (!kIsWeb && Platform.isWindows) {
        _showError(
          'Platform Error',
          'Google Sign-In is not supported on Windows.',
        );
        return null;
      }

      // Check if Firebase is initialized
      try {
        _auth; // Access the getter to check
      } catch (e) {
        _showError(
          'Firebase Error',
          'Firebase is not initialized. Please restart the app.',
        );
        return null;
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      _showError('Authentication Error', e.message ?? 'Sign-in failed.');
      return null;
    } catch (e) {
      _showError(
        'Login Error',
        'An unexpected error occurred: ${e.toString()}',
      );
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
        await _googleSignIn.signOut();
      }
      await _auth.signOut();
    } catch (e) {
      _showError('Logout Error', 'Failed to sign out properly.');
    }
  }

  void _showError(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
    );
  }
}
