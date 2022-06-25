import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'rfid_screen.dart';
import 'help_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  DashboardScreen({required this.fname});
  var fname;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  var currentUser;
  var uid;
  String name = "";

  Widget stepRow(var step, var node, var val) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, left: 24.0, bottom: 20.0),
      child: Row(
        children: [
          Container(
            height: 25.0,
            width: 25.0,
            decoration: BoxDecoration(
                color: step <= node ? Colors.blue : Colors.grey,
                borderRadius: BorderRadius.all(Radius.circular(20))),
            child: Center(
              child: step <= node
                  ? Icon(
                      Icons.check,
                      color: Colors.white,
                    )
                  : Text(
                      "$step",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          SizedBox(
            width: 14.0,
          ),
          Text(
            val,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget RFID(var rfid, var node, var bagWeight, var flightName, Timestamp t) {
    var temp = t.toDate();
    return ExpansionTile(
      title: Text("RFID : $rfid"),
      leading: Icon(Icons.badge),
      subtitle: Text("weight : " + bagWeight + "Kg" + ", flight : $flightName"),
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 30.0),
              child: Text(
                "Check-In time : ",
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ),
            SizedBox(
              height: 5.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30.0),
              child: Text(
                t.toDate().toString(),
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            stepRow(1, node, "Check-In"),
            SizedBox(
              height: 8.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 35.0),
              child: Container(
                height: 45.0,
                width: 1.0,
                color: Colors.grey,
              ),
            ),
            SizedBox(
              height: 8.0,
            ),
            stepRow(2, node, "Processing"),
            SizedBox(
              height: 8.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 35.0),
              child: Container(
                height: 45.0,
                width: 1.0,
                color: Colors.grey,
              ),
            ),
            SizedBox(
              height: 8.0,
            ),
            stepRow(3, node, "Boarded On Plane"),
          ],
        ),
      ],
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    uid = _auth.currentUser!.uid;
    name = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 181, 75, 103),
        actions: [
          IconButton(
            padding: EdgeInsets.only(right: 15.0),
            tooltip: "Help",
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const HelpScreen()));
            },
            icon: Icon(Icons.help),
          ),
          IconButton(
            padding: EdgeInsets.only(right: 15.0),
            tooltip: "logout",
            onPressed: () async {
              try {
                await _auth.signOut();
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => LoginScreen()));
              } catch (e) {
                print(e);
              }
            },
            icon: Icon(Icons.logout_sharp),
          ),
        ],
        leading: null,
        title: Text(
          "Hello, " +
              widget.fname.toString().substring(0, 1).toUpperCase() +
              widget.fname.toString().substring(1).toLowerCase(),
          style: TextStyle(
            fontSize: 16.0,
          ),
        ),
      ),
      body: Column(
        children: [
          ListTile(
            title: CupertinoSearchTextField(
              placeholder: "Search RFID",
              onChanged: (v) {
                setState(() {
                  name = v;
                });
              },
            ),
          ),
          SizedBox(
            height: 5.0,
          ),
          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('RFID')
                .where('uid', isEqualTo: uid)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }
              if (snapshot.data!.docs.length == 0) {
                return Expanded(
                  child: Container(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.badge,
                        size: 35.0,
                      ),
                      Text("No Bags Available"),
                    ],
                  )),
                );
              }
              return Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var data = snapshot.data!.docs[index].data()
                        as Map<String, dynamic>;
                    if (name.isEmpty) {
                      return RFID(
                          snapshot.data!.docs[index].id,
                          data['node'],
                          data['bagWeight'],
                          data['flightName'],
                          data['timestamp']);
                    }
                    if (snapshot.data!.docs[index].id
                        .toString()
                        .toLowerCase()
                        .startsWith(name.toLowerCase())) {
                      return RFID(
                          snapshot.data!.docs[index].id,
                          data['node'],
                          data['bagWeight'],
                          data['flightName'],
                          data['timestamp']);
                    }
                    return Container();
                  },
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => const AddScreen()));
        },
        tooltip: "Add RFID",
        backgroundColor: Color.fromARGB(255, 181, 75, 103),
        child: Icon(Icons.add),
      ),
    );
  }
}
