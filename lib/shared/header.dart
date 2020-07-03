import 'package:aapg_myaccount_flutter/screens/home/search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:aapg_myaccount_flutter/services/auth.dart';

final AuthService _auth = AuthService();

AppBar header(context, {bool isAppTitle = false, String titleText}) {
  return AppBar(
    title: Text(
      isAppTitle ? "My Account" : titleText,
      style: TextStyle(
        color: Colors.white,
        fontFamily: isAppTitle ? "Signatra" : "",
        fontSize: isAppTitle ? 40 : 20,
      ),
      overflow: TextOverflow.ellipsis,
    ),
    actions: <Widget>[
      isAppTitle? IconButton(
        icon: Icon(Icons.search),
        color: Colors.white,
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context){
            return Search();
          }));
        },
      ): Container()
    ],
    centerTitle: true,
    backgroundColor: Theme.of(context).primaryColor,
  );
}

AppBar mainHeader(){
  return AppBar(
    title: Text('My Account'),
    backgroundColor: Color(0xFF8B1122),
    elevation: 0,
    actions: <Widget>[
      FlatButton.icon(
        icon: Icon(Icons.person),
        label: Text('Logout'),
        onPressed: () async {
          await _auth.signOut();
        },
      )
    ],
  );
}
