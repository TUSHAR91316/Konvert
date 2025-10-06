import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
class  AuthService{
  final  _auth = FirebaseAuth.instance;
  Future<User?> createUserWithEmailAndPassword(
      String email, String password) async {
         try{
           final cred=await _auth.createUserWithEmailAndPassword(
               email: email, password: password);
           return cred.user;
         }catch(e){
           log("something went wrong" as num);
         }

  }
  Future<User?> loginUserWithEmailAndPassword(
      String email, String password) async {
    try{
      await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return _auth.currentUser;
    }catch(e){
      log("something went wrong" as num);
    }

  }
  Future<void> signOut() async {
    await _auth.signOut();
  }

}