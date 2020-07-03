import 'package:aapg_myaccount_flutter/models/user.dart';
import 'package:aapg_myaccount_flutter/screens/home/search.dart';
import 'package:aapg_myaccount_flutter/screens/home/upload.dart';
import 'package:aapg_myaccount_flutter/screens/pages/comments.dart';
import 'package:aapg_myaccount_flutter/screens/pages/likes.dart';
import 'package:aapg_myaccount_flutter/shared/custom_image.dart';
import 'package:aapg_myaccount_flutter/shared/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:aapg_myaccount_flutter/shared/wrapper.dart';
import 'package:intl/intl.dart';

final CollectionReference activityFeedRef =
    Firestore.instance.collection("feed");
final DateTime timestamp = DateTime.now();
final CollectionReference likesRef = Firestore.instance.collection("likes");

class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String userName;
  final String location;
  final String description;
  final String mediaUrl;
  final dynamic likes;
  final Timestamp dateTime;

  Post(
      {this.postId,
      this.ownerId,
      this.userName,
      this.location,
      this.description,
      this.mediaUrl,
      this.likes,
      this.dateTime});

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      postId: doc['postId'],
      ownerId: doc['ownerId'],
      userName: doc['userName'],
      location: doc['location'],
      description: doc['description'],
      mediaUrl: doc['mediaUrl'],
      likes: doc['likes'],
      dateTime: doc['timestamp'],
    );
  }

  int getLikeCount(likes) {
    // if no likes, return 0
    if (likes == null) {
      return 0;
    }
    int count = 0;
    // if the key is explicitly set to true, add a like
    likes.values.forEach((val) {
      if (val == true) {
        count += 1;
      }
    });
    return count;
  }

  @override
  _PostState createState() => _PostState(
      postId: this.postId,
      ownerId: this.ownerId,
      userName: this.userName,
      location: this.location,
      description: this.description,
      mediaUrl: this.mediaUrl,
      likes: this.likes,
      likeCount: getLikeCount(this.likes),
      dateTime: this.dateTime);
}

class _PostState extends State<Post> {
  final String postId;
  final String ownerId;
  final String userName;
  final String location;
  final String description;
  final String mediaUrl;
  final Timestamp dateTime;
  String currentUserId = user.uid;
  int likeCount;
  Map likes;
  bool isLiked;
  UserData _user;
  int commentCount = 0;

  _PostState(
      {this.postId,
      this.ownerId,
      this.userName,
      this.location,
      this.description,
      this.mediaUrl,
      this.likes,
      this.likeCount,
      this.dateTime});

  @override
  void initState() {
    super.initState();
    getUser();
    getComments();
  }

  getUser() async {
    DocumentSnapshot doc = await usersRef.document(currentUserId).get();
    _user = UserData.fromDocument(doc);
  }

  getComments() async {
    QuerySnapshot snapshot = await commentsRef
        .document(postId)
        .collection('comments')
        .getDocuments();
    if (this.mounted) {
      setState(() {
        commentCount = snapshot.documents.length;
      });
    }
  }

  buildPostHeader() {
    return FutureBuilder(
      future: usersRef.document(ownerId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        UserData userData = UserData.fromDocument(snapshot.data);
        bool isPostOwner = currentUserId == ownerId;
        return ListTile(
          leading: GestureDetector(
            onTap: () => showProfile(context, profileId: userData.uid),
            child: userData.photoUrl.isEmpty
                ? CircleAvatar(
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, color: Colors.white, size: 35),
                    radius: 25,
                  )
                : CircleAvatar(
                    backgroundImage:
                        CachedNetworkImageProvider(userData.photoUrl),
                    radius: 25,
                  ),
          ),
          title: GestureDetector(
            onTap: () => showProfile(context, profileId: userData.uid),
            child: Text(
              userData.displayName,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          subtitle: RichText(
            text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: <TextSpan>[
                  TextSpan(
                      text:
                          '${DateFormat.yMMMd().format(dateTime.toDate())} at ${DateFormat.jm().format(dateTime.toDate())}\n'),
                  TextSpan(
                      text: location.isEmpty ? '' : location,
                      style: TextStyle(color: Colors.grey[600]))
                ]),
          ),
          trailing: isPostOwner
              ? IconButton(
                  onPressed: () => handleDeletePost(context),
                  icon: Icon(Icons.more_vert),
                )
              : Text(''),
        );
      },
    );
  }

