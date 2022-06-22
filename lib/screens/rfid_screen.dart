import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({Key? key}) : super(key: key);

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final rfidNumber = TextEditingController();
  final flightName = TextEditingController();
  final flightNumber = TextEditingController();
  final bagWeight = TextEditingController();
  bool hasErrorRFID = false;
  bool hasErrorFlightName = false;
  bool hasErrorFlightNumber = false;
  bool hasErrorWeight = false;
  bool showSpinner = false;
  var uid;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    uid = _auth.currentUser!.uid;
    hasErrorRFID = false;
    hasErrorFlightName = false;
    hasErrorFlightNumber = false;
    hasErrorWeight = false;
    showSpinner = false;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    rfidNumber.dispose();
    flightName.dispose();
    flightNumber.dispose();
    bagWeight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 181, 75, 103),
        title: Text("Bag Details"),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Hero(
                tag: 'logo',
                child: Container(
                  height: 150.0,
                  child: Image.asset('assets/images/logo 3.jpg'),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: TextField(
                controller: rfidNumber,
                onChanged: (v) {
                  setState(() {
                    hasErrorRFID = false;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Enter RFID number",
                  errorText:
                      hasErrorRFID ? "RFID Number cannot be empty" : null,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.airplane_ticket),
              title: TextField(
                controller: flightName,
                onChanged: (v) {
                  setState(() {
                    hasErrorFlightName = false;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Enter Flight name",
                  errorText:
                      hasErrorFlightName ? "Flight Name cannot be empty" : null,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.confirmation_number),
              title: TextField(
                controller: flightNumber,
                onChanged: (v) {
                  setState(() {
                    hasErrorFlightNumber = false;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Enter Flight number",
                  errorText: hasErrorFlightNumber
                      ? "Flight Number cannot be empty"
                      : null,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.monitor_weight),
              title: TextField(
                controller: bagWeight,
                onChanged: (v) {
                  setState(() {
                    hasErrorWeight = false;
                  });
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Enter bag weight",
                  errorText: hasErrorWeight ? "Weight cannot be empty" : null,
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
              color: Color.fromARGB(255, 181, 75, 103),
              onPressed: () async {
                if (rfidNumber.text == null || rfidNumber.text.length == 0) {
                  setState(() {
                    hasErrorRFID = true;
                  });
                  return;
                }
                if (flightName.text == null || flightName.text.length == 0) {
                  setState(() {
                    hasErrorFlightName = true;
                  });
                  return;
                }
                if (flightNumber.text == null || flightNumber.text.isEmpty) {
                  setState(() {
                    hasErrorFlightNumber = true;
                  });
                  return;
                }
                if (bagWeight.text == null || bagWeight.text.isEmpty) {
                  setState(() {
                    hasErrorWeight = true;
                  });
                  return;
                }
                try {
                  setState(() {
                    showSpinner = true;
                  });
                  await _firestore
                      .collection('RFID')
                      .doc(rfidNumber.text.trim())
                      .set({
                    'uid': uid,
                    'flightName': flightName.text,
                    'flightNumber': flightNumber.text,
                    'bagWeight': bagWeight.text,
                    'node': 0,
                  });
                  var snackBar =
                      SnackBar(content: Text('Bag Added Successfully'));
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  setState(() {
                    showSpinner = false;
                  });
                } catch (e) {
                  setState(() {
                    showSpinner = false;
                  });
                  var snackBar =
                      SnackBar(content: Text('Some error occured try again'));
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
                rfidNumber.clear();
                flightName.clear();
                flightNumber.clear();
                bagWeight.clear();
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
          ],
        ),
      ),
    );
  }
}
