import 'package:aapg_myaccount_flutter/models/post.dart';
import 'package:aapg_myaccount_flutter/models/user.dart';
import 'package:aapg_myaccount_flutter/screens/home/home.dart';
import 'package:aapg_myaccount_flutter/shared/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:cached_network_image/cached_network_image.dart';

final CollectionReference messageCollection =
    Firestore.instance.collection("messages");
final CollectionReference inboxRef = Firestore.instance.collection("inbox");
final scaffoldKey = GlobalKey<ScaffoldState>();

class Chat extends StatefulWidget {
  final String currentUserId;
  final String profileId;
  final String groupChatId;
  final String profileOwnerName;
  final String profilePhotoUrl;

  Chat(
      {this.currentUserId,
      this.profileId,
      this.groupChatId,
      this.profileOwnerName,
      this.profilePhotoUrl});

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  TextEditingController messageController = TextEditingController();
  ScrollController scrollController = ScrollController();
  UserData currentUserData;
  UserData profileUserData;
  bool isLoading = false;
  Message message;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    getProfileUser();
    // getMessages();
  }

  getCurrentUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await usersRef.document(widget.currentUserId).get();
    currentUserData = UserData.fromDocument(doc);
    setState(() {
      isLoading = false;
    });
  }

  getProfileUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await usersRef.document(widget.profileId).get();
    profileUserData = UserData.fromDocument(doc);
    setState(() {
      isLoading = false;
    });
  }

  getMessages() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await messageCollection.document().get();
    message = Message.fromDocument(doc);
    setState(() {
      isLoading = false;
    });
  }

  Future<void> callback() async {
    if (messageController.text.length > 0) {
      var documentRef = messageCollection
          .document(widget.groupChatId)
          .collection(widget.groupChatId)
          .document(DateTime.now().millisecondsSinceEpoch.toString());
      await Firestore.instance.runTransaction((transaction) async {
        await transaction.set(
          documentRef,
          {
            'text': messageController.text,
            'from': currentUserData.displayName,
            'ownerId': widget.currentUserId,
            'profileId': widget.profileId,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
          },
        );
      });
      inboxRef
          .document(widget.currentUserId)
          .collection('inboxUsers')
          .document(widget.profileId)
          .setData({
        'inboxUserId': widget.profileId,
        'senderUserId': widget.currentUserId,
        'recipientUserId': widget.profileId,
        'inboxFullName': profileUserData.displayName,
        'inboxUserName': profileUserData.userName,
        'inboxPhotoUrl':
            profileUserData.photoUrl.isNotEmpty ? profileUserData.photoUrl : '',
        'inboxLastMsg': messageController.text,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        'isRead': false
      });
      inboxRef
          .document(widget.profileId)
          .collection('inboxUsers')
          .document(widget.currentUserId)
          .setData({
        'inboxUserId': widget.currentUserId,
        'senderUserId': widget.currentUserId,
        'recipientUserId': widget.profileId,
        'inboxFullName': currentUserData.displayName,
        'inboxUserName': currentUserData.userName,
        'inboxPhotoUrl':
            currentUserData.photoUrl.isNotEmpty ? currentUserData.photoUrl : '',
        'inboxLastMsg': messageController.text,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        'isRead': false
      });
      activityFeedRef
          .document(widget.profileId)
          .collection('feedItems')
          .document(widget.groupChatId)
          .setData({
        'type': 'message',
        'senderId': widget.currentUserId,
        'recipientId': widget.profileId,
        'from': currentUserData.displayName,
        'senderLastMsg': messageController.text
      });
      usersRef
          .document(widget.currentUserId)
          .updateData({'chattingWith': widget.profileId});

      messageController.clear();
      scrollController.animateTo(
        scrollController.position.minScrollExtent,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  Widget buildListMessage() {
    return Flexible(
      child: widget.groupChatId == ''
          ? Center(child: circularProgress())
          : StreamBuilder(
              stream: messageCollection
                  .document(widget.groupChatId)
                  .collection(widget.groupChatId)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: circularProgress());
                } else {
                  List<DocumentSnapshot> docs = snapshot.data.documents;
                  List<Widget> messages = docs
                      .map((doc) => Message(
                            from: doc.data['from'],
                            text: doc.data['text'],
                            me: widget.currentUserId == doc.data['ownerId'],
                          ))
                      .toList();

                  return ListView.builder(
                    controller: scrollController,
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (_, index) {
                      return messages[index];
                    },
                  );
                }
              },
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: ListTile(
          leading:
              widget.profilePhotoUrl.isEmpty || widget.profilePhotoUrl == null
                  ? CircleAvatar(
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, color: Colors.white, size: 30),
                      radius: 20,
                    )
                  : CircleAvatar(
                      backgroundImage:
                          CachedNetworkImageProvider(widget.profilePhotoUrl),
                      radius: 20,
                    ),
          title: Text(
            '${widget.profileOwnerName}',
            style: TextStyle(color: Colors.white , fontSize: 18),
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  buildListMessage(),
                  Container(
                    padding: EdgeInsets.only(top: 10),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            onSubmitted: (value) => callback(),
                            decoration: InputDecoration(
                              hintText: "Enter a Message...",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50)),
                            ),
                            controller: messageController,
                          ),
                        ),
                        SendButton(
                          callback: callback,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class SendButton extends StatelessWidget {
  final VoidCallback callback;

  const SendButton({Key key, this.callback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.send),
      color: Theme.of(context).primaryColor,
      onPressed: callback,
      iconSize: 40,
    );
  }
}

class Message extends StatefulWidget {
  final String from;
  final String text;
  final String ownerId;
  final String profileId;
  final bool me;

  const Message(
      {Key key, this.from, this.text, this.me, this.ownerId, this.profileId})
      : super(key: key);

  factory Message.fromDocument(DocumentSnapshot doc) {
    return Message(
      from: doc['from'],
      text: doc['text'],
      ownerId: doc['ownerId'],
      profileId: doc['profileId'],
    );
  }

  @override
  _MessageState createState() => _MessageState();
}

class _MessageState extends State<Message> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 5),
      child: Column(
        crossAxisAlignment:
            widget.me ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            widget.me ? 'You' : widget.from,
            style: TextStyle(
                color: widget.me
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).accentColor),
          ),
          GestureDetector(
            onLongPress: () {
              Clipboard.setData(ClipboardData(text: widget.text));
              scaffoldKey.currentState.showSnackBar(
                  SnackBar(content: Text("Copied to Clipboard")));
            },
            child: Material(
              color: widget.me
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).accentColor,
              borderRadius: BorderRadius.circular(10),
              elevation: 6,
              child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: GestureDetector(
                    onTap: () {
                      if (widget.text.contains('http')) {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return WebviewScaffold(
                            url: widget.text,
                            appBar: AppBar(
                              title: Text('MyAccount'),
                            ),
                            withZoom: true,
                          );
                        }));
                      }
                    },
                    child: Text(
                      widget.text,
                      style: TextStyle(
                          color: widget.me ? Colors.white : Colors.black,
                          decoration: widget.text.contains('http')
                              ? TextDecoration.underline
                              : TextDecoration.none),
                    ),
                  )),
            ),
          )
        ],
      ),
    );
  }
}
