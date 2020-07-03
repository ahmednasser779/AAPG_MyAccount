import 'dart:io';
import 'package:aapg_myaccount_flutter/main.dart';
import 'package:aapg_myaccount_flutter/screens/home/timeline.dart';
import 'package:aapg_myaccount_flutter/screens/home/upload.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'activity_feed.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aapg_myaccount_flutter/shared/wrapper.dart';


final usersRef = Firestore.instance.collection('users');

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  PageController pageController;
  int pageIndex = 0;
  String currentUserId = user.uid;
  @override
  void initState() {
    super.initState();
    pageController = PageController();
    configurePushNotifications();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  onPageChanged(int pageIndex) {
     setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    pageController.animateToPage(
      pageIndex,
      duration: Duration(microseconds: 300),
      curve: Curves.easeInOut
    );
  }

  configurePushNotifications() {
    if (Platform.isIOS) getiOSPermission();
    _firebaseMessaging.getToken().then((token) {
      print("Firebase Messaging Token: $token\n");
      usersRef
          .document(user.uid)
          .updateData({"androidNotificationToken": token});
    });

    _firebaseMessaging.configure(
      onLaunch: (Map<String, dynamic> message) async {
        print("on launch: $message\n");
        final String messageType = message['data']['type'];
        if(messageType == 'message'){
          MyApp.navigatorKey.currentState.pushNamed('/inbox');
        }
        else{
          MyApp.navigatorKey.currentState.pushNamed('/activity_feed');
        }
      },
      onResume: (Map<String, dynamic> message) async {
        print("on resume: $message\n");
        final String messageType = message['data']['type'];
        if(messageType == 'message'){
          MyApp.navigatorKey.currentState.pushNamed('/inbox');
        }
        else{
          MyApp.navigatorKey.currentState.pushNamed('/activity_feed');
        }
      },
      onMessage: (Map<String, dynamic> message) async {
        print("on message: $message\n");
        final String recipientId = message['data']['recipient'];
        final String body = message['notification']['body'];
        if (recipientId == user.uid) {
          print("Notification shown!");
          SnackBar snackBar = SnackBar(
              content: Text(
                body,
                overflow: TextOverflow.ellipsis,
              ));
          _scaffoldKey.currentState.showSnackBar(snackBar);
        }
        print("Notification NOT shown");
      },
    );
  }

  getiOSPermission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(alert: true, badge: true, sound: true));
    _firebaseMessaging.onIosSettingsRegistered.listen((settings) {
      print("Settings registered: $settings");
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: PageView(
        children: <Widget>[
          Timeline(currentUser: user),
          Upload(),
          ActivityFeed(),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
          currentIndex: pageIndex,
          onTap: onTap,
          activeColor: Theme.of(context).primaryColor,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.add_circle,
                size: 35.0,
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_active),
            ),
          ]
      ),
    );
  }
}
