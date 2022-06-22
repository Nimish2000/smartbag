import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartbag/constants.dart';
import 'signup_screen.dart';
import 'dashboard_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

bool isWrong = false;

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  bool showSpinner = false;
  final email = TextEditingController();
  final password = TextEditingController();
  final _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    // TODO: implement dispose
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Flexible(
              child: Hero(
                tag: 'logo',
                child: Container(
                  height: 175.0,
                  child: Image.asset('assets/images/appLogo.jpg'),
                ),
              ),
            ),
            SizedBox(
              height: 52.0,
            ),
            TextField(
              keyboardType: TextInputType.emailAddress,
              textAlign: TextAlign.center,
              controller: email,
              decoration: kTextFileDecoration.copyWith(
                hintText: 'Enter your mail',
                errorText: isWrong ? 'invalid mail' : null,
              ),
            ),
            SizedBox(
              height: 8.0,
            ),
            TextField(
              obscureText: true,
              keyboardType: TextInputType.visiblePassword,
              textAlign: TextAlign.center,
              controller: password,
              decoration: kTextFileDecoration.copyWith(
                hintText: 'Enter your password',
              ),
            ),
            SizedBox(
              height: 24.0,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Material(
                elevation: 5.0,
                color: Colors.blue,
                borderRadius: BorderRadius.circular(30.0),
                child: MaterialButton(
                  onPressed: () async {
                    setState(() {
                      showSpinner = true;
                    });
                    try {
                      final user = await _auth.signInWithEmailAndPassword(
                          email: email.text, password: password.text);
                      if (user != null) {
                        //Navigate to dashboard
                        print("Success");

                        var uid = user.user!.uid;
                        var currentUser;
                        var data = await _firestore
                            .collection('users')
                            .where('uid', isEqualTo: uid)
                            .get();
                        for (var doc in data.docs) {
                          print(doc.get('fname'));
                          currentUser = doc.get('fname');
                        }

                        setState(() {
                          showSpinner = false;
                        });

                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => DashboardScreen(
                                  fname: currentUser,
                                )));
                      }
                    } catch (e) {
                      print("Some Error");
                      setState(() {
                        showSpinner = false;
                      });
                      var snackBar =
                          SnackBar(content: Text('Invalid Crdentials!!'));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                    email.clear();
                    password.clear();
                  },
                  minWidth: 200.0,
                  height: 42.0,
                  child: showSpinner
                      ? CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Didn't have account?"),
                  InkWell(
                    onTap: () {
                      //Navigate to main screen
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => SignupScreen()));
                    },
                    child: Text(
                      "Signup",
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    ),
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
