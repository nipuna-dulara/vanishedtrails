import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class ViewedMap extends StatefulWidget {
  final String data;
  ViewedMap({Key key, @required this.data}) : super(key: key);

  @override
  _ViewedMapState createState() => _ViewedMapState();
}

class _ViewedMapState extends State<ViewedMap> {
  String _mapName;
  String _mapFileName;
  String _filePath;
  int _count = 0;
  String _type;
  bool _live = false;
  bool _close = false;
  LatLng _startLocation;
  LatLng _liveLocation;
  String _user;
  bool _photos = false;
  bool _viewPhotos = false;
  bool _removeItems = false;
  double _distance = 0;
  double _duration = 0;
  double _precentage;
  List<Map> _list = <Map>[];
  List<String> _waterPoints = <String>[];
  List<String> _viewPoints = <String>[];
  List<String> _campSites = <String>[];
  List<LatLng> _latlongs = <LatLng>[];
  List<String> _photoFiles = <String>[];
  List<String> _photoLocations = <String>[];
  File _image;
  File _viewImage;
  Color _polylineColor = Colors.black;

  MapController mapController = MapController();

  // ADD THIS
  List<Marker> markers = [];
  void Initialize() async {
    setState(() {
      _mapName = widget.data;
    });
    Timer.periodic(new Duration(seconds: 3), (timer) async {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      var latitude = position.latitude;
      var longitude = position.longitude;
      setState(() {
        _liveLocation = LatLng(latitude, longitude);
      });
    });
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
    List<Map> list = await database
        .rawQuery('SELECT * FROM cmaps WHERE name = ?', [_mapName]);
    setState(() {
      _list = list;
      _user = list[0]['owner'];
      _type = list[0]['type'];
    });
    switch (_type) {
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
    final directorym = await getApplicationDocumentsDirectory();
    final directoryf = directorym.path;
    final myDir = Directory('$directoryf/cmaps/$_type/$_mapName');
    setState(() {
      _filePath = myDir.path;
    });
    var content = await File('$_filePath/$_mapName.txt').readAsString();

    var locationStringList = content.split('|');

    for (int i = 0; i < locationStringList.length - 1; i++) {
      var splitted = locationStringList[i].split(',');
      setState(() {
        _latlongs
            .add(LatLng(double.parse(splitted[0]), double.parse(splitted[1])));
      });
    }
    content = '';
    locationStringList = [];
    setState(() {
      _startLocation = _latlongs[0];
      _waterPoints = _list[0]['waterPoints'].split('|');
      _viewPoints = _list[0]['viewPoints'].split('|');
      _campSites = _list[0]['campsites'].split('|');
      _photoFiles = _list[0]['photoFiles'].split('|');
      _photoLocations = _list[0]['photoLocations'].split('|');
      _duration = _list[0]['duration'];
      _distance = _list[0]['distance'];
    });
    print(_startLocation);
  }

  List<Marker> viewPoints() {
    List<Marker> points = <Marker>[];
    for (int i = 0; i < _viewPoints.length - 1; i++) {
      var stringvals = _viewPoints[i].split(',');
      points.add(Marker(
        width: 60.0,
        height: 60.0,
        point: LatLng(double.parse(stringvals[0]), double.parse(stringvals[1])),
        builder: (ctx) => Container(child: Icon(Icons.map_outlined)),
      ));
    }
    print(points);
    return (points);
  }

  List<Marker> waterPoints() {
    List<Marker> points = <Marker>[];
    for (int i = 0; i < _waterPoints.length - 1; i++) {
      var stringvals = _waterPoints[i].split(',');
      points.add(Marker(
        width: 60.0,
        height: 60.0,
        point: LatLng(double.parse(stringvals[0]), double.parse(stringvals[1])),
        builder: (ctx) => Container(child: Icon(Icons.water_damage_outlined)),
      ));
    }
    return (points);
  }

  List<Marker> campsites() {
    List<Marker> points = <Marker>[];
    for (int i = 0; i < _campSites.length - 1; i++) {
      var stringvals = _campSites[i].split(',');
      points.add(
        Marker(
            width: 60.0,
            height: 60.0,
            point: LatLng(
                double.parse(stringvals[0]), double.parse(stringvals[1])),
            builder: (ctx) =>
                Container(child: Icon(Icons.house_siding_outlined))),
      );
    }
    return (points);
  }

  List<Marker> photos() {
    List<Marker> points = <Marker>[];
    for (int i = 0; i < _photoFiles.length - 1; i++) {
      var photolocationstring = _photoLocations[i].split(",");
      points.add(Marker(
        width: 60.0,
        height: 60.0,
        point: LatLng(double.parse(photolocationstring[0]), double.parse(photolocationstring[1])),
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

  Widget viewPhoto() {
    return Container(
        height: (_viewPhotos) ? MediaQuery.of(context).size.height : 0,
        width: (_viewPhotos) ? MediaQuery.of(context).size.width : 0,
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

  Widget map() {
    return Scaffold(
      body: Container(
          child: (_startLocation != null)
              ? FlutterMap(
                  options: MapOptions(
                    center: _startLocation,
                    zoom: 18.0,
                  ),
                  layers: [
                    TileLayerOptions(
                        urlTemplate:
                            "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        subdomains: ['a', 'b', 'c']),
                    PolylineLayerOptions(
                      polylines: [
                        Polyline(
                            points: _latlongs,
                            strokeWidth: 4.0,
                            color: _polylineColor),
                      ],
                    ),
                    MarkerLayerOptions(
                      markers: markers,
                    ),
                    MarkerLayerOptions(
                      markers: [
                        Marker(
                          width: 60.0,
                          height: 60.0,
                          point: _startLocation,
                          builder: (ctx) => Container(
                              child: Icon(Icons.location_on_outlined)),
                        ),
                        Marker(
                          width: 80.0,
                          height: 80.0,
                          point: _liveLocation,
                          builder: (ctx) => Container(
                            child: IconButton(
                                icon: Icon(Icons.emoji_people_rounded),
                                color: Colors.blue[800],
                                iconSize: 35.0,
                                onPressed: () {}),
                          ),
                        ),
                      ],
                    ),
                    MarkerLayerOptions(markers: waterPoints()),
                    MarkerLayerOptions(markers: viewPoints()),
                    MarkerLayerOptions(markers: campsites()),
                    MarkerLayerOptions(markers: photos()),
                  ],
                )
              : Container(
                  child: Center(
                    child: Text('loading'),
                  ),
                )),
    );
  }

  Widget top() {
    var durationm = (_duration / 60).round();
    var distance = (_distance).round();
    return Expanded(
        child: Align(
            alignment: Alignment.topLeft,
            child: Container(
                margin: EdgeInsets.only(top: 50, left: 10),
                width: MediaQuery.of(context).size.width / 2,
                height: 60,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('$_type',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.red[800],
                              decoration: TextDecoration.none)),
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
                    ]))));
  }

  Widget bottom() {
    return Expanded(
        child: Align(
            alignment: Alignment.bottomLeft,
            child: Container(
                margin: EdgeInsets.only(top: 50, left: 10),
                width: MediaQuery.of(context).size.width / 2,
                height: 80,
                child: Column(children: [
                  Row(
                    children: [
                      Icon(Icons.water_damage_outlined),
                      Text('Water Points',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              decoration: TextDecoration.none))
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.house_siding_outlined),
                      Text('Campsites',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              decoration: TextDecoration.none))
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.map_outlined),
                      Text('View Points',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              decoration: TextDecoration.none))
                    ],
                  )
                ]))));
  }

  @override
  void initState() {
    // TODO: implement initState
    Initialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [map(), top(), bottom(), viewPhoto()]);
  }
}
