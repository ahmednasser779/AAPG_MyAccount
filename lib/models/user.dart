
import 'package:cloud_firestore/cloud_firestore.dart';

class User{
  final String uid;
  User({this.uid});
}

class UserData{
  final String uid;
  final String userName;
  final String displayName;
  final String bio;
  final String photoUrl;
  final String email;

  UserData({this.uid, this.userName, this.displayName,this.bio, this.photoUrl , this.email});

  factory UserData.fromDocument(DocumentSnapshot doc) {
    return UserData(
      userName: doc['userName'],
      displayName: doc['displayName'],
      photoUrl: doc['photoUrl'],
      bio: doc['bio'],
      uid: doc['uid'],
      email: doc['email']
    );
  }

}