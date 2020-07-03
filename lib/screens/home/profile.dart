import 'package:aapg_myaccount_flutter/models/user.dart';
import 'package:aapg_myaccount_flutter/screens/home/upload.dart';
import 'package:aapg_myaccount_flutter/screens/pages/chat.dart';
import 'package:aapg_myaccount_flutter/screens/pages/followers.dart';
import 'package:aapg_myaccount_flutter/screens/pages/following.dart';
import 'package:aapg_myaccount_flutter/shared/header.dart';
import 'package:aapg_myaccount_flutter/shared/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../pages/edit_profile.dart';
import '../../models/post.dart';
import 'package:aapg_myaccount_flutter/shared/wrapper.dart';

final followersRef = Firestore.instance.collection("followers");
final followingRef = Firestore.instance.collection("following");
final DateTime timestamp = DateTime.now();
UserData userData;

class Profile extends StatefulWidget {
  final String profileId;
  Profile({this.profileId});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final String currentUserId = user?.uid;
  bool isLoading = false;
  int postCount = 0;
  int followerCount = 0;
  int followingCount = 0;
  List<Post> posts = [];
  bool isFollowing = false;
  UserData _user;
  String groupChatId;

  @override
  void initState() {
    super.initState();
    getProfilePosts();
    getFollowers();
    getFollowing();
    checkIfFollowing();
    getUser();
    groupChatId = '';
    readLocal();
  }

  readLocal() async {
    if (currentUserId.hashCode <= widget.profileId.hashCode) {
      groupChatId = '$currentUserId-${widget.profileId}';
    } else {
      groupChatId = '${widget.profileId}-$currentUserId';
    }

    setState(() {});
  }

  getUser() async {
    DocumentSnapshot doc = await usersRef.document(currentUserId).get();
    _user = UserData.fromDocument(doc);
  }

  checkIfFollowing() async {
    DocumentSnapshot doc = await followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .document(currentUserId)
        .get();
    setState(() {
      isFollowing = doc.exists;
  });
  }

  getFollowers() async {
    QuerySnapshot snapshot = await followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .getDocuments();
    setState(() {
      followerCount = snapshot.documents.length;
    });
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .document(widget.profileId)
        .collection('userFollowing')
        .getDocuments();
    setState(() {
      followingCount = snapshot.documents.length;
    });
  }

