import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod/riverpod.dart';

import '../repository/auth_repository.dart';

final authViewModelProvider = StateNotifierProvider<AuthViewModel, User?>(
  (ref) => AuthViewModel(authRepository: ref.watch(authRepositoryProvider)),
);

class AuthViewModel extends StateNotifier<User?> {
  final AuthRepository authRepository;

  AuthViewModel({required this.authRepository}) : super(null);

  Future<User?> signInAnonymously() async {
    try {
      final credential = await authRepository.signInAnonymously();
      state = credential.user;
      return credential.user!;
    } on FirebaseAuthException catch (e) {
      // Handle the error.
    }
  }

  Future<void>upDateHourlyWage(String uid,int hourlyWage)async{
    await authRepository.upDateHourlyWage(uid,hourlyWage);
  }

  Future<bool> passwordCheck(String uid,String password,) async {

    return await authRepository.passwordCheck(uid,password);

  }


  Future<String> nameSearch(String name) async {
    try {
      return await authRepository.nameSearch(name);
    } on FirebaseAuthException catch (e) {
      return (e.code);
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      final credential = await authRepository.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      // Handle the error.
    }
  }

  Future<void> name(String name, String password) async {
    state = await authRepository.name(name, password);
  }

  Future<void> nameUpdate(String name) async {
    state = await authRepository.nameUpdate(name);
  }

  Future<void> imageUpdate(String image) async {
    state = await authRepository.imageUpdate(image);
  }

  Future<void> fileUpdate(File file) async {
    state = await authRepository.fileUpdate(file);
  }

  Future<void> readProfile() async {
    state = await authRepository.getCurrentUserId();
  }

  Future<bool> isEmailVerified() async {
    bool isEmailVerified = await authRepository.isEmailVerified();
    state = await authRepository.getCurrentUserId();
    return isEmailVerified;
  }

  Future<bool> updateEmailAndSendVerificationEmail(String email) async {
    try {
      final user =
          await authRepository.updateEmailAndSendVerificationEmail(email);
      state = user;
      return false;
    } on FirebaseAuthException catch (e) {
      return true;
    }
  }

  Future<bool> signUpWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      final credential = await authRepository.signUpWithEmailAndPassword(
          email: email, password: password);
      state = credential.user;
      return false;
    } on FirebaseAuthException catch (e) {
      return true;
    }
  }

  Future<String> signInWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      await authRepository.signOut();
      final credential = await authRepository.signInWithEmailAndPassword(
          email: email, password: password);
      state = credential.user;
      return '成功';
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          return 'メールアドレスの形式が正しくありません。';
        case 'user-disabled':
          return 'このアカウントは無効になっています。';
        case 'user-not-found':
          return 'このメールアドレスに対応するアカウントが見つかりません。';
        case 'wrong-password':
          return 'パスワードが正しくありません。';
        case 'too-many-requests':
          return '何度もパスワードを間違えたため、アカウントが一時的にロックされました。後でもう一度お試しください。';
        default:
          return '予期せぬエラーが発生しました。';
      }
    }
  }

  Future<void> signOut() async {
    try {
      await authRepository.signOut();
    } on FirebaseAuthException catch (e) {}
  }

  Future<bool> switchToPermanentAccount(
      {required String email, required String password}) async {
    try {
      final user = await authRepository.switchToPermanentAccount(
          email: email, password: password);
      state = user;
      return false;
    } on FirebaseAuthException catch (e) {
      print(e);
      return true;
    }
  }

  Future<String> sendPasswordResetEmail(String email) async {
    try {
      await authRepository.sendPasswordResetEmail(email);
      return '成功';
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          return 'メールアドレスの形式が正しくありません。';
        case 'user-disabled':
          return 'このアカウントは無効になっています。';
        case 'user-not-found':
          return 'このメールアドレスに対応するアカウントが見つかりません。';
        case 'wrong-password':
          return 'パスワードが正しくありません。';
        case 'too-many-requests':
          return '何度もパスワードを間違えたため、アカウントが一時的にロックされました。後でもう一度お試しください。';
        default:
          return '予期せぬエラーが発生しました。';
      }
    }
  }
}
