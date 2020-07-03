import 'package:aapg_myaccount_flutter/screens/home/search.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Follower extends StatefulWidget {
  final String followerId;
  final String followerFullName;
  final String followerUserName;
  final String followerPhotoUrl;

  Follower({this.followerId , this.followerFullName , this.followerUserName , this.followerPhotoUrl});

  factory Follower.fromDocument(DocumentSnapshot doc) {
    return Follower(
        followerId: doc['followerId'],
        followerFullName: doc['followerFullName'],
        followerUserName: doc['followerUserName'],
        followerPhotoUrl: doc['followerPhotoUrl']
    );
  }
  @override
  _FollowerState createState() => _FollowerState();
}

class _FollowerState extends State<Follower> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(3),
      child: Card(
        elevation: 3,
        child: Container(
          color: Colors.white54,
          child: ListTile(
            onTap: () => showProfile(context , profileId: widget.followerId),
            title: Text(
              widget.followerFullName,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            leading: widget.followerPhotoUrl.isEmpty || widget.followerPhotoUrl == null? CircleAvatar(
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white, size: 35),
              radius: 25,
            ): CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(widget.followerPhotoUrl),
              radius: 25,
            ),
            subtitle: Text(
              widget.followerUserName
            ),
          ),
        ),
      ),
    );
  }
}