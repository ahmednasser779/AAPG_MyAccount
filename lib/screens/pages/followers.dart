import 'package:aapg_myaccount_flutter/models/follower.dart';
import 'package:aapg_myaccount_flutter/screens/home/profile.dart';
import 'package:aapg_myaccount_flutter/shared/header.dart';
import 'package:aapg_myaccount_flutter/shared/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Followers extends StatefulWidget {
  final String profileId;
  Followers({this.profileId});
  @override
  _FollowersState createState() => _FollowersState();
}

class _FollowersState extends State<Followers> {

  getFollowers() async {
    QuerySnapshot snapshot = await followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .getDocuments();
    List<Follower> followers = [];
    snapshot.documents.forEach((doc) {
      followers.add(Follower.fromDocument(doc));
    });
    return followers;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context , titleText: 'Followers'),
      body: FutureBuilder(
        future: getFollowers(),
        builder: (context , snapshot){
          if (!snapshot.hasData) {
            return circularProgress();
          }
          return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (_, index){
              return snapshot.data[index];
            },
          );
        },
      ),
    );
  }
}
