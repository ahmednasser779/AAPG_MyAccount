import 'package:aapg_myaccount_flutter/animations/fade_animation.dart';
import 'package:aapg_myaccount_flutter/models/user.dart';
import 'package:aapg_myaccount_flutter/screens/authenticate/register.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../home/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

final CollectionReference usersRef = Firestore.instance.collection("users");

class SetUp extends StatefulWidget {
  @override
  _SetUpState createState() => _SetUpState();
}

class _SetUpState extends State<SetUp> {
  var _formKey = GlobalKey<FormState>();
  TextEditingController userNameController = TextEditingController();
  TextEditingController displayNameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController aapgIdController = TextEditingController();
  String userName;
  String displayName;
  String phoneNumber;
  String aapgId;
  String currentEmail;
  String currentPassword;
  DateTime timestamp = DateTime.now();
  String error = '';
  bool loading = false;
  bool isBtnClicked = false;
  List<String> faculities = [
    'Choose your Faculty',
    'Petroleum and Mining Engineering',
    'Science',
    'Medicine',
    'Education',
    'Arts and Humanities',
    'Computers and Information',
    'Engineering',
    'Economics and Politics Science',
    'Fish Resources and Marine Studies',
    'Industrial Education',
    'Commerce',
    'Islamic and Arabic Studies',
    'High Canal Institute for Technology and Engineering',
    'Suez Institute for Management',
    'Other'
  ];
  String faculty = 'Choose your Faculty';
  bool isFacultyChosen = false;
  List<String> departments = ['Choose your Department', 'Other'];
  List<String> generalDepartments = ['Choose your Department', 'General'];
  String department = 'Choose your Department';
  bool isDepChosen = false;
  List<String> petroleumDepartments = [
    'Choose your Department',
    'General',
    'Petroleum Engineering',
    'Refining and Petrochemical Engineering',
    'Metallurgical and Materials Engineering',
    'Mining Engineering',
    'Geological and Geophysical Engineering',
    'Petroleum Exploration and Production Engineering',
    'Other'
  ];
  List<String> scienceDepartments = [
    'Choose your Department',
    'Physics',
    'General Chemistry',
    'Biochemistry',
    'Biotechnology',
    'Microbiology',
    'Mathematics',
    'Petroleum Geology',
    'Information Technology',
    'Other'
  ];
  List<String> educationDepartments = [
    'Choose your Department',
    'French',
    'English',
    'Arabic and Islamic Studies',
    'Science',
    'Educational Technology',
    'Artistic',
    'Kindergarten',
    'Biology',
    'Chemistry',
    'Mathematics',
    'Other'
  ];
  List<String> artsDepartments = [
    'Choose your Department',
    'English',
    'French',
    'Arabic Language and Literature',
    'Sociology',
    'Environmental Science and Geographic Information System',
    'History',
    'Philosophy',
    'Other'
  ];
  List<String> fishResDepartments = [
    'Choose your Department',
    'Aquaculture',
    'Fisheries',
    'Marine Engineering',
    'Marine Navigation',
    'Marine Safety',
    'Other'
  ];
  List<String> commerceDepartments = [
    'Choose your Department',
    'Accounting',
    'Business Administration',
    'Other'
  ];
  List<String> engineeringDepartments = [
    'Choose your Department',
    'Civil Engineering',
    'Mechanical Engineering',
    'Other'
  ];
  List<String> suezInistatueDepartments = [
    'Choose your Department',
    'Business Administration',
    'Other'
  ];
  List<String> islamicDepartments = [
    'Choose your Department',
    'Usul El Deen',
    'Other'
  ];
  List<String> ma3hadDepartments = [
    'Choose your Department',
    'Refining of Petroleum',
    'Metals',
    'Chemistry',
    'Other'
  ];
  List<String> years = [
    'Choose the year',
    'Preparatory',
    'First year',
    'Second year',
    'Third year',
    'Fourth year'
  ];
  String year = 'Choose the year';
  bool isYearChosen = false;
  List<String> positions = [
    'Choose your Position',
    'Member',
    'Head Assistant',
    'Ex Head Assistant',
    'Head',
    'Ex Head',
    'Officer',
    'Ex Officer',
    'Vice-officer',
    'President',
    'Ex President',
    'Vice-president',
    'Ex Vice-president',
    'Programs Coordinator',
    'Trainer',
    'Ex Trainer',
    'Editor-In-Chief',
    'Ex Editor-In-Chief',
    'Secretary Deputy',
    'Ex Secretary Deputy'
  ];
  String position = 'Choose your Position';
  bool isPositionChosen = false;
  List<String> coordinations = [
    'Choose your coordination',
    'Marketing Coordination',
    'Executive Coordination',
    'HR Coordination',
    'Academy Coordination',
    'Secretary Coordination',
    'Treasury Coordination'
  ];
  String coordination = 'Choose your coordination';
  bool isCoordinationChosen = false;
  bool isCoordinationVisible = false;
  bool isCoordinationError = false;
  List<String> committees = ['Choose your committee', 'More than one'];
  String committee = 'Choose your committee';
  bool isCommitteeChosen = false;
  bool isCommitteeVisible = false;
  bool isCommitteeError = false;
  List<String> hrCommittees = ['Choose your committee', 'Human Resources(HR)'];
  List<String> marketingCommittees = [
    'Choose your committee',
    'Information Technology Web(IT Web)',
    'Information Technology App(IT App)',
    'Social Media',
    'Media'
  ];
  List<String> executiveCommittees = [
    'Choose your committee',
    'Direct publicity(DP)',
    'Operations Committee(OC)'
  ];
  List<String> academyCommittees = [
    'Choose your committee',
    'Academy El Gamaa',
    'Academy Petrol'
  ];
  List<String> secretaryCommittees = [
    'Choose your committee',
    'Magazine',
    'Other'
  ];
  List<String> treasuryCommittees = [
    'Choose your committee',
    'Public Relations(PR)'
  ];

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async{
    myPref = await SharedPreferences.getInstance();
    currentEmail = myPref.getString('email');
    currentPassword = myPref.getString('password');
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    createUserInFireStore() async {
      usersRef.document(user.uid).setData({
        "userName": userName,
        "displayName": displayName,
        "searchKey": displayName[0],
        'email': currentEmail,
        'password': currentPassword,
        "phoneNumber": phoneNumber,
        'AAPGID': aapgId,
        'timestamp': timestamp,
        "bio": '',
        "photoUrl": '',
        "uid": user.uid,
        'faculty': faculty,
        'department': department,
        'year': year,
        'position': position,
        'coordination': coordination,
        'committeee': committee
      });
      // make new user their own follower (to include their posts in their timeline)
      /* await followersRef
          .document(user.uid)
          .collection('userFollowers')
          .document(user.uid)
          .setData({});*/
    }

    return isBtnClicked
        ? Home()
        : Scaffold(
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
                              "Set up your account",
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
                                SizedBox(height: 20),
                                FadeAnimation(
                                  1.4,
                                  Center(
                                    child: Text(
                                      'Personal Info',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 35),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                                FadeAnimation(
                                  1.5,
                                  TextFormField(
                                    controller: displayNameController,
                                    // ignore: missing_return
                                    validator: (val) {
                                      if (val.isEmpty) {
                                        return 'Please Enter your name';
                                      } else if (val.length < 3) {
                                        return 'Your Name is too short';
                                      }
                                    },
                                    decoration: InputDecoration(
                                        labelText: 'Full Name',
                                        hintText: 'Enter Your Full Name',
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        icon: Icon(Icons.person,
                                            size: 40,
                                            color: Theme.of(context)
                                                .primaryColor)),
                                  ),
                                ),
                                SizedBox(height: 20),
                                FadeAnimation(
                                  1.6,
                                  TextFormField(
                                    controller: userNameController,
                                    // ignore: missing_return
                                    validator: (val) {
                                      if (val.isEmpty) {
                                        return 'Please Enter user name';
                                      } else if (val.length < 3) {
                                        return 'User Name is too short';
                                      }
                                    },
                                    decoration: InputDecoration(
                                        labelText: 'User Name',
                                        hintText: 'cannot change it later',
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        icon: Icon(Icons.person_outline,
                                            size: 40,
                                            color: Theme.of(context)
                                                .primaryColor)),
                                  ),
                                ),
                                SizedBox(height: 20),
                                FadeAnimation(
                                  1.7,
                                  TextFormField(
                                    controller: phoneNumberController,
                                    // ignore: missing_return
                                    validator: (val) {
                                      if (val.isEmpty) {
                                        return 'Please Enter your Phone Number';
                                      }
                                    },
                                    decoration: InputDecoration(
                                        labelText: 'Phone Number',
                                        hintText: 'Enter your Phone Number',
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        icon: Icon(Icons.phone_android,
                                            size: 40,
                                            color: Theme.of(context)
                                                .primaryColor)),
                                    keyboardType: TextInputType.phone,
                                  ),
                                ),
                                SizedBox(height: 30),
                                Divider(height: 2),
                                SizedBox(height: 20),
                                FadeAnimation(
                                  1.8,
                                  Center(
                                    child: Text(
                                      'Education Info',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 35),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                                FadeAnimation(
                                  1.9,
                                  DropdownButtonFormField(
                                    isDense: false,
                                    isExpanded: true,
                                    value: faculty ?? '',
                                    items: faculities
                                        .map((faculty) {
                                          return DropdownMenuItem(
                                            value: faculty,
                                            child: Text('$faculty',
                                                overflow:
                                                    TextOverflow.ellipsis),
                                          );
                                        })
                                        .toSet()
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        faculty = value;
                                        isFacultyChosen = true;
                                        if (isDepChosen) {
                                          setState(() {
                                            departments = departments;
                                            department = departments[0];
                                          });
                                        }
                                        faculities = [
                                          'Choose your Faculty',
                                          'Petroleum and Mining Engineering',
                                          'Science',
                                          'Medicine',
                                          'Education',
                                          'Arts and Humanities',
                                          'Computers and Information',
                                          'Engineering',
                                          'Economics and Politics Science',
                                          'Fish Resources and Marine Studies',
                                          'Industrial Education',
                                          'Commerce',
                                          'Islamic and Arabic Studies',
                                          'High Canal Institute for Technology and Engineering',
                                          'Suez Institute for Management',
                                          'Other'
                                        ];
                                        if (faculty ==
                                            'Petroleum and Mining Engineering') {
                                          setState(() {
                                            departments = petroleumDepartments;
                                          });
                                        } else if (faculty == 'Science') {
                                          setState(() {
                                            departments = scienceDepartments;
                                          });
                                        } else if (faculty == 'Education') {
                                          setState(() {
                                            departments = educationDepartments;
                                          });
                                        } else if (faculty ==
                                            'Arts and Humanities') {
                                          setState(() {
                                            departments = artsDepartments;
                                          });
                                        } else if (faculty == 'Engineering') {
                                          setState(() {
                                            departments =
                                                engineeringDepartments;
                                          });
                                        } else if (faculty ==
                                            'Fish Resources and Marine Studies') {
                                          setState(() {
                                            departments = fishResDepartments;
                                          });
                                        } else if (faculty == 'Commerce') {
                                          setState(() {
                                            departments = commerceDepartments;
                                          });
                                        } else if (faculty ==
                                            'Islamic and Arabic Studies') {
                                          setState(() {
                                            departments = islamicDepartments;
                                          });
                                        } else if (faculty ==
                                            'High Canal Institute for Technology and Engineering') {
                                          setState(() {
                                            departments = ma3hadDepartments;
                                          });
                                        } else if (faculty ==
                                            'Suez Institute for Management') {
                                          setState(() {
                                            departments =
                                                suezInistatueDepartments;
                                          });
                                        } else {
                                          setState(() {
                                            departments = generalDepartments;
                                          });
                                        }
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(height: 20),
                                isFacultyChosen &&
                                        faculty != 'Choose your Faculty'
                                    ? DropdownButtonFormField(
                                        isDense: false,
                                        isExpanded: true,
                                        value: department ?? '',
                                        items: departments
                                            .map((department) {
                                              return DropdownMenuItem(
                                                value: department,
                                                child: Text(
                                                  '$department',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              );
                                            })
                                            .toSet()
                                            .toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            department = value;
                                            isDepChosen = true;
                                            if (isYearChosen) {
                                              setState(() {
                                                years = years;
                                                year = years[0];
                                              });
                                            }
                                          });
                                        },
                                      )
                                    : Container(),
                                SizedBox(height: 20),
                                isDepChosen &&
                                        department != 'Choose your Department'
                                    ? DropdownButtonFormField(
                                        isDense: false,
                                        isExpanded: true,
                                        value: year ?? '',
                                        items: years
                                            .map((year) {
                                              return DropdownMenuItem(
                                                value: year,
                                                child: Text(
                                                  '$year',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              );
                                            })
                                            .toSet()
                                            .toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            year = value;
                                            isYearChosen = true;
                                          });
                                        },
                                      )
                                    : Container(),
                                SizedBox(height: 30),
                                Divider(height: 2),
                                SizedBox(height: 20),
                                FadeAnimation(
                                  2,
                                  Center(
                                    child: Text(
                                      'Chapter Info',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 35),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                                FadeAnimation(
                                  2.1,
                                  TextFormField(
                                    controller: aapgIdController,
                                    // ignore: missing_return
                                    validator: (val) {
                                      if (val.isEmpty) {
                                        return 'Please Enter your AAPG ID';
                                      }
                                    },
                                    decoration: InputDecoration(
                                        labelText: 'AAPG ID',
                                        hintText: 'Enter your AAPG ID',
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        icon: Icon(Icons.perm_contact_calendar,
                                            size: 40,
                                            color: Theme.of(context)
                                                .primaryColor)),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                SizedBox(height: 20),
                                FadeAnimation(
                                  2.2,
                                  DropdownButtonFormField(
                                    isDense: false,
                                    isExpanded: true,
                                    value: position,
                                    items: positions
                                        .map((position) {
                                          return DropdownMenuItem(
                                            value: position,
                                            child: Text(
                                              '$position',
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          );
                                        })
                                        .toSet()
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        position = value;
                                        isPositionChosen = true;
                                        if (isCoordinationChosen) {
                                          setState(() {
                                            coordinations = coordinations;
                                            coordination = coordinations[0];
                                          });
                                        }
                                      });
                                      if (isPositionChosen &&
                                          position != 'Choose your Position' &&
                                          position != 'President' &&
                                          position != 'Ex President' &&
                                          position != 'Vice-president' &&
                                          position != 'Ex Vice-president' &&
                                          position != 'Programs Coordinator' &&
                                          position != 'Trainer' &&
                                          position != 'Ex Trainer' &&
                                          position != 'Secretary Deputy' &&
                                          position != 'Ex Secretary Deputy') {
                                        setState(() {
                                          isCoordinationVisible = true;
                                        });
                                      } else {
                                        setState(() {
                                          isCoordinationVisible = false;
                                        });
                                      }
                                    },
                                  ),
                                ),
                                SizedBox(height: 20),
                                isPositionChosen &&
                                    position != 'Choose your Position' &&
                                    position != 'President' &&
                                    position != 'Ex President' &&
                                    position != 'Vice-president' &&
                                    position != 'Ex Vice-president' &&
                                    position != 'Programs Coordinator' &&
                                    position != 'Trainer' &&
                                    position != 'Ex Trainer' &&
                                    position != 'Secretary Deputy' &&
                                    position != 'Ex Secretary Deputy'
                                    ? DropdownButtonFormField(
                                        isDense: false,
                                        isExpanded: true,
                                        value: coordination,
                                        items: coordinations
                                            .map((coordination) {
                                              return DropdownMenuItem(
                                                value: coordination,
                                                child: Text(
                                                  '$coordination',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              );
                                            })
                                            .toSet()
                                            .toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            coordination = value;
                                            isCoordinationChosen = true;
                                            if (isCommitteeChosen) {
                                              setState(() {
                                                committees = committees;
                                                committee = committees[0];
                                              });
                                            }
                                            if (coordination ==
                                                'HR Coordination') {
                                              setState(() {
                                                committees = hrCommittees;
                                              });
                                            } else if (coordination ==
                                                'Marketing Coordination') {
                                              setState(() {
                                                committees =
                                                    marketingCommittees;
                                              });
                                            } else if (coordination ==
                                                'Executive Coordination') {
                                              setState(() {
                                                committees =
                                                    executiveCommittees;
                                              });
                                            } else if (coordination ==
                                                'Secretary Coordination') {
                                              setState(() {
                                                committees =
                                                    secretaryCommittees;
                                              });
                                            } else if (coordination ==
                                                'Academy Coordination') {
                                              setState(() {
                                                committees = academyCommittees;
                                              });
                                            } else if (coordination ==
                                                'Treasury Coordination') {
                                              setState(() {
                                                committees = treasuryCommittees;
                                              });
                                            } else {
                                              setState(() {
                                                committees = committees;
                                              });
                                            }
                                          });

                                          if(
                                          isCoordinationChosen &&
                                              coordination !=
                                                  'Choose your coordination' &&
                                              position != 'Officer' &&
                                              position != 'Ex Officer' &&
                                              position != 'Vice-officer'
                                          ){
                                            setState(() {
                                              isCommitteeVisible = true;
                                            });
                                          }
                                          else{
                                            setState(() {
                                              isCommitteeVisible = false;
                                            });
                                          }
                                        },
                                      )
                                    : Container(),
                                SizedBox(height: 20),
                                isCoordinationChosen &&
                                    coordination !=
                                        'Choose your coordination' &&
                                    position != 'Officer' &&
                                    position != 'Ex Officer' &&
                                    position != 'Vice-officer'
                                    ? DropdownButtonFormField(
                                        isDense: false,
                                        isExpanded: true,
                                        value: committee,
                                        items: committees
                                            .map((committee) {
                                              return DropdownMenuItem(
                                                value: committee,
                                                child: Text(
                                                  '$committee',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              );
                                            })
                                            .toSet()
                                            .toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            committee = value;
                                            isCommitteeChosen = true;
                                          });
                                        },
                                      )
                                    : Container(),
                                SizedBox(height: 20),
                                Text(
                                  error,
                                  style: TextStyle(color: Colors.red),
                                ),
                                SizedBox(height: 30),
                                FadeAnimation(
                                  2.3,
                                  ButtonTheme(
                                    minWidth: 200,
                                    height: 50,
                                    child: RaisedButton(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      elevation: 5,
                                      color: Color(0xFF8B1122),
                                      child: Text('Save',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20)),
                                      onPressed: () async {
                                        if (isCoordinationVisible &&
                                            isCoordinationChosen == false ) {
                                          setState(() {
                                            isCoordinationError = true;
                                          });
                                        }
                                        else if(
                                        isCoordinationVisible &&
                                        isCoordinationChosen &&
                                            coordination ==
                                                'Choose your coordination'
                                        ){
                                          setState(() {
                                            isCoordinationError = true;
                                          });
                                        }
                                        else{
                                          setState(() {
                                            isCoordinationError = false;
                                          });
                                        }

                                        if (isCommitteeVisible&&
                                            isCommitteeChosen == false ) {
                                          setState(() {
                                            isCommitteeError = true;
                                          });
                                        }
                                        else if(
                                        isCommitteeVisible &&
                                            isCommitteeChosen &&
                                            committee ==
                                                'Choose your committee'
                                        ){
                                          setState(() {
                                            isCommitteeError = true;
                                          });
                                        }
                                        else{
                                          setState(() {
                                            isCommitteeError = false;
                                          });
                                        }

                                        if (_formKey.currentState.validate()) {
                                          if (isFacultyChosen &&
                                              faculty !=
                                                  'Choose your Faculty' &&
                                              isDepChosen &&
                                              department !=
                                                  'Choose your Department' &&
                                              isYearChosen &&
                                              year != 'Choose the year' &&
                                              isPositionChosen &&
                                              position !=
                                                  'Choose your Position' &&
                                              isCoordinationError == false &&
                                          isCommitteeError == false
                                          ) {
                                            setState(() {
                                              loading = true;
                                            });
                                            userName = userNameController.text;
                                            displayName =
                                                displayNameController.text;
                                            phoneNumber =
                                                phoneNumberController.text;
                                            aapgId = aapgIdController.text;
                                            createUserInFireStore();
                                            setState(() {
                                              isBtnClicked = true;
                                            });
                                          } else {
                                            setState(() {
                                              error =
                                                  'Please fill all the fields';
                                            });
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                ),
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
