import 'package:aapg_myaccount_flutter/models/user.dart';
import 'package:aapg_myaccount_flutter/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/authenticate/authenticate.dart';
import '../screens/home/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/pages/set_up.dart';

final CollectionReference usersRef = Firestore.instance.collection("users");
User user;

class Wrapper extends StatefulWidget {
  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  bool isDocExist;
  @override
  Widget build(BuildContext context) {
    user = Provider.of<User>(context);
    //return home if user logged in or authenticate if not
    if(user == null){
      return Authenticate();
    }else{
      checkUserInFireStore();
      if(isDocExist == true){
        return Home();
      }
      else if(isDocExist == false) {
        return SetUp();
      }else{
        return Loading();
      }
    }
  }

  checkUserInFireStore() async{
    final DocumentSnapshot doc = await usersRef.document(user.uid).get();
    if(!doc.exists){
      setState(() {
        isDocExist = false;
      });
    }else{
      setState(() {
        isDocExist = true;
      });
    }
  }
}
