import 'package:aapg_myaccount_flutter/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';

String signInError;
String registerError;

class AuthService{

  final FirebaseAuth _auth = FirebaseAuth.instance;
  User _userModel (FirebaseUser user){
    return user != null ? User(uid: user.uid) : null;
  }
  // Auth change state user stream
  Stream<User> get user{
    return _auth.onAuthStateChanged
        .map(_userModel);
  }

  //sign in with email and password
  Future signInWithEmailAndPassword(String email , String password) async{
    try{
      AuthResult result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      FirebaseUser user = result.user;
      return _userModel(user);
    }catch(e){
      print(e.toString());
      signInError = e.toString();
      return null;
    }
  }

  //register with email and password
  Future registerWithEmailAndPassword(String email , String password) async{
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser user = result.user;
      return _userModel(user);
    }catch(e){
      print(e.toString());
      registerError = e.toString();
      return null;
    }
  }

  //sign out
  Future signOut() async{
    try{
      return await _auth.signOut();
    }catch(e){
      print(e.toString());
      return null;
    }
  }
}