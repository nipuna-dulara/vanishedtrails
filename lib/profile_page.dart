import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'userLogin.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _logged = true;
  final picker = ImagePicker();

  void logged() async {
    Database database = await openDatabase('vanishedTrails.db ', version: 1,
        onCreate: (Database db, int version) async {
      // When creating the db, create the table
      await db.execute(
          'CREATE TABLE user (id INTEGER PRIMARY KEY, email TEXT, displayname TEXT, photourl TEXT)');
      await db.execute(
          'CREATE TABLE maps (id INTEGER PRIMARY KEY, name TEXT, status BOOLEAN, completed BOOLEAN, boughtday DATE)');
      await db.execute(
          'CREATE TABLE cmaps (id INTEGER PRIMARY KEY, name TEXT, waterPoints TEXT, type TEXT, photoFiles TEXT, photoLocations TEXT ,campsites TEXT, viewPoints TEXT,photos TEXT, mainMap TEXT, owner TEXT, uploaded BOOLEAN, createdDate TEXT,duration REAL, distance REAL)');
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
    return Container(
        child: (_logged)
            ? ElevatedButton(
                child: Text('camera'),
                onPressed: () async {
                  final pickedFile =
                      await picker.getImage(source: ImageSource.camera);
                  print(pickedFile.path);
                })
            : Content());
  }
}
