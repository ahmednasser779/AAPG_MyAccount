import 'package:aapg_myaccount_flutter/models/inbox_model.dart';
import 'package:aapg_myaccount_flutter/models/post.dart';
import 'package:aapg_myaccount_flutter/models/user.dart';
import 'package:aapg_myaccount_flutter/screens/home/profile.dart';
import 'package:aapg_myaccount_flutter/screens/pages/chat.dart';
import 'package:aapg_myaccount_flutter/screens/pages/inbox.dart';
import 'package:aapg_myaccount_flutter/services/auth.dart';
import 'package:aapg_myaccount_flutter/shared/header.dart';
import 'package:aapg_myaccount_flutter/shared/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:aapg_myaccount_flutter/shared/wrapper.dart';

final timelineRef = Firestore.instance.collection("timeline");

class Timeline extends StatefulWidget {
  final User currentUser;

  Timeline({this.currentUser});

  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  List<Post> posts;
  List<String> followingList = [];
  bool isLoading = false;
  UserData userData;
  final AuthService _auth = AuthService();
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  InboxModel inboxModel;
  int count = 0;

  @override
  void initState() {
    super.initState();
    getTimeline();
    getFollowing();
    getUser();
    getInbox();
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc =
        await usersRef.document(widget.currentUser.uid).get();
    userData = UserData.fromDocument(doc);
    setState(() {
      isLoading = false;
    });
  }

  getInbox() async {
    QuerySnapshot snapshot = await inboxRef
        .document(widget.currentUser.uid)
        .collection('inboxUsers')
        .where('isRead', isEqualTo: false)
        .where('recipientUserId', isEqualTo: widget.currentUser.uid)
        .getDocuments();
    setState(() {
      count = snapshot.documents.length;
    });
  }

  getTimeline() async {
    QuerySnapshot snapshot = await timelineRef
        .document(widget.currentUser.uid)
        .collection('timelinePosts')
        .orderBy('timestamp', descending: true)
        .getDocuments();
    List<Post> posts =
        snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
    if (this.mounted) {
      setState(() {
        this.posts = posts;
      });
    }
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .document(user.uid)
        .collection('userFollowing')
        .getDocuments();
    if (this.mounted) {
      setState(() {
        followingList =
            snapshot.documents.map((doc) => doc.documentID).toList();
      });
    }
  }

  buildTimeline() {
    if (posts == null) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return buildNoPosts();
    } else {
      return RefreshIndicator(
        key: refreshKey,
        onRefresh: () => getTimeline(),
        child: ListView.builder(
          padding: EdgeInsets.only(top: 10),
          physics: AlwaysScrollableScrollPhysics(),
          itemCount: posts.length,
          itemBuilder: (_, index) {
            return posts[index];
          },
        ),
      );
    }
  }

  buildNoPosts() {
    return Center(
      child: Image.asset('assets/images/no_posts.png'),
    );
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
  Widget build(context) {
    getInbox();
    return isLoading
        ? circularProgress()
        : WillPopScope(
            onWillPop: _onWillPop,
            child: Scaffold(
                appBar: header(context, isAppTitle: true),
                drawer: Drawer(
                  child: ListView(
                    children: <Widget>[
                      UserAccountsDrawerHeader(
                          accountName: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return Profile(
                                      profileId: widget.currentUser.uid);
                                }));
                              },
                              child: Text('${userData.displayName}')),
                          accountEmail: Text('${userData.email}'),
                          currentAccountPicture: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return Profile(
                                    profileId: widget.currentUser.uid);
                              }));
                            },
                            child: userData.photoUrl.isEmpty
                                ? CircleAvatar(
                                    backgroundColor: Colors.grey,
                                    child: Icon(Icons.person,
                                        color: Colors.white, size: 50),
                                  )
                                : CircleAvatar(
                                    backgroundImage: CachedNetworkImageProvider(
                                        userData.photoUrl),
                                  ),
                          )),
                      ListTile(
                        leading: Icon(
                          Icons.home,
                          size: 25,
                        ),
                        title: Text(
                          'Home',
                          style: TextStyle(fontSize: 18),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.account_circle, size: 25),
                        title: Text('Profile', style: TextStyle(fontSize: 18)),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return Profile(profileId: widget.currentUser.uid);
                          }));
                        },
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.mail, size: 25),
                        title: Text('Inbox', style: TextStyle(fontSize: 18)),
                        trailing: count != 0
                            ? CircleAvatar(
                                child: Text(
                                  '$count',
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.red,
                                radius: 18,
                              )
                            : Text(''),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return Inbox(currentUserId: widget.currentUser.uid);
                          }));
                        },
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.exit_to_app,
                            size: 25, color: Colors.red),
                        title: Text('Logout',
                            style: TextStyle(fontSize: 18, color: Colors.red)),
                        onTap: () {
                          Navigator.pop(context);
                          _auth.signOut();
                        },
                      ),
                      Divider(),
                    ],
                  ),
                ),
                body: buildTimeline()),
          );
  }
}
