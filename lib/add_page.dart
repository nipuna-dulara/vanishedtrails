import 'package:flutter/material.dart';
import 'userLogin.dart';
import 'package:sqflite/sqflite.dart';

class AddPage extends StatefulWidget {
  final bool data;
  AddPage({Key key, @required this.data}) : super(key: key);

  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  bool _logged = true;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            child: Row(
      children: [(_logged) ? AddMaps() : Content()],
    )));
  }
}

class AddMaps extends StatefulWidget {
  AddMaps({Key key}) : super(key: key);

  @override
  _AddMapsState createState() => _AddMapsState();
}

class _AddMapsState extends State<AddMaps> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Padding(
            padding: EdgeInsets.only(top: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(left: 15),
                  child:
                      Text('Select category ', style: TextStyle(fontSize: 20)),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: ButtonBar(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ElevatedButton(
                        child: Container(
                            padding: EdgeInsets.all(5),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(Icons.directions_walk_outlined),
                                  Text('hiking', style: TextStyle(fontSize: 15))
                                ])),
                        onPressed: () {
                          Navigator.of(context)
                              .pushNamed('/addhike', arguments: 'hike');
                        },
                      ),
                      ElevatedButton(
                        child: Container(
                            padding: EdgeInsets.all(5),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(Icons.car_repair),
                                  Text('4x4', style: TextStyle(fontSize: 15))
                                ])),
                        onPressed: () {
                          Navigator.of(context)
                              .pushNamed('/addhike', arguments: '4x4');
                        },
                      ),
                      ElevatedButton(
                        child: Container(
                            padding: EdgeInsets.all(5),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(Icons.motorcycle),
                                  Text('Cycling',
                                      style: TextStyle(fontSize: 15))
                                ])),
                        onPressed: () {
                          Navigator.of(context)
                              .pushNamed('/addhike', arguments: 'cycling');
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                    padding: EdgeInsets.all(15),
                    child: Text('Instructions', style: TextStyle(fontSize: 21)))
              ],
            )));
  }
}
