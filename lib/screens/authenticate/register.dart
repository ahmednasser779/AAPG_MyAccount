
import 'package:aapg_myaccount_flutter/animations/fade_animation.dart';
import 'package:aapg_myaccount_flutter/services/auth.dart';
import 'package:aapg_myaccount_flutter/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

SharedPreferences myPref;

class Register extends StatefulWidget {
  final Function toggleViews;
  Register({this.toggleViews});
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthService _auth = AuthService();
  var _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  String error = '';
  bool loading = false;
  bool _obscureTextPass = true;
  bool _obscureTextConfirm = true;
  String email;
  String password;

  // Toggles the password show status
  void _togglePassword() {
    setState(() {
      _obscureTextPass = !_obscureTextPass;
    });
  }

  void _toggleConfirm(){
    setState(() {
      _obscureTextConfirm = !_obscureTextConfirm;
    });
  }
  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topCenter, colors: [
              Theme.of(context).primaryColor,
              Colors.red[900],
              Colors.red[500]
            ])),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 80),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FadeAnimation(
                      1,
                      Text(
                        "MyAccount",
                        style:
                        TextStyle(color: Colors.white, fontSize: 40),
                      )),
                  SizedBox(
                    height: 10,
                  ),
                  FadeAnimation(
                      1.3,
                      Text(
                        "Create Account",
                        style:
                        TextStyle(color: Colors.white, fontSize: 20),
                      )),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(60),
                        topRight: Radius.circular(60))),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          SizedBox(height: 60),
                          FadeAnimation(
                            1.4,
                            TextFormField(
                              controller: emailController,
                              // ignore: missing_return
                              validator: (val) {
                                if (val.isEmpty) {
                                  return 'Please Enter your email';
                                }
                              },
                              decoration: InputDecoration(
                                  icon: Icon(Icons.email , size: 40, color: Theme.of(context).primaryColor),
                                  labelText: 'Email',
                                  hintText: 'Enter Your Email',
                                  border: OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius.circular(5))),
                            ),
                          ),
                          SizedBox(height: 20),
                          FadeAnimation(
                            1.5,
                            TextFormField(
                              obscureText: _obscureTextPass,
                              controller: passController,
                              // ignore: missing_return
                              validator: (val){
                                if(val.isEmpty){
                                  return 'Please Enter your password';
                                }else if(val.length < 6){
                                  return 'Password must be at least 6 chars';
                                }
                              },
                              decoration: InputDecoration(
                                  icon: Icon(Icons.lock , size: 40, color: Theme.of(context).primaryColor),
                                  labelText: 'Password',
                                  hintText: 'At least 6 characters',
                                  suffixIcon: IconButton(
                                    icon: _obscureTextPass? Icon(Icons.visibility_off): Icon(Icons.visibility),
                                    onPressed: (){
                                      _togglePassword();
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius.circular(5))),
                            ),
                          ),
                          SizedBox(height: 20),
                          FadeAnimation(
                            1.6, TextFormField(
                              obscureText: _obscureTextConfirm,
                              // ignore: missing_return
                              validator: (val){
                                if(val.isEmpty){
                                  return 'Please Confirm your password';
                                }else if(val != passController.text.trim()){
                                  return 'Confirm with value that match your Password';
                                }
                              },
                              decoration: InputDecoration(
                                  icon: Icon(Icons.lock , size: 40, color: Theme.of(context).primaryColor),
                                  labelText: 'Confirm',
                                  hintText: 'Confirm Your Password',
                                  suffixIcon: IconButton(
                                    icon: _obscureTextConfirm? Icon(Icons.visibility_off): Icon(Icons.visibility),
                                    onPressed: (){
                                      _toggleConfirm();
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5)
                                  )
                              ),
                            ),
                          ),
                          SizedBox(height: 30),
                          FadeAnimation(
                            1.7,
                            ButtonTheme(
                              minWidth: 200,
                              height: 50,
                              child: RaisedButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(20)),
                                elevation: 5,
                                color: Color(0xFF8B1122),
                                child: Text('Create Account' , style: TextStyle(color: Colors.white , fontSize: 20)),
                                onPressed: () async{
                                  if(_formKey.currentState.validate()){
                                    setState(() {
                                      loading = true;
                                    });
                                    email = emailController.text.trim();
                                    password = passController.text.trim();
                                    dynamic result = await _auth.registerWithEmailAndPassword(email, password);
                                    if(result == null){
                                      setState(() {
                                        loading = false;
                                      });
                                      if(registerError == "PlatformException(ERROR_INVALID_EMAIL, The email address is badly formatted., null)")
                                      {
                                        setState(() {
                                          error = 'Invalid email, Try again with valid email.';
                                        });
                                      }
                                      else if(registerError == "PlatformException(ERROR_NETWORK_REQUEST_FAILED, A network error (such as timeout, interrupted connection or unreachable host) has occurred., null)")
                                      {
                                        setState(() {
                                          error = 'Check your internet connection.';
                                        });
                                      }
                                      else{
                                        setState(() {
                                          error = 'Something went wrong, Try again.';
                                        });
                                      }
                                    }
                                    else{
                                      myPref = await SharedPreferences.getInstance();
                                      myPref.setString('email', email);
                                      myPref.setString('password', password);
                                    }
                                  }
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            error,
                            style: TextStyle(color: Colors.red),
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          FadeAnimation(
                              1.8,
                              Row(
                                children: <Widget>[
                                  Text(
                                    "Already have an account? ",
                                    style: TextStyle(
                                        color:
                                        Theme.of(context).primaryColor),
                                  ),
                                  GestureDetector(
                                      onTap: (){
                                        widget.toggleViews();
                                      },
                                      child: Text(
                                        "Login",
                                        style: TextStyle(
                                            color:
                                            Theme.of(context).primaryColor,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      )),
                                ],
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
