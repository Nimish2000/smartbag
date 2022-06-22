import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final fname = TextEditingController();
  final lname = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  bool showSpinner = false;
  bool showPassword = false;
  bool hasErrorPassword = false;
  bool hasErrorName = false;
  bool hasErrorEmail = false;

  @override
  void dispose() {
    // TODO: implement dispose
    fname.dispose();
    lname.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    height: 150.0,
                    child: Image.asset('assets/images/appLogo.jpg'),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.04,
              ),
              ListTile(
                leading: Icon(Icons.home),
                title: TextField(
                  controller: fname,
                  onChanged: (v) {
                    setState(() {
                      hasErrorName = false;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Enter first name",
                    errorText:
                        hasErrorName ? "First name cannot be null" : null,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.contact_mail_outlined),
                title: TextField(
                  controller: lname,
                  decoration: InputDecoration(
                    hintText: "Enter last name",
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.email),
                title: TextField(
                  onChanged: (v) {
                    setState(() {
                      hasErrorEmail = false;
                    });
                  },
                  controller: email,
                  decoration: InputDecoration(
                    hintText: "Enter email",
                    errorText:
                        hasErrorEmail ? "Enter email in correct format" : null,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.password),
                title: TextField(
                  controller: password,
                  onChanged: (v) {
                    setState(() {
                      hasErrorPassword = false;
                    });
                  },
                  obscureText: !showPassword,
                  decoration: InputDecoration(
                    hintText: "Enter password",
                    errorText: hasErrorPassword
                        ? "Password should contain special character"
                        : null,
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.04,
              ),
              RaisedButton(
                elevation: 5.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
                color: Colors.blueGrey,
                onPressed: () async {
                  if (fname == null || fname.text.length == 0) {
                    setState(() {
                      hasErrorName = true;
                    });
                    return;
                  }
                  bool emailValid = RegExp(
                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                      .hasMatch(email.text);

                  if (!emailValid) {
                    setState(() {
                      hasErrorEmail = true;
                    });
                    return;
                  }
                  bool hasSpecialCharacters = password.text
                      .contains(new RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
                  if (!hasSpecialCharacters) {
                    setState(() {
                      hasErrorPassword = true;
                    });
                    return;
                  }
                  setState(() {
                    showSpinner = true;
                  });
                  try {
                    final newUser = await _auth.createUserWithEmailAndPassword(
                        email: email.text, password: password.text);

                    if (newUser != null) {
                      //Navigate to dashboard
                      var uid = _auth.currentUser!.uid;
                      print(uid);
                      await _firestore.collection('users').add({
                        'fname': fname.text,
                        'lname': lname.text,
                        'email': email.text,
                        'uid': uid,
                      });
                      var temp = fname.text;
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => DashboardScreen(
                            fname: temp,
                          ),
                        ),
                      );
                      print("New User created");
                      setState(() {
                        showSpinner = false;
                      });
                    }
                  } catch (e) {
                    setState(() {
                      showSpinner = false;
                    });
                    var snackBar =
                        SnackBar(content: Text('Some error occured try again'));
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    fname.clear();
                    lname.clear();
                    email.clear();
                    password.clear();
                  }
                  setState(() {
                    showSpinner = false;
                  });

                  fname.clear();
                  lname.clear();
                  email.clear();
                  password.clear();
                },
                child: showSpinner
                    ? CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : Text(
                        "Submit",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.03,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have account? "),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => LoginScreen()));
                    },
                    child: Text(
                      "Login",
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
