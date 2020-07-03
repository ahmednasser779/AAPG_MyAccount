import 'package:aapg_myaccount_flutter/models/user.dart';
import 'package:aapg_myaccount_flutter/screens/home/profile.dart';
import 'package:aapg_myaccount_flutter/shared/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../shared/wrapper.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> with AutomaticKeepAliveClientMixin {
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot> searchResultsFuture;
  var queryResultSet = [];
  var tempSearchStore = [];
  List<String> followingList = [];

  @override
  void initState() {
    super.initState();
    getFollowing();
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

  searchByName(String searchField) {
    Future<QuerySnapshot> users = usersRef
        .where("searchKey",
            isEqualTo: searchField.substring(0, 1).toUpperCase())
        .getDocuments();
    setState(() {
      searchResultsFuture = users;
    });
    return searchResultsFuture;
  }

  clearSearch() {
    searchController.clear();
  }

  initiateSearch(value) {
    if (value.length == 0) {
      setState(() {
        queryResultSet = [];
        tempSearchStore = [];
      });
    }

    var capitalizedValue =
        value.substring(0, 1).toUpperCase() + value.substring(1);

    if (queryResultSet.length == 0 && value.length == 1) {
      searchByName(value).then((QuerySnapshot docs) {
        for (int i = 0; i < docs.documents.length; ++i) {
          queryResultSet.add(docs.documents[i].data);
          setState(() {
            tempSearchStore.add(queryResultSet[i]);
          });
        }
      });
    } else {
      tempSearchStore = [];
      queryResultSet.forEach((element) {
        if (element['displayName']
                .toLowerCase()
                .contains(value.toLowerCase()) ==
            true) {
          if (element['displayName']
                  .toLowerCase()
                  .indexOf(value.toLowerCase()) ==
              0) {
            setState(() {
              tempSearchStore.add(element);
            });
          }
        }
      });
    }
    if (tempSearchStore.length == 0 && value.length > 1) {
      setState(() {});
    }
  }

  buildUsersToFollow() {
    return StreamBuilder(
      stream:
          usersRef.orderBy('timestamp', descending: true).limit(30).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<UserResult> userResults = [];
        snapshot.data.documents.forEach((doc) {
          UserData userData = UserData.fromDocument(doc);
          final bool isAuthUser = user.uid == userData.uid;
          final bool isFollowingUser = followingList.contains(userData.uid);
          // remove auth user from recommended list
          if (isAuthUser) {
            return;
          } else if (isFollowingUser) {
            return;
          } else {
            UserResult userResult = UserResult(userData);
            userResults.add(userResult);
          }
        });
        return userResults.isEmpty
            ? Center(
                child: Image.asset('assets/images/no_content.png'),
              )
            : Container(
                color: Colors.white,
                child: ListView(
                  children: <Widget>[
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.add,
                          color: Theme.of(context).accentColor,
                        ),
                        Text(
                          'Users to follow',
                          style: TextStyle(
                              color: Theme.of(context).accentColor,
                              fontSize: 28,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                    SizedBox(height: 12),
                    Column(children: userResults),
                    SizedBox(height: 12),
                  ],
                ),
              );
      },
    );
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: TextFormField(
          controller: searchController,
          onChanged: (val) {
            initiateSearch(val);
          },
          decoration: InputDecoration(
              hintText: 'Search for a user...',
              filled: true,
              prefixIcon: Icon(Icons.account_box, size: 28),
              suffixIcon: IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  clearSearch();
                },
              )),
        ),
      ),
      body: searchResultsFuture != null
          ? ListView(
              children: tempSearchStore.map((element) {
              return buildResultCard(element, context);
            }).toList())
          : buildUsersToFollow(),
    );
  }
}

Widget buildResultCard(data, context) {
  return Padding(
    padding: EdgeInsets.all(5),
    child: Card(
      elevation: 3,
      child: Container(
        margin: EdgeInsets.all(5),
        color: Colors.white,
        child: Column(
          children: <Widget>[
            GestureDetector(
              onTap: () {
                showProfile(context, profileId: data['uid']);
              },
              child: ListTile(
                leading: data['photoUrl'].isEmpty
                    ? CircleAvatar(
                        backgroundColor: Colors.grey,
                        child:
                            Icon(Icons.person, color: Colors.white, size: 35),
                        radius: 25,
                      )
                    : CircleAvatar(
                        backgroundImage:
                            CachedNetworkImageProvider(data['photoUrl']),
                        radius: 30,
                      ),
                title: Text(
                  data['displayName'],
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  data['userName'],
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
            Divider(
              height: 2.0,
              color: Colors.white54,
            ),
          ],
        ),
      ),
    ),
  );
}

class UserResult extends StatefulWidget {
  final UserData user;

  UserResult(this.user);

  @override
  _UserResultState createState() => _UserResultState();
}

class _UserResultState extends State<UserResult> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5),
      child: Card(
        elevation: 3,
        child: Container(
          margin: EdgeInsets.all(5),
          color: Colors.white,
          child: Column(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  showProfile(context, profileId: widget.user.uid);
                },
                child: ListTile(
                  leading: widget.user.photoUrl.isEmpty
                      ? CircleAvatar(
                          backgroundColor: Colors.grey,
                          child:
                              Icon(Icons.person, color: Colors.white, size: 35),
                          radius: 25,
                        )
                      : CircleAvatar(
                          backgroundImage:
                              CachedNetworkImageProvider(widget.user.photoUrl),
                          radius: 25,
                        ),
                  title: Text(
                    widget.user.displayName,
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    widget.user.userName,
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              Divider(
                height: 2.0,
                color: Colors.white54,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

showProfile(BuildContext context, {String profileId}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Profile(
        profileId: profileId,
      ),
    ),
  );
}
