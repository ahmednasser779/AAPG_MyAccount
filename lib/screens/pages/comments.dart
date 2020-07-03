import 'package:aapg_myaccount_flutter/models/post.dart';
import 'package:aapg_myaccount_flutter/screens/home/profile.dart';
import 'package:aapg_myaccount_flutter/shared/header.dart';
import 'package:aapg_myaccount_flutter/shared/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

final CollectionReference commentsRef =
    Firestore.instance.collection("Comments");
final DateTime timestamp = DateTime.now();

class Comments extends StatefulWidget {
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;
  final String currentUserId;
  final String userName;
  final String fullName;
  final String photoUrl;

  Comments(
      {this.postId,
      this.postOwnerId,
      this.postMediaUrl,
      this.currentUserId,
      this.userName,
      this.fullName,
      this.photoUrl});

  @override
  CommentsState createState() => CommentsState(
      postId: this.postId,
      postOwnerId: this.postOwnerId,
      postMediaUrl: this.postMediaUrl,
      currentUserId: this.currentUserId,
      userName: this.userName,
      fullName: this.fullName,
      photoUrl: this.photoUrl);
}

class CommentsState extends State<Comments> {
  TextEditingController commentController = TextEditingController();
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;
  final String currentUserId;
  final String userName;
  final String fullName;
  final String photoUrl;

  CommentsState(
      {this.postId,
      this.postOwnerId,
      this.postMediaUrl,
      this.currentUserId,
      this.userName,
      this.fullName,
      this.photoUrl});

  buildComments() {
    return StreamBuilder(
        stream: commentsRef
            .document(postId)
            .collection('comments')
            .orderBy("timestamp", descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          List<Comment> comments = [];
          snapshot.data.documents.forEach((doc) {
            comments.add(Comment.fromDocument(doc));
          });
          return ListView(
            children: comments,
          );
        });
  }

  addComment() {
    commentsRef.document(postId).collection("comments").add({
      "username": userName,
      'fullName': fullName,
      "comment": commentController.text,
      "timestamp": timestamp,
      "userId": currentUserId,
      "photoUrl": photoUrl
    });
    bool isNotPostOwner = postOwnerId != currentUserId;
    if (isNotPostOwner) {
      activityFeedRef.document(postOwnerId).collection('feedItems').add({
        "type": "comment",
        "commentData": commentController.text,
        "timestamp": timestamp,
        "postId": postId,
        "userId": currentUserId,
        "username": userName,
        'fullName': fullName,
        "mediaUrl": postMediaUrl,
        "userProfileImg": photoUrl
      });
    }
    commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: "Comments"),
      body: Column(
        children: <Widget>[
          Expanded(child: buildComments()),
          Divider(),
          ListTile(
            title: TextFormField(
              controller: commentController,
              decoration: InputDecoration(labelText: "Write a comment..."),
            ),
            trailing: IconButton(
              icon: Icon(Icons.send),
              color: Theme.of(context).primaryColor,
              onPressed: addComment,
              iconSize: 40,
            ),
          ),
        ],
      ),
    );
  }
}

class Comment extends StatelessWidget {
  final String username;
  final String fullName;
  final String userId;
  final String photoUrl;
  final String comment;
  final Timestamp timestamp;

  Comment({
    this.username,
    this.fullName,
    this.userId,
    this.photoUrl,
    this.comment,
    this.timestamp,
  });

  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      username: doc['username'],
      fullName: doc['fullName'],
      userId: doc['userId'],
      comment: doc['comment'],
      timestamp: doc['timestamp'],
      photoUrl: doc['photoUrl'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: RichText(
            text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: <TextSpan>[
                  TextSpan(
                      text: '$fullName\n',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) {
                          return Profile(profileId: userId);
                        }));
                      }
                  ),
                  TextSpan(
                    text: comment,
                  )
                ]),
          ),
          leading: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return Profile(profileId: userId);
                }));
              },
              child: photoUrl.isEmpty
                  ? CircleAvatar(
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, color: Colors.white, size: 35),
                      radius: 25,
                    )
                  : CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(photoUrl),
                      radius: 25,
                    )),
          subtitle: Text(timeago.format(timestamp.toDate())),
        ),
        Divider(),
      ],
    );
  }
}
