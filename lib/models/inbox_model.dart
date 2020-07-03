import 'package:aapg_myaccount_flutter/screens/home/search.dart';
import 'package:aapg_myaccount_flutter/screens/pages/chat.dart';
import 'package:aapg_myaccount_flutter/shared/wrapper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class InboxModel extends StatefulWidget {
  final String inboxUserId;
  final String senderUserId;
  final String recipientUserId;
  final String inboxFullName;
  final String inboxUserName;
  final String inboxPhotoUrl;
  final String inboxLastMsg;
  final bool isRead;

  InboxModel(
      {this.inboxUserId,
      this.senderUserId,
      this.recipientUserId,
      this.inboxFullName,
      this.inboxUserName,
      this.inboxPhotoUrl,
      this.inboxLastMsg,
      this.isRead});

  factory InboxModel.fromDocument(DocumentSnapshot doc) {
    return InboxModel(
      inboxUserId: doc['inboxUserId'],
      senderUserId: doc['senderUserId'],
      recipientUserId: doc['recipientUserId'],
      inboxFullName: doc['inboxFullName'],
      inboxUserName: doc['inboxUserName'],
      inboxPhotoUrl: doc['inboxPhotoUrl'],
      inboxLastMsg: doc['inboxLastMsg'],
      isRead: doc['isRead'],
    );
  }

  @override
  _InboxModelState createState() => _InboxModelState();
}

class _InboxModelState extends State<InboxModel> {
  String currentUserId = user.uid;
  String groupChatId;

  @override
  void initState() {
    super.initState();
    groupChatId = '';
    readLocal();
  }

  readLocal() async {
    if (currentUserId.hashCode <= widget.inboxUserId.hashCode) {
      groupChatId = '$currentUserId-${widget.inboxUserId}';
    } else {
      groupChatId = '${widget.inboxUserId}-$currentUserId';
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(3),
      child: Card(
        elevation: 3,
        child: Container(
          color: Colors.white54,
          child: ListTile(
            onTap: () async {
              await readLocal();
              inboxRef
                  .document(widget.inboxUserId)
                  .collection('inboxUsers')
                  .document(currentUserId)
                  .updateData({'isRead': true});
              inboxRef
                  .document(currentUserId)
                  .collection('inboxUsers')
                  .document(widget.inboxUserId)
                  .updateData({'isRead': true});
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return Chat(
                  currentUserId: currentUserId,
                  profileId: widget.inboxUserId,
                  groupChatId: groupChatId,
                  profileOwnerName: widget.inboxFullName,
                  profilePhotoUrl: widget.inboxPhotoUrl,
                );
              }));
            },
            title: GestureDetector(
              onTap: () => showProfile(context, profileId: widget.inboxUserId),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    widget.inboxFullName,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            leading: GestureDetector(
              onTap: () => showProfile(context, profileId: widget.inboxUserId),
              child: widget.inboxPhotoUrl.isEmpty ||
                      widget.inboxPhotoUrl == null
                  ? CircleAvatar(
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, color: Colors.white, size: 35),
                      radius: 25,
                    )
                  : CircleAvatar(
                      backgroundImage:
                          CachedNetworkImageProvider(widget.inboxPhotoUrl),
                      radius: 25,
                    ),
            ),
            subtitle: Text(
              currentUserId == widget.senderUserId
                  ? 'You: ${widget.inboxLastMsg}'
                  : widget.inboxLastMsg,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontWeight: widget.isRead == false &&
                          currentUserId != widget.senderUserId
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: widget.isRead == false &&
                          currentUserId != widget.senderUserId
                      ? Colors.black
                      : Colors.grey[700]),
            ),
            trailing:
                widget.isRead == false && currentUserId != widget.senderUserId
                    ? Icon(
                        Icons.email,
                        color: Colors.red,
                      )
                    : Text(''),
          ),
        ),
      ),
    );
  }
}
