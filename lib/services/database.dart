import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aapg_myaccount_flutter/models/user.dart';

class DatabaseService {
  final String uid;
  DatabaseService({this.uid});

  final CollectionReference usersRef = Firestore.instance.collection("users");

  //user data from snapshot
  UserData userDataModel(DocumentSnapshot snapshot){
    return UserData(
        uid: uid,
        userName: snapshot.data['userName'],
        displayName: snapshot.data['displayName'],
        bio: snapshot.data['bio'],
        photoUrl: snapshot.data['photoUrl'],
    );
  }

  Stream<UserData> get userData{
    return usersRef.document(uid).snapshots().map(userDataModel);
  }
}