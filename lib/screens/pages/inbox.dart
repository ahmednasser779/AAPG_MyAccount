import 'package:aapg_myaccount_flutter/models/inbox_model.dart';
import 'package:aapg_myaccount_flutter/screens/pages/chat.dart';
import 'package:aapg_myaccount_flutter/shared/header.dart';
import 'package:aapg_myaccount_flutter/shared/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Inbox extends StatefulWidget {
  final String currentUserId;
  Inbox({this.currentUserId});

  @override
  _InboxState createState() => _InboxState();
}

class _InboxState extends State<Inbox> {
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  List<InboxModel> inboxUsers;

  getInboxUsers() async {
    QuerySnapshot snapshot = await inboxRef
        .document(widget.currentUserId)
        .collection('inboxUsers')
        .orderBy('timestamp', descending: true)
        .getDocuments();
    List<InboxModel> inboxUsers = [];
    snapshot.documents.forEach((doc) {
      inboxUsers.add(InboxModel.fromDocument(doc));
    });
    if (this.mounted) {
      setState(() {
        this.inboxUsers = inboxUsers;
      });
    }
    return inboxUsers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: 'Inbox'),
      body: FutureBuilder(
        future: getInboxUsers(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          return inboxUsers.isEmpty
              ? buildNoContent()
              : RefreshIndicator(
                  key: refreshKey,
                  onRefresh: () => getInboxUsers(),
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
    );
  }

  buildNoContent() {
    return Center(
      child: Image.asset('assets/images/no_content.png'),
    );
  }
}
