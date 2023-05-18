import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod/riverpod.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final firebaseAuth = FirebaseAuth.instance;
  return AuthRepository(firebaseAuth: firebaseAuth);
});

class AuthRepository {
  final FirebaseAuth firebaseAuth;

  AuthRepository({required this.firebaseAuth});

  Future<UserCredential> signInAnonymously() async {
    return await firebaseAuth.signInAnonymously();
  }

  Future<User?> getCurrentUserId() async {
    final User? currentUser = firebaseAuth.currentUser;
    return currentUser;
  }
  Future<void>upDateHourlyWage(String uid,int hourlyWage)async{
    final profileRef = FirebaseFirestore.instance.collection('Users').doc(uid);
    profileRef.update({'時給': hourlyWage});
  }

  Future<User?> updateEmailAndSendVerificationEmail(String newEmail) async {
    final currentUser = firebaseAuth.currentUser;
    try {
      await currentUser?.updateEmail(newEmail);
      await currentUser?.sendEmailVerification();
    } catch (e) {
      debugPrint(e.toString());
    }

    final newCurrentUser = firebaseAuth.currentUser;

    return newCurrentUser;
  }

  Future<User?> nameUpdate(String name) async {
    final credential = firebaseAuth.currentUser;
    final uid = credential!.uid;
    final profileRef = FirebaseFirestore.instance.collection('Users').doc(uid);
    profileRef.update({'name': name});
    await credential.updateDisplayName(name);
    final credentialRe = firebaseAuth.currentUser;

    return credentialRe;
  }

  Future<User?> imageUpdate(String image) async {
    final credential = firebaseAuth.currentUser;
    final uid = credential!.uid;
    final profileRef = FirebaseFirestore.instance.collection('Users').doc(uid);

    await credential.updatePhotoURL(image);
    profileRef.update({'image': image});
    final credentialRe = firebaseAuth.currentUser;
    return credentialRe;
  }

  Future<User?> fileUpdate(File file) async {
    final credential = firebaseAuth.currentUser;
    final uid = credential!.uid;
    final profileRef = FirebaseFirestore.instance.collection('Users').doc(uid);
    // final storageRef =
    // FirebaseStorage.instance.ref().child('Users/$uid/profile');
    // final task = await storageRef.putFile(file);
    credential.updatePhotoURL(uid);
    profileRef.update({'image': uid});
    final credentialRe = firebaseAuth.currentUser;
    return credentialRe;
  }

  Future getHourlyWage(String uid) async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('Users').doc(uid).get();
    return querySnapshot.data()!['時給'] as int;
  }

  Future<String> nameSearch(String name) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .where('name', isEqualTo: name)
        .limit(1)
        .get();

    if (querySnapshot.size == 0) {
      // ドキュメントが存在しない場合
      return "Data does not exist.";
    } else {
      // ドキュメントが存在する場合
      final doc = querySnapshot.docs[0];
      return doc.id;
    }
  }

  Future<bool> passwordCheck(String uid, String password) async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('Users').doc(uid).get();
    return password == querySnapshot.data()!['password'];
  }

  Future<User?> name(String name, String password) async {
    final credential = firebaseAuth.currentUser;
    String uid = credential!.uid;
    final DocumentReference<Map<String, dynamic>> profileRef =
        FirebaseFirestore.instance.collection('Users').doc(uid);
    profileRef.set({'name': name, 'password': password});

    final credential2 = firebaseAuth.currentUser;
    await credential2!.updateDisplayName(name);
    final credentialRe = firebaseAuth.currentUser;

    return credentialRe;
  }

  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final credential = await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await credential.user!.sendEmailVerification();

    return credential;
  }

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }

  Future<bool> isSignedIn() async {
    final currentUser = firebaseAuth.currentUser;
    return currentUser != null;
  }

  Future<bool> isEmailVerified() async {
    final currentUser = firebaseAuth.currentUser;
    await currentUser?.reload();
    return currentUser?.emailVerified ?? false;
  }

  Future<void> sendEmailVerification() async {
    final currentUser = firebaseAuth.currentUser;
    await currentUser?.sendEmailVerification();
  }

  Future<void> resetPassword(String email) async {
    await firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<User?> switchToPermanentAccount({
    required String email,
    required String password,
  }) async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint(e.toString());
      return null;
    }
    return firebaseAuth.currentUser;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await firebaseAuth.sendPasswordResetEmail(email: email);
  }
}