  handleDeletePost(BuildContext parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: Text("Remove this post?"),
            children: <Widget>[
              SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context);
                    deletePost();
                  },
                  child: Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  )),
              SimpleDialogOption(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel')),
            ],
          );
        });
  }

  // Note: To delete post, ownerId and currentUserId must be equal, so they can be used interchangeably
  deletePost() async {
    // delete post itself
    postsRef
        .document(ownerId)
        .collection('userPosts')
        .document(postId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    if (mediaUrl.isNotEmpty) {
      // delete uploaded image for the post
      storageRef.child("post_$postId.jpg").delete();
    }
    // then delete all activity feed notifications
    QuerySnapshot activityFeedSnapshot = await activityFeedRef
        .document(ownerId)
        .collection("feedItems")
        .where('postId', isEqualTo: postId)
        .getDocuments();
    activityFeedSnapshot.documents.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // then delete all comments
    QuerySnapshot commentsSnapshot = await commentsRef
        .document(postId)
        .collection('comments')
        .getDocuments();
    commentsSnapshot.documents.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    // then delete all likes
    QuerySnapshot likesSnapshot =
        await likesRef.document(ownerId).collection(postId).getDocuments();
    likesSnapshot.documents.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  handleLikePost() {
    bool _isLiked = likes[currentUserId] == true;
    if (_isLiked) {
      postsRef
          .document(ownerId)
          .collection('userPosts')
          .document(postId)
          .updateData({'likes.$currentUserId': false});
      removeLikeFromActivityFeed();
      removeLikeFromLikesRef();
      if (this.mounted) {
        setState(() {
          likeCount -= 1;
          isLiked = false;
          likes[currentUserId] = false;
        });
      }
    } else if (!_isLiked) {
      postsRef
          .document(ownerId)
          .collection('userPosts')
          .document(postId)
          .updateData({'likes.$currentUserId': true});
      addLikeToActivityFeed();
      addLikeToLikesRef();
      if (this.mounted) {
        setState(() {
          likeCount += 1;
          isLiked = true;
          likes[currentUserId] = true;
        });
      }
    }
  }

  addLikeToActivityFeed() {
    // add a notification to the postOwner's activity feed only if comment made by OTHER user (to avoid getting notification for our own like)
    bool isNotPostOwner = currentUserId != ownerId;
    if (isNotPostOwner) {
      activityFeedRef
          .document(ownerId)
          .collection("feedItems")
          .document(postId)
          .setData({
        "type": "like",
        "username": _user.userName,
        'fullName': _user.displayName,
        "userId": currentUserId,
        "postId": postId,
        "mediaUrl": mediaUrl,
        "timestamp": timestamp,
        "userProfileImg": _user.photoUrl
      });
    }
  }

  addLikeToLikesRef() {
    likesRef
        .document(ownerId)
        .collection(postId)
        .document(currentUserId)
        .setData({
      "username": _user.userName,
      "displayName": _user.displayName,
      "userId": currentUserId,
      "postId": postId,
      "mediaUrl": mediaUrl,
      "timestamp": timestamp,
      "userProfileImg": _user.photoUrl
    });
  }

  removeLikeFromActivityFeed() {
    bool isNotPostOwner = currentUserId != ownerId;
    if (isNotPostOwner) {
      activityFeedRef
          .document(ownerId)
          .collection("feedItems")
          .document(postId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    }
  }

  removeLikeFromLikesRef() {
    likesRef
        .document(ownerId)
        .collection(postId)
        .document(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  buildPostContent() {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          description.isEmpty
              ? Container(height: 0, width: 0)
              : Text(description,
                  style: TextStyle(color: Colors.black, fontSize: 18)),
          SizedBox(height: 10),
          mediaUrl.isEmpty
              ? Container(height: 0, width: 0)
              : cachedNetworkImage(mediaUrl)
        ],
      ),
    );
  }

  buildPostFooter() {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Padding(padding: EdgeInsets.only(top: 40, left: 20)),
            Expanded(
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: handleLikePost,
                    child: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      size: 28,
                      color: Colors.pink,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return Likes(
                            ownerId: ownerId,
                            postId: postId,
                            currentUserId: currentUserId);
                      }));
                    },
                    child: Container(
                      margin: EdgeInsets.only(left: 20),
                      child: Text(
                        "$likeCount Likes",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => showComments(context,
                    postId: postId,
                    ownerId: ownerId,
                    mediaUrl: mediaUrl,
                    currentUserId: currentUserId,
                    userName: _user.userName,
                    fullName: _user.displayName,
                    photoUrl: _user.photoUrl),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.chat,
                      size: 28,
                      color: Colors.blue[900],
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 20),
                      child: Text(
                        "$commentCount Comments",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 15)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    isLiked = (likes[currentUserId] == true);
    return Container(
      padding: EdgeInsets.only(bottom: 10, right: 5, left: 5),
      child: Card(
        elevation: 3,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(padding: EdgeInsets.only(top: 10)),
            buildPostHeader(),
            buildPostContent(),
            buildPostFooter(),
          ],
        ),
      ),
    );
  }

  showComments(BuildContext context,
      {String postId,
      String ownerId,
      String mediaUrl,
      String currentUserId,
      String userName,
      String fullName,
      String photoUrl}) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Comments(
          postId: postId,
          postOwnerId: ownerId,
          postMediaUrl: mediaUrl,
          currentUserId: currentUserId,
          userName: userName,
          fullName: fullName,
          photoUrl: photoUrl);
    }));
  }
}