  getProfilePosts() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await postsRef
        .document(widget.profileId)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .getDocuments();
    setState(() {
      isLoading = false;
      postCount = snapshot.documents.length;
      posts = snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
    });
  }

  Column buildCountColumn(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: EdgeInsets.only(top: 4.0),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 15.0,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  editProfile() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditProfile(profileId: widget.profileId)));
  }

  Container buildButton({String text, Function function}) {
    return Container(
      padding: EdgeInsets.all(2),
      child: FlatButton(
        onPressed: function,
        child: Container(
          width: 225,
          height: 50,
          child: Text(
            text,
            style: TextStyle(
                color: isFollowing ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isFollowing ? Colors.white : Theme.of(context).primaryColor,
            border: Border.all(
              color: isFollowing ? Colors.grey : Theme.of(context).primaryColor,
            ),
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      ),
    );
  }

  buildProfileButton() {
    // viewing your own profile - should show edit profile button
    bool isProfileOwner = widget.profileId == currentUserId;
    if (isProfileOwner) {
      return buildButton(text: "Edit Profile", function: editProfile);
    } else if (isFollowing) {
      return buildButton(text: "Unfollow", function: handleUnFollowUser);
    } else if (isFollowing == false) {
      return buildButton(text: "Follow", function: handleFollowUser);
    }
  }

  handleUnFollowUser() {
    setState(() {
      isFollowing = false;
    });
    // remove follower
    followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .document(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // remove following
    followingRef
        .document(currentUserId)
        .collection('userFollowing')
        .document(widget.profileId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // delete activity feed item for them
    activityFeedRef
        .document(widget.profileId)
        .collection('feedItems')
        .document(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  handleFollowUser() {
    setState(() {
      isFollowing = true;
    });
    // Make auth user follower of THAT user (update THEIR followers collection)
    followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .document(currentUserId)
        .setData({
      "followerId": currentUserId,
      "followerFullName": _user.displayName,
      "followerUserName": _user.userName,
      "followerPhotoUrl": _user.photoUrl.isNotEmpty? _user.photoUrl: ''
    });
    // Put THAT user on YOUR following collection (update your following collection)
    followingRef
        .document(currentUserId)
        .collection('userFollowing')
        .document(widget.profileId)
        .setData({
      "followingId": widget.profileId,
      "followingFullName": userData.displayName,
      "followingUserName": userData.userName,
      "followingPhotoUrl": userData.photoUrl.isNotEmpty? userData.photoUrl: ''
    });
    // add activity feed item for that user to notify about new follower (us)
    activityFeedRef
        .document(widget.profileId)
        .collection('feedItems')
        .document(currentUserId)
        .setData({
      "type": "follow",
      "ownerId": widget.profileId,
      "username": _user.userName,
      'fullName': _user.displayName,
      "userId": currentUserId,
      "userProfileImg": _user.photoUrl,
      "timestamp": timestamp,
    });
  }

  buildProfileHeader() {
    bool isProfileOwner = widget.profileId == currentUserId;
    return FutureBuilder(
      future: usersRef.document(widget.profileId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        userData = UserData.fromDocument(snapshot.data);
        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              Center(
                  child: userData.photoUrl.isEmpty
                      ? CircleAvatar(
                          backgroundColor: Colors.grey,
                          child:
                              Icon(Icons.person, color: Colors.white, size: 70),
                          radius: 50,
                        )
                      : CircleAvatar(
                          backgroundImage:
                              CachedNetworkImageProvider(userData.photoUrl),
                          radius: 60,
                        )),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(top: 15),
                child: Text(
                  userData.displayName,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  userData.userName,
                  style: TextStyle(color: Colors.black),
                ),
              ),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(top: 20),
                child: Text(
                  userData.bio,
                ),
              ),
              SizedBox(height: 20),
              isProfileOwner
                  ? buildProfileButton()
                  : Row(children: <Widget>[
                      Expanded(
                          flex: 1,
                          child: SizedBox.fromSize(
                            size: Size(56, 56), // button width and height
                            child: ClipOval(
                              child: Material(
                                color: Theme.of(context)
                                    .primaryColor, // button color
                                child: InkWell(
                                  splashColor: Theme.of(context)
                                      .accentColor, // splash color
                                  onTap: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return Chat(
                                          currentUserId: currentUserId,
                                          profileId: widget.profileId,
                                          groupChatId: groupChatId,
                                          profileOwnerName:
                                              userData.displayName,
                                        profilePhotoUrl: userData.photoUrl
                                      );
                                    }));
                                  }, // button pressed
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(Icons.chat_bubble,
                                          color: Colors.white),
                                      // icon
                                      Text("Chat",
                                          style:
                                              TextStyle(color: Colors.white)),
                                      // text
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )),
                      Expanded(flex: 4, child: buildProfileButton()),
                    ]),
              SizedBox(height: 20),
              Divider(height: 2),
              SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  buildCountColumn("posts", postCount),
                  GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context){
                        return Followers(profileId: widget.profileId);
                      }));
                    },
                      child: buildCountColumn("followers", followerCount)
                  ),
                  GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context){
                          return Following(profileId: widget.profileId);
                        }));
                      },
                      child: buildCountColumn("following", followingCount)
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  buildProfilePosts() {
    if (isLoading) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return Center(
        child: Container(
            padding: EdgeInsets.only(top: 35),
            child: Image.asset('assets/images/no_posts.png')
        ),
      );
    } else {
      return Container(
        padding: EdgeInsets.only(top: 10),
        child: Column(
          children: posts,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: "Profile"),
      body: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: <Widget>[
          buildProfileHeader(),
          Divider(height: 2),
          buildProfilePosts(),
        ],
      ),
    );
  }
}
