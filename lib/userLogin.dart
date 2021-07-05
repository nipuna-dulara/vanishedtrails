import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class Content extends StatefulWidget {
  @override
  _ContentState createState() => _ContentState();
}

class _ContentState extends State<Content> {
  bool _isLogged = false;

  GoogleSignInAccount _userObject;
  GoogleSignIn _googleSignIn = GoogleSignIn();

  void dbLogic(GoogleSignInAccount object) async {
    // Get a location using getDatabasesPath
    Database database = await openDatabase('vanishedTrails.db ', version: 1,
        onCreate: (Database db, int version) async {
      // When creating the db, create the table
      await db.execute(
          'CREATE TABLE user (id INTEGER PRIMARY KEY, email TEXT, displayname TEXT, photourl TEXT)');
      await db.execute(
          'CREATE TABLE maps (id INTEGER PRIMARY KEY, name TEXT, status BOOLEAN, completed BOOLEAN, boughtday DATE)');
      await db.execute(
          'CREATE TABLE cmaps (id INTEGER PRIMARY KEY, name TEXT, waterPoints TEXT, type TEXT, photoFiles TEXT, photoLocations TEXT, campsites TEXT, viewPoints TEXT,photos TEXT, mainMap TEXT, owner TEXT, uploaded BOOLEAN, createdDate TEXT,duration REAL, distance REAL)');
    });

    await database.transaction((txn) async {
      int id = await txn.rawInsert(
          'INSERT INTO user(email, displayname, photourl) VALUES (?,?,?)',
          [object.email, object.displayName, object.photoUrl]);
      print('inserted : $id');
    });
    List<Map> list = await database.rawQuery('SELECT * FROM user');
    print(list);
    await database.close();
    await Firebase.initializeApp();
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    // Call the user's CollectionReference to add a new user
    users
        .add({
          'email': object.email, // John Doe
          'displayname': object.displayName, // Stokes and Sons
          'photoUrl': object.photoUrl // 42
        })
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: _isLogged
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                    Image.network(_userObject.photoUrl),
                    Text(_userObject.displayName),
                    Text(_userObject.email)
                  ])
            : Center(
                child: ElevatedButton(
                    child: Text('Sign in with Google'),
                    onPressed: () {
                      _googleSignIn.signIn().then((userData) {
                        setState(() {
                          _isLogged = true;
                          _userObject = userData;
                        });
                        dbLogic(userData);
                      }).catchError((e) {
                        print(e);
                      });
                    })));
  }
}
