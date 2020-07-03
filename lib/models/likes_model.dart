import 'package:aapg_myaccount_flutter/screens/home/search.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LikesModel extends StatefulWidget {
  final String likedUserId;
  final String likedUserFullName;
  final String likedUserName;
  final String likedUserPhotoUrl;

  LikesModel({this.likedUserId, this.likedUserFullName, this.likedUserName, this.likedUserPhotoUrl});

  factory LikesModel.fromDocument(DocumentSnapshot doc) {
    return LikesModel(
        likedUserId: doc['userId'],
        likedUserFullName: doc['displayName'],
        likedUserName: doc['username'],
        likedUserPhotoUrl: doc['userProfileImg']
    );
  }
  @override
  _LikesModelState createState() => _LikesModelState();
}

class _LikesModelState extends State<LikesModel> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(3),
      child: Card(
        elevation: 3,
        child: Container(
          color: Colors.white54,
          child: ListTile(
            onTap: () => showProfile(context , profileId: widget.likedUserId),
            title: Text(
              widget.likedUserFullName,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            leading: widget.likedUserPhotoUrl.isEmpty || widget.likedUserPhotoUrl == null? CircleAvatar(
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white, size: 35),
              radius: 25,
            ): CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(widget.likedUserPhotoUrl),
              radius: 25,
            ),
            subtitle: Text(
                widget.likedUserName
            ),
          ),
        ),
      ),
    );
  }
}
