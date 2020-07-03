import 'package:aapg_myaccount_flutter/screens/home/search.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FollowingModel extends StatefulWidget {
  final String followingId;
  final String followingFullName;
  final String followingUserName;
  final String followingPhotoUrl;

  FollowingModel({this.followingId, this.followingFullName, this.followingUserName, this.followingPhotoUrl});

  factory FollowingModel.fromDocument(DocumentSnapshot doc) {
    return FollowingModel(
        followingId: doc['followingId'],
        followingFullName: doc['followingFullName'],
        followingUserName: doc['followingUserName'],
        followingPhotoUrl: doc['followingPhotoUrl']
    );
  }
  @override
  _FollowingModelState createState() => _FollowingModelState();
}

class _FollowingModelState extends State<FollowingModel> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(3),
      child: Card(
        elevation: 3,
        child: Container(
          color: Colors.white54,
          child: ListTile(
            onTap: () => showProfile(context , profileId: widget.followingId),
            title: Text(
              widget.followingFullName,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            leading: widget.followingPhotoUrl.isEmpty || widget.followingPhotoUrl == null? CircleAvatar(
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white, size: 35),
              radius: 25,
            ): CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(widget.followingPhotoUrl),
              radius: 25,
            ),
            subtitle: Text(
                widget.followingUserName
            ),
          ),
        ),
      ),
    );
  }
}
