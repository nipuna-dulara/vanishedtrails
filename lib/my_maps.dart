import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'userLogin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:connectivity/connectivity.dart';

class MyMaps extends StatefulWidget {
  MyMaps({Key key}) : super(key: key);

  @override
  _MyMapsState createState() => _MyMapsState();
}

class _MyMapsState extends State<MyMaps> {
  bool _logged = true;
  List<Map> _list = <Map>[];

  void logged() async {
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
    List<Map> list = await database.rawQuery('SELECT * FROM cmaps');
    setState(() {
      _list = list;
    });
    int count = Sqflite.firstIntValue(
        await database.rawQuery('SELECT COUNT(*) FROM user'));
    print(count);
    if (count == 0) {
      setState(() {
        _logged = false;
      });
      await database.close();
    } else {
      setState(() {
        _logged = true;
      });
      await database.close();
    }
  }

  void initState() {
    super.initState();
    logged();
  }

  Future<void> _showMyDialog2() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(''),
          content: Text('No internet connection'),
          actions: <Widget>[
            TextButton(
              child: const Text('ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  List<Widget> mapList() {
    List<Widget> points = <Widget>[];
    for (int i = 0; i < _list.length; i++) {
      var namec;
      if (_list[i]['name'] != null) {
        namec = _list[i]['name'].split('|');
      } else {
        namec = 'empty';
      }
      points.add(Container(
          margin: EdgeInsets.only(top: 10),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9),
              color: Colors.green[200],
              boxShadow: [BoxShadow(color: Colors.grey[400], spreadRadius: 1)]),
          width: MediaQuery.of(context).size.width,
          child: Row(
            children: [
              Expanded(
                  flex: 3,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(namec[0],
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Row(children: [
                          Text(_list[i]['createdDate'],
                              style: TextStyle(
                                  fontStyle: FontStyle.italic, fontSize: 10)),
                          Container(
                              margin: EdgeInsets.only(left: 10),
                              child: Text(_list[i]['type'],
                                  style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.red[800],
                                      fontSize: 13)))
                        ])
                      ])),
              Expanded(
                  flex: 1,
                  child: TextButton(
                      onPressed: () {
                        Navigator.of(context)
                            .pushNamed('/viewMap', arguments: _list[i]['name']);
                      },
                      child: Icon(Icons.remove_red_eye_outlined))),
              Expanded(
                  flex: 2,
                  child: OutlinedButton(
                      onPressed: () async {
                        var connectivityResult =
                            await (Connectivity().checkConnectivity());
                        if (connectivityResult == ConnectivityResult.none) {
                          _showMyDialog2();
                        } else {
                          await Firebase.initializeApp();
                          FirebaseFirestore firestore =
                              FirebaseFirestore.instance;
                        }
                      },
                      child: Row(children: [
                        Icon(Icons.upload_rounded),
                        Text('UPLOAD')
                      ])))
            ],
          )));
    }
    return (points);
  }

  Widget mapListScaffold() {
    return Scaffold(
      body: Container(
          padding: EdgeInsets.only(top: 35),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child:
              ListView(padding: const EdgeInsets.all(8), children: mapList())),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(child: (_logged) ? mapListScaffold() : Content());
  }
}
