import 'dart:io';
import 'package:aapg_myaccount_flutter/models/user.dart';
import 'package:aapg_myaccount_flutter/services/database.dart';
import 'package:aapg_myaccount_flutter/shared/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart'as Im;
import 'package:aapg_myaccount_flutter/shared/wrapper.dart';

final StorageReference storageRef = FirebaseStorage.instance.ref();
final postsRef = Firestore.instance.collection('posts');
final DateTime timestamp = DateTime.now();

class Upload extends StatefulWidget {
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> with AutomaticKeepAliveClientMixin{
  TextEditingController captionController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  File file;
  bool isUploading = false;
  String postId = Uuid().v4();
  UserData userData;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var _formKey = GlobalKey<FormState>();
  bool showSnackBar = false;

  handleTakePhoto() async {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
    );
    setState(() {
      this.file = file;
    });
  }

  handleChooseFromGallery() async {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      this.file = file;
    });
  }

  selectImage(parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: Text("Create Post"),
            children: <Widget>[
              SimpleDialogOption(
                  child: Text("Photo with Camera"), onPressed: handleTakePhoto),
              SimpleDialogOption(
                  child: Text("Image from Gallery"),
                  onPressed: handleChooseFromGallery),
              SimpleDialogOption(
                child: Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        });
  }

  clearImage() {
    setState(() {
      file = null;
    });
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
    final compressedImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
    setState(() {
      file = compressedImageFile;
    });
  }

  Future<String> uploadImage(imageFile) async {
    StorageUploadTask uploadTask =
    storageRef.child("post_$postId.jpg").putFile(imageFile);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  createImagePostInFireStore(
      {String mediaUrl, String location, String description}){
    postsRef
        .document(user.uid)
        .collection("userPosts")
        .document(postId)
        .setData({
      "postId": postId,
      "ownerId": user.uid,
      "userName": userData.userName,
      "mediaUrl": mediaUrl,
      "description": description,
      "location": location,
      "timestamp": timestamp,
      "likes": {},
    });
    setState(() {
      file = null;
      isUploading = false;
      postId = Uuid().v4();
      showSnackBar = true;
    });
  }

  createPostInFireStore(){
    postsRef
        .document(user.uid)
        .collection("userPosts")
        .document(postId)
        .setData({
      "postId": postId,
      "ownerId": user.uid,
      "userName": userData.userName,
      "mediaUrl": "",
      "description": captionController.text,
      "location": locationController.text,
      "timestamp": timestamp,
      "likes": {},
    });
    setState(() {
      isUploading = false;
      postId = Uuid().v4();
      showSnackBar = true;
    });
    captionController.clear();
    locationController.clear();
  }

  handleSubmit() async {
    setState(() {
      isUploading = true;
    });
    await compressImage();
    String mediaUrl = await uploadImage(file);
    createImagePostInFireStore(
      mediaUrl: mediaUrl,
      location: locationController.text,
      description: captionController.text,
    );
    captionController.clear();
    locationController.clear();
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
    )) ?? false;
  }

  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return StreamBuilder<UserData>(
      stream: DatabaseService(uid: user.uid).userData,
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          userData = snapshot.data;
          return WillPopScope(
            onWillPop: _onWillPop,
            child: Scaffold(
              key: _scaffoldKey,
              appBar: AppBar(
                backgroundColor: Theme
                    .of(context)
                    .primaryColor,
                title: Text(
                  'Create Post', style: TextStyle(color: Colors.white),),
                centerTitle: true,
                elevation: 0,
                actions: <Widget>[
                  isUploading ? Container(): FlatButton(
                    onPressed: (){
                      if(file != null){
                        handleSubmit();
                        if(showSnackBar){
                          SnackBar snackBar = SnackBar(
                              content: Text(
                                "Your post has been uploaded successfully.",
                                overflow: TextOverflow.ellipsis,
                              ));
                          _scaffoldKey.currentState.showSnackBar(snackBar);
                        }
                      }
                      else{
                        if(_formKey.currentState.validate()){
                          createPostInFireStore();
                          if(showSnackBar){
                            SnackBar snackBar = SnackBar(
                                content: Text(
                                  "Your post has been uploaded successfully.",
                                  overflow: TextOverflow.ellipsis,
                                ));
                            _scaffoldKey.currentState.showSnackBar(snackBar);
                          }
                        }
                      }
                    },
                    child: Text(
                      "Post",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
              body: ListView(
                children: <Widget>[
                  isUploading ? linearProgress() : Text(''),
                  file == null ? Container() : Container(
                    padding: EdgeInsets.all(10),
                    height: 220.0,
                    width: MediaQuery
                        .of(context)
                        .size
                        .width * 0.8,
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: FileImage(file),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20),
                  ),
                  Form(
                    key: _formKey,
                    child: ListTile(
                      leading: userData.photoUrl.isEmpty? CircleAvatar(
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.person, color: Colors.white, size: 25),
                        radius: 20,
                      ): CircleAvatar(
                        backgroundImage: CachedNetworkImageProvider(userData.photoUrl),
                        radius: 25,
                      ),
                      title: Container(
                        width: 250,
                        child: TextFormField(
                          controller: captionController,
                          // ignore: missing_return
                          validator: (val){
                            if (val.isEmpty){
                              return 'Please Fill this field';
                            }
                          },
                          decoration: InputDecoration(
                            hintText: "What's on your mind? ",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(
                      Icons.pin_drop,
                      color: Theme
                          .of(context)
                          .primaryColor,
                      size: 35,
                    ),
                    title: Container(
                      width: 250,
                      child: TextField(
                        controller: locationController,
                        decoration: InputDecoration(
                          hintText: "Where are you writing this post? ",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 200,
                    height: 100,
                    alignment: Alignment.center,
                    child: RaisedButton.icon(
                      label: Text(
                        "Use Current Location",
                        style: TextStyle(color: Colors.white),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      color: Theme
                          .of(context)
                          .primaryColor,
                      onPressed: () => getUserLocation(),
                      icon: Icon(
                        Icons.my_location,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () => selectImage(context),
                child: Icon(Icons.add_a_photo , color: Colors.white,),
                tooltip: 'Add Photo',
                backgroundColor: Theme.of(context).primaryColor,
              ),
            ),
          );
        }
        else {
          return Container();
        }
      }
    );
  }

  getUserLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placeMarks = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placeMarks[0];
    String completeAddress =
        '${placemark.subThoroughfare} ${placemark.thoroughfare}, ${placemark.subLocality} ${placemark.locality},'
        ' ${placemark.subAdministrativeArea}, ${placemark.administrativeArea} ${placemark.postalCode}, ${placemark.country}';
    print(completeAddress);
    String formattedAddress = "${placemark.administrativeArea}, ${placemark.country}";
    locationController.text = formattedAddress;
  }

}
