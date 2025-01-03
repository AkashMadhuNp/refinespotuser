import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';


class AuthException implements Exception {
  final String message;
  final String? code;
  
  AuthException(this.message, {this.code});
  
  @override
  String toString() => message;
}

String _getFirebaseAuthErrorMessage(String code) {
  switch (code) {
    case 'user-not-found':
      return 'No account found with this email.';
    case 'wrong-password':
      return 'Incorrect password.';
    case 'invalid-email':
      return 'Invalid email format.';
    case 'user-disabled':
      return 'This account has been disabled.';
    case 'too-many-requests':
      return 'Too many failed attempts. Please try again later.';
    default:
      return 'Authentication failed: $code';
  }

}


class AuthServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

 Future<String> signUpUser({
  required String email,
  required String password,
  required String username,
  required int phone,
}) async {
  try {
    // Create the user in Firebase Auth
    UserCredential credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Add user to Firestore database
    await _firestore.collection("users").doc(credential.user!.uid).set({
      'name': username,
      'email': email,
      'phone': phone,
      'uid': credential.user!.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return "success";
  } on FirebaseAuthException catch (e) {
    
    return e.message ?? "Authentication error occurred";
  } on FirebaseException catch (e) {
    
    return e.message ?? "Database error occurred";
  } catch (e) {
    
    return e.toString();
  }
}

  Future<User?> loginUserWithEmailAndPassword(String email, String password) async {
  try {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    // Update last login time
    if (credential.user != null) {
      await _firestore.collection("users").doc(credential.user!.uid).set({
        'lastLogin': FieldValue.serverTimestamp(),
        'email': credential.user!.email,
        'uid': credential.user!.uid,
      }, SetOptions(merge: true));
    }
    
    return credential.user;
  } on FirebaseAuthException catch (e) {
    // Pass both the message AND the code to AuthException
    throw AuthException(
      _getFirebaseAuthErrorMessage(e.code),
      code: e.code  // Make sure your AuthException class accepts this parameter
    );
  } catch (e) {
    throw AuthException(
      'Failed to sign in: ${e.toString()}',
      code: 'unknown-error'  // Provide a default error code
    );
  }
}

  




Future<User?> signInWithGoogle(BuildContext context) async {
    try {
      // Sign out from any previous session
      await _googleSignIn.signOut();
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
      
      // If sign in was cancelled by user
      if (googleSignInAccount == null) {
        return null;
      }

      // Obtain auth details from request
      final GoogleSignInAuthentication googleSignInAuthentication = 
          await googleSignInAccount.authentication;

      // Create new credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken,
      );

      // Sign in with credential
      UserCredential result = await _auth.signInWithCredential(credential);
      User? userDetails = result.user;

      // If sign in successful
      if (userDetails != null) {
        // Store user details in Firestore
        await _firestore.collection("users").doc(userDetails.uid).set({
          'name': userDetails.displayName ?? 'Unknown',
          'email': userDetails.email ?? '',
          'uid': userDetails.uid,
          'lastLogin': FieldValue.serverTimestamp(),
          'provider': 'google',
          'emailVerified': userDetails.emailVerified,
        }, SetOptions(merge: true));

        return userDetails;
      }
      
      return null;

    } catch (error) {
      print("Error signing in with Google: $error");
      rethrow; // Rethrow to be handled by the bloc
    }
  }



  

  Future<void> sendPasswordResetLink(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getFirebaseAuthErrorMessage(e.code),code:  e.code);
    } catch (e) {
      throw AuthException('Failed to send reset link: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw AuthException('Failed to sign out: ${e.toString()}');
    }
  }


  String _getDetailedGoogleSignInError(String code) {
    switch (code) {
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email address but different sign-in credentials. Please sign in using the appropriate provider.';
      case 'invalid-credential':
        return 'The authentication credential is invalid. Please try signing in again.';
      case 'operation-not-allowed':
        return 'Google sign-in is not enabled for this project. Please contact support.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No user found for this Google account.';
      default:
        return 'Authentication failed: $code';
    }


  
  
}}