/// Flutter code sample for BottomNavigationBar

// This example shows a [BottomNavigationBar] as it is used within a [Scaffold]
// widget. The [BottomNavigationBar] has three [BottomNavigationBarItem]
// widgets, which means it defaults to [BottomNavigationBarType.fixed], and
// the [currentIndex] is set to index 0. The selected item is
// amber. The `_onItemTapped` function changes the selected item's index
// and displays a corresponding message in the center of the [Scaffold].

import 'package:flutter/material.dart';
import 'Main_Page.dart';

import 'route_generator.dart';
import 'my_maps.dart';
import 'profile_page.dart';
import 'package:sqflite/sqflite.dart';

void main() => runApp(MyApp());

/// This is the main application widget.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '_title',
      theme: ThemeData(
          primarySwatch: Colors.green,
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              primary: Colors.lightBlue[900],
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: TextButton.styleFrom(
              primary: Colors.lightBlue[900],
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                  primary: Colors.green[400],
                  textStyle: TextStyle(color: Colors.lightBlue[900])))),
      initialRoute: '/',
      onGenerateRoute: routeGenerator.generateRoute,
    );
  }
}

/// This is the stateful widget that the main application instantiates.
class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

/// This is the private State class that goes with MyStatefulWidget.
class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  int _selectedIndex = 0;
  bool _floatinVisibility = true;
  bool _logged;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void logged() async {
    Database database = await openDatabase('vanishedTrails.db ', version: 1,
        onCreate: (Database db, int version) async {
      // When creating the db, create the table
      await db.execute(
          'CREATE TABLE user (id INTEGER PRIMARY KEY, email TEXT, displayname TEXT, photourl TEXT)');
      await db.execute(
          'CREATE TABLE maps (id INTEGER PRIMARY KEY, name TEXT, status BOOLEAN, completed BOOLEAN, boughtday DATE)');
      await db.execute(
          'CREATE TABLE cmaps (id INTEGER PRIMARY KEY, name TEXT, waterPoints TEXT, type TEXT, photoFiles TEXT, photoLocations TEXT, campsites TEXT, viewPoints TEXT,photos TEXT, mainMap TEXT, owner TEXT, uploaded BOOLEAN, createdDate TEXT,duration REAL, distance REAL,notes TEXT,noteLocations TEXT)');
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

  Widget component() {
    switch (_selectedIndex) {
      case 0:
        return SearchMap();
      case 1:
        return MyMaps();
      case 2:
        return ProfilePage();
      default:
        return SearchMap();
    }
  }

  void initState() {
    super.initState();
    logged();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: component(),
      ),
      floatingActionButton: Visibility(
        visible: _floatinVisibility,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).pushNamed('/addpage', arguments: _logged);
          },
          backgroundColor: Colors.green[200],
          foregroundColor: Colors.black87,
          focusColor: Colors.lightBlue[900],
          child: Icon(Icons.add),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.green[200],
        selectedItemColor: Colors.lightBlue[900],
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Find',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'My maps',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
