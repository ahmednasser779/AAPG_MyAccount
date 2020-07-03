import 'package:aapg_myaccount_flutter/models/likes_model.dart';
import 'package:aapg_myaccount_flutter/models/post.dart';
import 'package:aapg_myaccount_flutter/shared/header.dart';
import 'package:aapg_myaccount_flutter/shared/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Likes extends StatefulWidget {
  final String ownerId;
  final String postId;
  final String currentUserId;
  Likes({this.ownerId, this.postId, this.currentUserId});
  @override
  _LikesState createState() => _LikesState();
}

class _LikesState extends State<Likes> {

  getLikedUsers() async {
    QuerySnapshot snapshot = await likesRef
        .document(widget.ownerId)
        .collection(widget.postId)
        .getDocuments();
    List<LikesModel> likes = [];
    snapshot.documents.forEach((doc) {
      likes.add(LikesModel.fromDocument(doc));
    });
    return likes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: 'Likes'),
      body: FutureBuilder(
        future: getLikedUsers(),
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
