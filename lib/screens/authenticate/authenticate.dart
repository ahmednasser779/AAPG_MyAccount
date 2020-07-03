import 'package:aapg_myaccount_flutter/screens/authenticate/register.dart';
import 'package:aapg_myaccount_flutter/screens/authenticate/sign_in.dart';
import 'package:flutter/material.dart';

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  bool showSignIn = true;
  void toggleViews(){
    setState(() {
      showSignIn = !showSignIn;
    });
  }
  @override
  Widget build(BuildContext context) {
    if(showSignIn){
      return SignIn(toggleViews: this.toggleViews);
    }else{
      return Register(toggleViews: this.toggleViews);
    }
  }
}
