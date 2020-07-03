import 'package:aapg_myaccount_flutter/models/post.dart';
import 'package:aapg_myaccount_flutter/models/user.dart';
import 'package:aapg_myaccount_flutter/screens/home/profile.dart';
import 'package:aapg_myaccount_flutter/screens/home/search.dart';
import 'package:aapg_myaccount_flutter/screens/pages/post_screen.dart';
import 'package:aapg_myaccount_flutter/shared/header.dart';
import 'package:aapg_myaccount_flutter/shared/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:aapg_myaccount_flutter/shared/wrapper.dart';
import 'package:timeago/timeago.dart' as timeago;

class ActivityFeed extends StatefulWidget {
  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  List<ActivityFeedItem> feedItems;

  getActivityFeed() async {
    QuerySnapshot snapshot = await activityFeedRef
        .document(user.uid)
        .collection('feedItems')
        .orderBy('timestamp', descending: true)
        .getDocuments();
    List<ActivityFeedItem> feedItems = [];
    snapshot.documents.forEach((doc) {
      feedItems.add(ActivityFeedItem.fromDocument(doc));
    });
    if (this.mounted) {
      setState(() {
        this.feedItems = feedItems;
      });
    }
    return feedItems;
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Are you sure?'),
            content: Text('Do you want to exit an App'),
            actions: <Widget>[
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
              FlatButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: header(context, titleText: "Notifications"),
        body: FutureBuilder(
          future: getActivityFeed(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return circularProgress();
            }
            return feedItems.isEmpty
                ? buildNoContent()
                : RefreshIndicator(
                    key: refreshKey,
                    onRefresh: () => getActivityFeed(),
                    child: ListView.builder(
                      physics: AlwaysScrollableScrollPhysics(),
                      itemCount: snapshot.data.length,
                      itemBuilder: (_, index) {
                        return snapshot.data[index];
                      },
                    ),
                  );
          },
        ),
      ),
    );
  }

  buildNoContent() {
    return Center(
      child: Image.asset('assets/images/no_content.png'),
    );
  }
}

Widget mediaPreview;
String activityItemText;
String photoUrl;

class ActivityFeedItem extends StatefulWidget {
  final String username;
  final String fullName;
  final String userId;
  final String type; // 'like', 'follow', 'comment'
  final String mediaUrl;
  final String postId;
  final String commentData;
  final Timestamp timestamp;
  final String photoUrl;

  ActivityFeedItem(
      {this.username,
      this.fullName,
      this.userId,
      this.type,
      this.mediaUrl,
      this.postId,
      this.commentData,
      this.timestamp,
      this.photoUrl});

  factory ActivityFeedItem.fromDocument(DocumentSnapshot doc) {
    return ActivityFeedItem(
      username: doc['username'],
      fullName: doc['fullName'],
      userId: doc['userId'],
      type: doc['type'],
      postId: doc['postId'],
      commentData: doc['commentData'],
      timestamp: doc['timestamp'],
      mediaUrl: doc['mediaUrl'],
      photoUrl: doc['userProfileImg'],
    );
  }

  @override
  _ActivityFeedItemState createState() => _ActivityFeedItemState();
}

class _ActivityFeedItemState extends State<ActivityFeedItem> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getUser();
  }

  showPost(context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return PostScreen(
        userId: user.uid,
        postId: widget.postId,
      );
    }));
  }

  configureMediaPreview(context) {
    if (widget.type == "like" || widget.type == 'comment') {
      mediaPreview = widget.mediaUrl.isEmpty
          ? Text('')
          : Container(
              height: 50,
              width: 50,
              child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: CachedNetworkImageProvider(widget.mediaUrl),
                      ),
                    ),
                  )),
            );
    } else {
      mediaPreview = Text('');
    }

    if (widget.type == 'like') {
      activityItemText = "liked your post";
    } else if (widget.type == 'follow') {
      activityItemText = "is following you";
    } else if (widget.type == 'comment') {
      activityItemText = 'replied: ${widget.commentData}';
    } else {
      activityItemText = "Error: Unknown type '${widget.type}'";
    }
  }

  getUser() async {
    if (this.mounted) {
      setState(() {
        isLoading = true;
      });
    }
    DocumentSnapshot doc = await usersRef.document(widget.userId).get();
    userData = UserData.fromDocument(doc);
    photoUrl = userData.photoUrl;
    if (this.mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    configureMediaPreview(context);
    return isLoading
        ? Container()
        : Padding(
            padding: EdgeInsets.only(bottom: 2),
            child: Card(
              elevation: 3,
              child: Container(
                color: Colors.white54,
                child: ListTile(
                  onTap: () {
                    widget.type == "like" || widget.type == 'comment'
                        ? showPost(context)
                        : showProfile(context, profileId: widget.userId);
                  },
                  title: RichText(
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                        children: [
                          TextSpan(
                            text: widget.fullName,
                            style: TextStyle(fontWeight: FontWeight.bold),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                showProfile(context, profileId: widget.userId);
                              },
                          ),
                          TextSpan(
                            text: ' $activityItemText',
                          ),
                        ]),
                  ),
                  leading: GestureDetector(
                    onTap: () => showProfile(context, profileId: widget.userId),
                    child: widget.photoUrl.isEmpty || widget.photoUrl == null
                        ? CircleAvatar(
                            backgroundColor: Colors.grey,
                            child: Icon(Icons.person,
                                color: Colors.white, size: 35),
                            radius: 25,
                          )
                        : CircleAvatar(
                            backgroundImage:
                                CachedNetworkImageProvider(widget.photoUrl),
                            radius: 25,
                          ),
                  ),
                  subtitle: Text(
                    timeago.format(widget.timestamp.toDate()),
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: mediaPreview,
                ),
              ),
            ),
          );
  }
}
