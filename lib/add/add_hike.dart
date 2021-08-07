import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:user_location/user_location.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:image_picker/image_picker.dart';
import 'package:percent_indicator/percent_indicator.dart';

class AddHike extends StatefulWidget {
  final String data;
  AddHike({Key key, @required this.data}) : super(key: key);
  @override
  _AddHikeState createState() => _AddHikeState();
}

class _AddHikeState extends State<AddHike> {
  String _mapName;
  String _mapFileName;
  String _filePath;
  int _count = 0;
  bool _live = false;
  bool _close = false;
  LatLng _startLocation;
  String _user;
  String _Note = '';
  bool _viewNote = false;
  bool _photos = false;
  bool _viewPhotos = false;
  bool _removeItems = false;
  double _distance = 0;
  double _distancec = 0;
  double _duration = 0;
  double _precentage;

  List<LatLng> _waterPoints = <LatLng>[];
  List<LatLng> _noteLocations = <LatLng>[];
  List<LatLng> _viewPoints = <LatLng>[];
  List<LatLng> _campSites = <LatLng>[];
  List<LatLng> _latlongs = <LatLng>[];
  List<String> _photoFiles = <String>[];
  List<String> _notes = <String>[];
  List<LatLng> _photoLocations = <LatLng>[];
  List<LatLng> _temperaryLatlngs = <LatLng>[];
  File _image;
  File _viewImage;
  Color _polylineColor = Colors.black;
  final picker = ImagePicker();
  void start(String name) async {
    var type = widget.data;
    switch (type) {
      case 'hike':
        setState(() {
          _polylineColor = Colors.black;
        });
        break;
      case '4x4':
        setState(() {
          _polylineColor = Colors.green[900];
        });
        break;
      case 'cycling':
        setState(() {
          _polylineColor = Colors.blue[900];
        });
        break;
      default:
        setState(() {
          _polylineColor = Colors.black;
        });
    }
    double distanceInMeters;
    final directorym = await getApplicationDocumentsDirectory();
    final directoryf = directorym.path;
    final myDir = Directory('$directoryf/cmaps');
    print(myDir.path);
    var isThere = await myDir.exists();
    if (isThere) {
      print('directort');
      var directory = await Directory('$directoryf/cmaps/$type/$name')
          .create(recursive: true);
      print(directory.path);
      setState(() {
        _filePath = directory.path;
      });
      print(_filePath);
    } else {
      print('no directort');
      new Directory('$directoryf/cmaps')
          .create()
          .then((Directory directory) async {
        var directoryn = await Directory('$directoryf/cmaps/$type/$name')
            .create(recursive: true);
        print(directoryn.path);
        setState(() {
          _filePath = directoryn.path;
        });
      });
    }
    Timer.periodic(new Duration(seconds: 2), (timer) async {
      if (_live) {
        if (!_close) {
          if (timer.tick == 1) {
            var latitude = _startLocation.latitude;
            var longitude = _startLocation.longitude;
            File('$_filePath/$_mapName.txt')
                .writeAsString('$latitude,$longitude|', mode: FileMode.append);
          }
          debugPrint(timer.tick.toString());
          setState(() {
            _duration = _duration + 2;
          });
          Position position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.best);
          var latitude = position.latitude;
          var longitude = position.longitude;

          setState(() {
            _temperaryLatlngs.add(LatLng(latitude, longitude));
          });
          if (_temperaryLatlngs.length == 5) {
            if (timer.tick > 2) {
              distanceInMeters = Geolocator.distanceBetween(
                  _latlongs[_latlongs.length - 1].latitude,
                  _latlongs[_latlongs.length - 1].longitude,
                  latitude,
                  longitude);
              setState(() {
                _distance = distanceInMeters + _distance;
              });
            } else {
              distanceInMeters = Geolocator.distanceBetween(
                  _startLocation.latitude,
                  _startLocation.longitude,
                  latitude,
                  longitude);
              setState(() {
                _distance = distanceInMeters + _distance;
                _distancec = distanceInMeters + _distancec;
              });
            }
            latitude = _temperaryLatlngs[0].latitude +
                _temperaryLatlngs[1].latitude +
                _temperaryLatlngs[2].latitude +
                _temperaryLatlngs[3].latitude +
                _temperaryLatlngs[4].latitude;
            longitude = _temperaryLatlngs[0].longitude +
                _temperaryLatlngs[1].longitude +
                _temperaryLatlngs[2].longitude +
                _temperaryLatlngs[3].longitude +
                _temperaryLatlngs[4].longitude;
            latitude = latitude / 5;
            longitude = longitude / 5;
            if (distanceInMeters > 3) {
              setState(() {
                _latlongs.add(LatLng(latitude, longitude));
              });

              File('$_filePath/$_mapName.txt').writeAsString(
                  '$latitude,$longitude|',
                  mode: FileMode.append);
              setState(() {
                _distancec = distanceInMeters + _distancec;
              });
            }
            setState(() {
              _temperaryLatlngs.clear();
            });
            print(_latlongs[_latlongs.length - 1]);
            print(_latlongs.length);
          } else {
            print(distanceInMeters);
          }
        } else {
          var added = await File('$_filePath/$_mapName.txt').readAsString();
          print(added);
        }
      }
    });
    // The created directory is returned as a Future.
  }

  Future<void> _showMyDialog() async {
    setState(() {
      _count = _count + 1;
    });
    var timeStamp = DateTime.now().millisecondsSinceEpoch;
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Map Name'),
          content: SingleChildScrollView(
              child: TextField(
            decoration: InputDecoration(hintText: "map name"),
            onChanged: (value) {
              setState(() {
                _mapFileName = '$value|$_user';
                _mapName = '$value|$timeStamp';
              });
            },
          )),
          actions: <Widget>[
            TextButton(
              child: const Text('Enter'),
              onPressed: () async {
                // Get a location using getDatabasesPath
                Database database = await openDatabase('vanishedTrails.db ',
                    version: 1, onCreate: (Database db, int version) async {
                  // When creating the db, create the table
                  await db.execute(
                      'CREATE TABLE user (id INTEGER PRIMARY KEY, email TEXT, displayname TEXT, photourl TEXT)');
                  await db.execute(
                      'CREATE TABLE maps (id INTEGER PRIMARY KEY, name TEXT, status BOOLEAN, completed BOOLEAN, boughtday DATE)');
                  await db.execute(
                      'CREATE TABLE cmaps (id INTEGER PRIMARY KEY, name TEXT, waterPoints TEXT, type TEXT, photoFiles TEXT, photoLocations TEXT, campsites TEXT, viewPoints TEXT,photos TEXT, mainMap TEXT, owner TEXT, uploaded BOOLEAN, createdDate TEXT,duration REAL, distance REAL)');
                });
                List<Map> list = await database.rawQuery('SELECT * FROM user');
                Map<String, Object> mapRead = list.first;
                setState(() {
                  _user = mapRead['email'];
                });
                print(_user);
                database.close();
                Position position = await Geolocator.getCurrentPosition(
                    desiredAccuracy: LocationAccuracy.bestForNavigation);
                var latitude = position.latitude;
                var longitude = position.longitude;
                setState(() {
                  _latlongs.add(LatLng(latitude, longitude));
                });

                setState(() {
                  _live = true;
                  _startLocation =
                      LatLng(position.latitude, position.longitude);
                });

                if (_mapName != null) {
                  start(_mapName);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showMyDialog2() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        var lengthw = _waterPoints.length.toString();
        var lengthc = _campSites.length.toString();
        var lengthv = _viewPoints.length.toString();

        return AlertDialog(
          title: const Text(''),
          content: SingleChildScrollView(
              child: Column(children: <Widget>[
            Text('Good job $_user',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            Text('Water Points : $lengthw'),
            Text('campsites : $lengthc'),
            Text('View Points : $lengthv'),
            Text(
                'We will upload your map after inspection. check mymaps for the progress.',
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 8))
          ])),
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

  Future<void> _showMyDialog3() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        var note;

        return AlertDialog(
          title: const Text(''),
          content: SingleChildScrollView(
              child: Column(children: <Widget>[
            Text('Add Note',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            TextField(
              decoration: InputDecoration(hintText: ""),
              onChanged: (value) {
                note = value;
              },
            )
          ])),
          actions: <Widget>[
            TextButton(
              child: const Text('Add'),
              onPressed: () async {
                Position position = await Geolocator.getCurrentPosition(
                    desiredAccuracy: LocationAccuracy.bestForNavigation);
                var latitude = position.latitude;
                var longitude = position.longitude;
                setState(() {
                  _noteLocations.add(LatLng(latitude, longitude));
                  _notes.add(note);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  MapController mapController = MapController();
  UserLocationOptions userLocationOptions;
  // ADD THIS
  List<Marker> markers = [];

  Widget map() {
    userLocationOptions = UserLocationOptions(
      context: context,
      mapController: mapController,
      markers: markers,
    );
    return Scaffold(
        body: Container(
            child: FlutterMap(
      options: MapOptions(
        center: LatLng(7.2, 80.6),
        zoom: 20.0,
        plugins: [
          UserLocationPlugin(),
        ],
      ),
      layers: [
        TileLayerOptions(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c']),
        PolylineLayerOptions(
          polylines: [
            Polyline(
                points: _latlongs, strokeWidth: 4.0, color: _polylineColor),
          ],
        ),
        MarkerLayerOptions(
          markers: markers,
        ),
        MarkerLayerOptions(
          markers: [
            Marker(
              width: 90.0,
              height: 90.0,
              point: _startLocation,
              builder: (ctx) =>
                  Container(child: Icon(Icons.location_on_outlined)),
            ),
          ],
        ),
        MarkerLayerOptions(markers: waterPoints()),
        MarkerLayerOptions(markers: viewPoints()),
        MarkerLayerOptions(markers: campsites()),
        MarkerLayerOptions(markers: photos()),
        MarkerLayerOptions(markers: notes()),
        MarkerLayerOptions(
            markers: (_removeItems) ? clearPoints() : <Marker>[]),
        userLocationOptions,
      ],
      mapController: mapController,
    )));
  }

  List<Marker> waterPoints() {
    List<Marker> points = <Marker>[];
    for (int i = 0; i < _waterPoints.length; i++) {
      points.add(Marker(
        width: 90.0,
        height: 90.0,
        point: _waterPoints[i],
        builder: (ctx) => Container(
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(color: Colors.grey[100], spreadRadius: 1)
            ]),
            child: Icon(Icons.water_damage_outlined)),
      ));
    }
    return (points);
  }

  List<Marker> clearPoints() {
    List<Marker> points = <Marker>[];
    for (int i = 0; i < _latlongs.length; i++) {
      points.add(Marker(
        width: 40.0,
        height: 40.0,
        point: _latlongs[i],
        builder: (ctx) => Container(
          child: IconButton(
              icon: Icon(Icons.remove_circle_outline),
              color: Colors.red,
              iconSize: 35.0,
              onPressed: () {
                _latlongs.removeAt(i);
              }),
        ),
      ));
    }
    return (points);
  }

  List<Marker> photos() {
    List<Marker> points = <Marker>[];
    for (int i = 0; i < _photoFiles.length; i++) {
      points.add(Marker(
        width: 60.0,
        height: 60.0,
        point: _photoLocations[i],
        builder: (ctx) => Container(
            child: TextButton(
                onPressed: () {
                  setState(() {
                    _viewImage = File(_photoFiles[i]);
                    _viewPhotos = true;
                  });
                },
                child: Container(
                    decoration: BoxDecoration(boxShadow: [
                      BoxShadow(color: Colors.grey[100], spreadRadius: 1)
                    ]),
                    child: Image.file(File(_photoFiles[i]))))),
      ));
    }
    return (points);
  }

  List<Marker> notes() {
    List<Marker> points = <Marker>[];
    for (int i = 0; i < _notes.length; i++) {
      points.add(Marker(
        width: 90.0,
        height: 90.0,
        point: _noteLocations[i],
        builder: (ctx) => Container(
            child: TextButton(
                onPressed: () {
                  setState(() {
                    _Note = _notes[i];
                    _viewNote = true;
                  });
                },
                child: Container(
                    decoration: BoxDecoration(boxShadow: [
                      BoxShadow(color: Colors.grey[100], spreadRadius: 1)
                    ]),
                    child: Icon(Icons.note_add)))),
      ));
    }
    return (points);
  }

  List<Marker> viewPoints() {
    List<Marker> points = <Marker>[];
    for (int i = 0; i < _viewPoints.length; i++) {
      points.add(Marker(
        width: 90.0,
        height: 90.0,
        point: _viewPoints[i],
        builder: (ctx) => Container(
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(color: Colors.grey[100], spreadRadius: 1)
            ]),
            child: Icon(Icons.map_outlined)),
      ));
    }
    return (points);
  }

  List<Marker> campsites() {
    List<Marker> points = <Marker>[];
    for (int i = 0; i < _campSites.length; i++) {
      points.add(Marker(
        width: 90.0,
        height: 90.0,
        point: _campSites[i],
        builder: (ctx) => Container(
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(color: Colors.grey[100], spreadRadius: 1)
            ]),
            child: Icon(Icons.house_siding_outlined)),
      ));
    }
    return (points);
  }

  Widget dudis() {
    var durationm = (_duration / 60).round();
    var distance = (_distancec).round();
    return Expanded(
        child: Align(
            alignment: Alignment.topLeft,
            child: Container(
                margin: EdgeInsets.only(top: 50, left: 10),
                width: MediaQuery.of(context).size.width / 2.3,
                height: 60,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Duration: $durationm (minutes)',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              decoration: TextDecoration.none)),
                      Text('Distance: $distance (meters)',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              decoration: TextDecoration.none)),
                      (_precentage == null)
                          ? Container()
                          : LinearPercentIndicator(
                              width: MediaQuery.of(context).size.width / 4,
                              lineHeight: 14.0,
                              percent: _precentage,
                              backgroundColor: Colors.grey,
                              progressColor: Colors.blue[800],
                            ),
                    ]))));
  }

  Widget buttonBox() {
    return Expanded(
      child: Align(
          alignment: Alignment.bottomLeft,
          child: Container(
              height: MediaQuery.of(context).size.height / 2.25,
              width: MediaQuery.of(context).size.width / 2.3,
              margin: EdgeInsets.only(left: 10),
              child: Column(children: <Widget>[
                (_live)
                    ? ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _live = false;
                          });
                          print(_latlongs);
                        },
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.pause),
                              Text('Pause', style: TextStyle(fontSize: 12))
                            ]))
                    : ElevatedButton(
                        onPressed: () {
                          if (_count < 1) {
                            _showMyDialog();
                          } else {
                            setState(() {
                              _live = true;
                            });
                          }
                        },
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.follow_the_signs_outlined),
                              Text('Start', style: TextStyle(fontSize: 12))
                            ])),
                ElevatedButton(
                    onPressed: (_live)
                        ? () {
                            setState(() {
                              _waterPoints.add(_latlongs.last);
                            });
                          }
                        : null,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.water_damage_outlined),
                          Text('Add Water Point',
                              style: TextStyle(fontSize: 12))
                        ])),
                ElevatedButton(
                    onPressed: (_live)
                        ? () {
                            setState(() {
                              _viewPoints.add(_latlongs.last);
                            });
                          }
                        : null,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.map_outlined),
                          Text('Add View Point', style: TextStyle(fontSize: 12))
                        ])),
                ElevatedButton(
                    onPressed: (_live)
                        ? () {
                            setState(() {
                              _campSites.add(_latlongs.last);
                            });
                            print(_campSites);
                          }
                        : null,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.house_siding_outlined),
                          Text('Add Campsite', style: TextStyle(fontSize: 12))
                        ])),
                ElevatedButton(
                    onPressed: (_live)
                        ? () {
                            setState(() {
                              _photos = true;
                            });
                          }
                        : null,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.add_photo_alternate_outlined),
                          Text('Add Picture', style: TextStyle(fontSize: 12))
                        ])),
                ElevatedButton(
                    onPressed: (_live)
                        ? () {
                            _showMyDialog3();
                          }
                        : null,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.note_add),
                          Text('Add Note', style: TextStyle(fontSize: 12))
                        ])),
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (_removeItems) {
                          _removeItems = false;
                        } else {
                          _removeItems = true;
                        }
                      });
                    },
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon((_removeItems)
                              ? Icons.done_all
                              : Icons.remove_circle_outline),
                          Text((_removeItems) ? 'Done' : 'Clear Points',
                              style: TextStyle(fontSize: 12))
                        ])),
                ElevatedButton(
                    onPressed: (_live)
                        ? () async {
                            var waterPoints = '';
                            var campsites = '';
                            var viewPoints = '';
                            var photoFiles = '';
                            var photoLocations = '';
                            var noteLocations = '';
                            var notes = '';
                            setState(() {
                              _close = true;
                              _live = false;
                            });
                            _waterPoints.forEach((element) {
                              var latitude = element.latitude.toString();
                              var longitude = element.longitude.toString();
                              waterPoints =
                                  '$waterPoints' + '$latitude,$longitude|';
                            });
                            _campSites.forEach((element) {
                              var latitude = element.latitude.toString();
                              var longitude = element.longitude.toString();
                              campsites =
                                  '$campsites' + '$latitude,$longitude|';
                            });
                            _viewPoints.forEach((element) {
                              var latitude = element.latitude.toString();
                              var longitude = element.longitude.toString();
                              viewPoints =
                                  '$viewPoints' + '$latitude,$longitude|';
                            });
                            _photoLocations.forEach((element) {
                              var latitude = element.latitude.toString();
                              var longitude = element.longitude.toString();
                              photoLocations =
                                  '$photoLocations' + '$latitude,$longitude|';
                            });

                            _photoFiles.forEach((element) {
                              photoFiles = '$photoFiles' + '$element|';
                            });
                            _noteLocations.forEach((element) {
                              var latitude = element.latitude.toString();
                              var longitude = element.longitude.toString();
                              noteLocations =
                                  '$noteLocations' + '$latitude,$longitude|';
                            });
                            _notes.forEach((element) {
                              notes = '$notes' + '$element|';
                            });
                            var i = 0;
                            _latlongs.forEach((element) {
                              i = i + 1;
                              var latitude = element.latitude.toString();
                              var longitude = element.longitude.toString();
                              print(longitude);

                              setState(() {
                                _precentage = i / _latlongs.length;
                              });
                              print(_precentage);
                            });

                            Database database = await openDatabase(
                                'vanishedTrails.db ',
                                version: 1,
                                onCreate: (Database db, int version) async {
                              // When creating the db, create the table
                              await db.execute(
                                  'CREATE TABLE user (id INTEGER PRIMARY KEY, email TEXT, displayname TEXT, photourl TEXT)');
                              await db.execute(
                                  'CREATE TABLE maps (id INTEGER PRIMARY KEY, name TEXT, status BOOLEAN, completed BOOLEAN, boughtday DATE)');
                              await db.execute(
                                  'CREATE TABLE cmaps (id INTEGER PRIMARY KEY, name TEXT, waterPoints TEXT, type TEXT, photoFiles TEXT, photoLocations TEXT, campsites TEXT, viewPoints TEXT,photos TEXT, mainMap TEXT, owner TEXT, uploaded BOOLEAN, createdDate TEXT,duration REAL, distance REAL,notes TEXT,noteLocations TEXT)');
                            });
                            await database.transaction((txn) async {
                              int id = await txn.rawInsert(
                                  'INSERT INTO cmaps (name, waterPoints, campsites, viewPoints, owner, uploaded, createdDate,photoFiles,type, photoLocations,distance,duration,notes,noteLocations) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
                                  [
                                    _mapName,
                                    waterPoints,
                                    campsites,
                                    viewPoints,
                                    _user,
                                    false,
                                    DateTime.now().year.toString() +
                                        '-' +
                                        DateTime.now().month.toString() +
                                        '-' +
                                        DateTime.now().day.toString(),
                                    photoFiles,
                                    widget.data,
                                    photoLocations,
                                    _distancec,
                                    _duration,
                                    notes,
                                    noteLocations
                                  ]);
                              print('inserted : $id');
                            });
                            var added = await File('$_filePath/$_mapName.txt')
                                .readAsString();
                            print(added);
                            print(_latlongs);
                            print(campsites);
                            _showMyDialog2().then((value) {
                              Navigator.of(context).pop();
                              print('popped');
                            });
                          }
                        : null,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.close),
                          Text('Finish', style: TextStyle(fontSize: 12))
                        ])),
              ]))),
    );
  }

  Future getImage(ImageSource source) async {
    final pickedFile = await picker.getImage(source: source);

    setState(() {
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      } else {
        print('No image selected.');
      }
    });
  }

  Widget photoContainer() {
    return AnimatedContainer(
        height: (_photos && _live) ? MediaQuery.of(context).size.height : 0,
        width: (_photos && _live) ? MediaQuery.of(context).size.width : 0,
        duration: Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn,
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.only(top: 10),
            child: Container(
                width: MediaQuery.of(context).size.width,
                child: ListView(children: <Widget>[
                  TextButton(
                      child: Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _photos = false;
                        });
                      }),
                  Container(
                      margin: EdgeInsets.only(top: 10),
                      width: MediaQuery.of(context).size.width,
                      height: 70,
                      child: Row(children: [
                        Expanded(
                            child: Container(
                          padding: EdgeInsets.all(10),
                          child: OutlinedButton(
                              child: Row(
                                children: [
                                  Icon(Icons.camera_alt_sharp),
                                  Text('Camera')
                                ],
                              ),
                              onPressed: () {
                                getImage(ImageSource.camera);
                              }),
                        )),
                        Expanded(
                            child: Container(
                          padding: EdgeInsets.all(10),
                          child: OutlinedButton(
                              child: Row(
                                children: [
                                  Icon(Icons.photo),
                                  Text('Photo Library')
                                ],
                              ),
                              onPressed: () {
                                getImage(ImageSource.gallery);
                              }),
                        ))
                      ])),
                  Container(
                      width: MediaQuery.of(context).size.width / 3,
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.only(top: 20),
                      child: _image == null
                          ? Text('Select an image',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                  decoration: TextDecoration.none))
                          : Image.file(_image)),
                  _image != null
                      ? TextButton(
                          child: Row(
                            children: [
                              Icon(Icons.navigate_next_outlined),
                              Text('Continue')
                            ],
                          ),
                          onPressed: () async {
                            Position position =
                                await Geolocator.getCurrentPosition(
                                    desiredAccuracy:
                                        LocationAccuracy.bestForNavigation);
                            var latitude = position.latitude;
                            var longitude = position.longitude;
                            setState(() {
                              _photos = false;
                              _photoFiles.add(_image.path);
                              _photoLocations.add(LatLng(latitude, longitude));
                            });
                          })
                      : Container()
                ]))));
  }

  Widget viewPhoto() {
    return AnimatedContainer(
        height: (_viewPhotos) ? MediaQuery.of(context).size.height : 0,
        width: (_viewPhotos) ? MediaQuery.of(context).size.width : 0,
        duration: Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn,
        child: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.only(top: 35),
            child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: ListView(children: <Widget>[
                  TextButton(
                      child: Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _viewPhotos = false;
                        });
                      }),
                  Container(
                      child: (_viewImage == null)
                          ? Text('image not available')
                          : Image.file(_viewImage)),
                ]))));
  }

  Widget viewNote() {
    return AnimatedContainer(
        height: (_viewNote) ? MediaQuery.of(context).size.height : 0,
        width: (_viewNote) ? MediaQuery.of(context).size.width : 0,
        duration: Duration(milliseconds: 500),
        curve: Curves.bounceInOut,
        child: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.only(top: 35),
            child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: ListView(children: <Widget>[
                  TextButton(
                      child: Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _viewNote = false;
                        });
                      }),
                  Container(
                      padding: EdgeInsets.all(10),
                      child: (_Note == '')
                          ? Text('note not available')
                          : Text(_Note,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black,
                                  decoration: TextDecoration.none))),
                ]))));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        map(),
        buttonBox(),
        dudis(),
        photoContainer(),
        viewPhoto(),
        viewNote()
      ],
    );
  }
}
