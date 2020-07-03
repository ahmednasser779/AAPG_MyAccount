import 'package:aapg_myaccount_flutter/animations/fade_animation.dart';
import 'package:aapg_myaccount_flutter/services/auth.dart';
import 'package:aapg_myaccount_flutter/shared/loading.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  final Function toggleViews;

  SignIn({this.toggleViews});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();
  var _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  String email;
  String password;
  String error = '';
  bool loading = false;
  bool _obscureText = true;

  // Toggles the password show status
  void _togglePassword() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            resizeToAvoidBottomPadding: false,
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
                              "Welcome Back",
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
                                    obscureText: _obscureText,
                                    controller: passController,
                                    // ignore: missing_return
                                    validator: (val) {
                                      if (val.isEmpty) {
                                        return 'Please Enter your password';
                                      }
                                    },
                                    decoration: InputDecoration(
                                        icon: Icon(Icons.lock , size: 40, color: Theme.of(context).primaryColor),
                                        labelText: 'Password',
                                        hintText: 'Enter Your Password',
                                        suffixIcon: IconButton(
                                          icon: _obscureText? Icon(Icons.visibility_off): Icon(Icons.visibility),
                                          onPressed: (){
                                            _togglePassword();
                                          },
                                        ),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(5))),
                                  ),
                                ),
                                SizedBox(height: 30),
                                FadeAnimation(
                                  1.6,
                                  ButtonTheme(
                                    minWidth: 200,
                                    height: 50,
                                    child: RaisedButton(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      elevation: 5,
                                      color: Color(0xFF8B1122),
                                      child: Text('Login',
                                          style: TextStyle(
                                              color: Colors.white, fontSize: 20)),
                                      onPressed: () async {
                                        if (_formKey.currentState.validate()) {
                                          setState(() {
                                            loading = true;
                                          });
                                          email = emailController.text.trim();
                                          password = passController.text.trim();
                                          dynamic result = await _auth
                                              .signInWithEmailAndPassword(
                                                  email, password);
                                          if (result == null) {
                                            setState(() {
                                              loading = false;
                                            });
                                            if(signInError == "PlatformException(ERROR_USER_NOT_FOUND, There is no user record corresponding to this identifier. The user may have been deleted., null)")
                                              {
                                                setState(() {
                                                  error = 'User not found, Please create account first.';
                                                });
                                              }
                                            else if(signInError == "PlatformException(ERROR_NETWORK_REQUEST_FAILED, A network error (such as timeout, interrupted connection or unreachable host) has occurred., null)")
                                            {
                                              setState(() {
                                                error = 'Check your internet connection.';
                                              });
                                            }
                                            else if(signInError == "PlatformException(ERROR_INVALID_EMAIL, The email address is badly formatted., null)")
                                              {
                                                setState(() {
                                                  error = 'Invalid email, Try again with valid email.';
                                                });
                                              }
                                            else if (signInError == "PlatformException(ERROR_WRONG_PASSWORD, The password is invalid or the user does not have a password., null)")
                                              {
                                                setState(() {
                                                  error = 'Wrong Password, Try again with right one.';
                                                });
                                              }
                                            else{
                                              setState(() {
                                                error = 'Something went wrong, Try again.';
                                              });
                                            }
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
                                    1.7,
                                    Row(
                                      children: <Widget>[
                                        Text(
                                          "Don't have an account? ",
                                          style: TextStyle(
                                              color:
                                                  Theme.of(context).primaryColor),
                                        ),
                                        GestureDetector(
                                          onTap: (){
                                            widget.toggleViews();
                                          },
                                            child: Text(
                                          "Create Account",
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
