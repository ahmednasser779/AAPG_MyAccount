import 'dart:io';
import 'package:aapg_myaccount_flutter/screens/home/upload.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as Im;
import 'package:aapg_myaccount_flutter/models/user.dart';
import 'package:aapg_myaccount_flutter/shared/wrapper.dart';
import 'package:aapg_myaccount_flutter/services/auth.dart';
import 'package:aapg_myaccount_flutter/shared/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class EditProfile extends StatefulWidget {
  final String profileId;

  EditProfile({this.profileId});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final AuthService _auth = AuthService();
  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  bool isLoading = false;
  UserData userData;
  var _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String displayName;
  String bio;
  String photoUrl;
  File file;
  bool isUploading = false;
  String picId = Uuid().v4();

  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await usersRef.document(widget.profileId).get();
    userData = UserData.fromDocument(doc);
    displayNameController.text = userData.displayName;
    bioController.text = userData.bio;
    photoUrl = userData.photoUrl;
    setState(() {
      isLoading = false;
    });
  }

  Column buildDisplayNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: Text(
              "Display Name",
              style: TextStyle(color: Colors.grey),
            )),
        TextFormField(
          controller: displayNameController,
          // ignore: missing_return
          validator: (val) {
            if (val.isEmpty) {
              return 'Please Enter your Name';
            } else if (val.trim().length < 3) {
              return 'The name is too short';
            }
          },
          decoration: InputDecoration(
            hintText: "Update your Name",
          ),
        )
      ],
    );
  }

  Column buildBioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: Text(
              "Bio",
              style: TextStyle(color: Colors.grey),
            )),
        TextFormField(
          controller: bioController,
          // ignore: missing_return
          validator: (val) {
            if (val.trim().length > 100) {
              return 'Your bio is too long';
            }
          },
          decoration: InputDecoration(
            hintText: "Say something about yourself...",
          ),
        )
      ],
    );
  }

  selectImage(parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: Text("Edit Profile Picture"),
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

  handleSubmit() async {
    setState(() {
      isUploading = true;
    });
    await compressImage();
    String photoUrl = await uploadImage(file);
    createProfilePicInFireStore(photoUrl: photoUrl);
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
    final compressedImageFile = File('$path/img_$picId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
    setState(() {
      file = compressedImageFile;
    });
  }

  Future<String> uploadImage(imageFile) async {
    StorageUploadTask uploadTask =
        storageRef.child("profilePicture_$picId.jpg").putFile(imageFile);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  createProfilePicInFireStore({String photoUrl}) {
    usersRef.document(widget.profileId).updateData({"photoUrl": photoUrl});
    setState(() {
      isUploading = false;
      picId = Uuid().v4();
    });
    SnackBar snackBar =
        SnackBar(content: Text('Your profile is Updated Successfully.'));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
        title: Text(
          "Edit Profile",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.done,
              size: 30.0,
              color: Colors.green,
            ),
          ),
        ],
      ),
      body: isLoading
          ? circularProgress()
          : ListView(
              children: <Widget>[
                isUploading ? linearProgress() : Text(''),
                Container(
                  child: Column(
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.only(
                            top: 16.0,
                            bottom: 8.0,
                          ),
                          child: GestureDetector(
                              onTap: () {
                                selectImage(context);
                              },
                              child: file == null && photoUrl.isEmpty
                                  ? CircleAvatar(
                                      backgroundColor: Colors.grey,
                                      child: Icon(
                                        Icons.person_add,
                                        color: Colors.white,
                                        size: 70,
                                      ),
                                      radius: 50,
                                    )
                                  : CircleAvatar(
                                      backgroundImage: file != null
                                          ? FileImage(file)
                                          : photoUrl.isNotEmpty
                                              ? CachedNetworkImageProvider(
                                                  photoUrl)
                                              : circularProgress(),
                                      radius: 60,
                                    ))),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: <Widget>[
                              buildDisplayNameField(),
                              buildBioField(),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      isUploading
                          ? Container()
                          : RaisedButton(
                              color: Theme.of(context).primaryColor,
                              onPressed: () {
                                updateProfileData();
                                if (file != null) {
                                  handleSubmit();
                                }
                              },
                              child: Text(
                                "Update Profile",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  updateProfileData() {
    if (_formKey.currentState.validate()) {
      displayName = displayNameController.text;
      bio = bioController.text;
      usersRef
          .document(widget.profileId)
          .updateData({"displayName": displayName, "bio": bio});
      if (file == null) {
        SnackBar snackBar =
            SnackBar(content: Text('Your profile is Updated Successfully.'));
        _scaffoldKey.currentState.showSnackBar(snackBar);
      }
    }
  }
}
