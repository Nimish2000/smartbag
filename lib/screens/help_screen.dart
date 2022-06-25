import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final rfidNumber = TextEditingController();
  final message = TextEditingController();
  var email;
  var uid;
  bool showSpinner = false;
  bool hasRfidError = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    email = _auth.currentUser!.email;
    uid = _auth.currentUser!.uid;
    showSpinner = false;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    rfidNumber.dispose();
    message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(245, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 181, 75, 103),
        title: Text("Help Center"),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Tooltip(
              child: Icon(Icons.info),
              message:
                  "If a bag is not reached in 15 min from origin time please complain",
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Hero(
                tag: 'logo',
                child: Container(
                  height: 175.0,
                  child: Image.asset('assets/images/help_logo.jpeg'),
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.04,
            ),
            ListTile(
              leading: Icon(Icons.numbers),
              title: TextField(
                onChanged: (v) {
                  setState(() {
                    hasRfidError = false;
                  });
                },
                controller: rfidNumber,
                decoration: InputDecoration(
                  hintText: "Enter RFID number",
                  errorText: hasRfidError ? "RFID cannot be empty" : null,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.question_answer_sharp),
              title: TextFormField(
                controller: message,
                decoration: InputDecoration(
                  hintText: "Please decribe your issue",
                ),
                maxLines: 3,
                maxLength: 100,
                keyboardType: TextInputType.multiline,
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            RaisedButton(
              elevation: 5.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
              ),
              color: Color.fromARGB(255, 181, 75, 103),
              onPressed: () async {
                if (rfidNumber.text.isEmpty) {
                  setState(() {
                    hasRfidError = true;
                  });
                  return;
                }
                setState(() {
                  showSpinner = true;
                });
                try {
                  await _firestore
                      .collection('queries')
                      .doc(rfidNumber.text)
                      .set({
                    "email": email,
                    "uid": uid,
                    "message": message.text,
                  });
                  setState(() {
                    showSpinner = false;
                  });
                  var snackBar =
                      SnackBar(content: Text('Query send successfully!!'));
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                } catch (e) {
                  setState(() {
                    showSpinner = false;
                  });
                  var snackBar =
                      SnackBar(content: Text('Some error occured try again'));
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
                rfidNumber.clear();
                message.clear();
              },
              child: showSpinner
                  ? CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : Text(
                      "Submit",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text("Instructions:"),
              trailing: Text(""),
              subtitle: Text(
                  "If the bag is not reached in 15 min between any checkpoints please complain !!"),
            ),
          ],
        ),
      ),
    );
  }
}
