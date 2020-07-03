import 'package:aapg_myaccount_flutter/models/following_model.dart';
import 'package:aapg_myaccount_flutter/screens/home/profile.dart';
import 'package:aapg_myaccount_flutter/shared/header.dart';
import 'package:aapg_myaccount_flutter/shared/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Following extends StatefulWidget {
  final String profileId;
  Following({this.profileId});

  @override
  _FollowingState createState() => _FollowingState();
}

class _FollowingState extends State<Following> {

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .document(widget.profileId)
        .collection('userFollowing')
        .getDocuments();
    List<FollowingModel> following = [];
    snapshot.documents.forEach((doc) {
      following.add(FollowingModel.fromDocument(doc));
    });
    return following;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context , titleText: 'Following'),
      body: FutureBuilder(
        future: getFollowing(),
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
