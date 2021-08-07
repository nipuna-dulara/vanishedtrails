import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:ipstack/ipstack.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'dart:convert' as convert;
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class upload extends StatefulWidget {
  final String data;
  upload({Key key, @required this.data}) : super(key: key);

  @override
  _uploadState createState() => _uploadState();
}

class _uploadState extends State<upload> {
  LatLng _current;
  String _country;
  bool _addNew = false;
  bool _select = false;
  String _mapName;
  bool _sl = false;
  void current() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    var latitude = position.latitude;
    var longitude = position.longitude;
    setState(() {
      _current = LatLng(latitude, longitude);
    });
    Locale myLocale = Localizations.localeOf(context);
    print(myLocale.toString());
    print(DateTime.now().timeZoneName);
    findCountry();
  }

  void initState() {
    super.initState();
    current();
    setState(() {
      _mapName = widget.data;
    });
  }

  Widget map() {
    var newMainMapName;
    var latitude;
    var longitude;
    var country = _country;

    return Scaffold(
      body: Stack(
        children: [
          Container(
              child: (_current != null)
                  ? FlutterMap(
                      options: MapOptions(
                        center: _current,
                        zoom: 18.0,
                      ),
                      layers: [
                        TileLayerOptions(
                            urlTemplate:
                                "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                            subdomains: ['a', 'b', 'c']),
                        MarkerLayerOptions(
                          markers: [],
                        ),
                      ],
                    )
                  : Container(
                      child: Center(
                        child: Text('loading'),
                      ),
                    )),
          Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.white.withOpacity(0.85),
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.only(top: 20),
              child: Column(
                children: [
                  TextButton(
                    child: Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _select = false;
                      });
                    },
                  ),
                  (_addNew)
                      ? Container()
                      : Container(
                          alignment: Alignment.topLeft,
                          child: TextButton(
                            child: Text('New MainMap'),
                            onPressed: () {
                              setState(() {
                                _addNew = true;
                              });
                            },
                          )),
                  (_addNew)
                      ? Container(
                          child: Column(
                            children: [
                              Container(
                                  alignment: Alignment.topLeft,
                                  child: TextButton(
                                      child: Icon(Icons.arrow_back_ios),
                                      onPressed: () {
                                        setState(() {
                                          _addNew = false;
                                        });
                                      })),
                              Container(
                                margin: EdgeInsets.all(10),
                                child: TextFormField(
                                  onChanged: (value) {
                                    newMainMapName = value;
                                  },
                                  decoration: InputDecoration(
                                      labelText: 'Map Name',
                                      border: OutlineInputBorder(),
                                      hintText: 'Adam\'s peak'),
                                ),
                              ),
                              Container(
                                  margin: EdgeInsets.all(10),
                                  child: TextFormField(
                                    initialValue: _country,
                                    onChanged: (value) {
                                      country = value;
                                    },
                                    decoration: InputDecoration(
                                        labelText: 'Country Code',
                                        border: OutlineInputBorder(),
                                        hintText: 'SL'),
                                  )),
                              Text('location has to be in decimal type'),
                              Container(
                                  margin: EdgeInsets.all(10),
                                  child: TextFormField(
                                    onChanged: (value) {
                                      latitude = value;
                                    },
                                    decoration: InputDecoration(
                                        labelText: 'latitude',
                                        border: OutlineInputBorder(),
                                        hintText: 'latitude'),
                                  )),
                              Container(
                                  margin: EdgeInsets.all(10),
                                  child: TextFormField(
                                    onChanged: (value) {
                                      longitude = value;
                                    },
                                    decoration: InputDecoration(
                                        labelText: 'longitude',
                                        border: OutlineInputBorder(),
                                        hintText: 'longitude'),
                                  )),
                              ElevatedButton(
                                  onPressed: () async {
                                    setState(() {
                                      _addNew = false;
                                    });
                                    http.Response response = await http.post(
                                      Uri.parse(
                                          'http://127.0.0.1:3000/addNewMain'),
                                      headers: <String, String>{
                                        'Content-Type':
                                            'application/json; charset=UTF-8',
                                      },
                                      body: jsonEncode(<String, String>{
                                        'name': newMainMapName,
                                        'countryCode': country,
                                        'latitude': latitude,
                                        'longitude': longitude
                                      }),
                                    );

                                    if (response.statusCode == 200) {
                                      var jsonResponse =
                                          convert.jsonDecode(response.body)
                                              as Map<String, dynamic>;
                                      var name = jsonResponse['name'];
                                      print(
                                          'Number of books about http: $name.');
                                    } else {
                                      print(
                                          'Request failed with status: ${response.statusCode}.');
                                    }
                                  },
                                  child: Text('Request'))
                            ],
                          ),
                        )
                      : Container(),
                  (!_addNew)
                      ? Container(
                          margin: EdgeInsets.all(10),
                          child: TextFormField(
                            onChanged: (value) {},
                            decoration: InputDecoration(
                                labelText: 'Search for main map',
                                border: OutlineInputBorder(),
                                hintText: 'alagalla'),
                          ))
                      : Container(),
                ],
              ))
        ],
      ),
    );
  }

  Widget mmain() {
    return Scaffold(
      body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          margin: EdgeInsets.only(top: 30.0),
          padding: EdgeInsets.all(10),
          child: Column(children: [
            Container(
                alignment: Alignment.topLeft,
                child: Row(
                  children: [
                    TextButton(
                        child: Icon(Icons.arrow_back_ios),
                        onPressed: () {
                          Navigator.of(context).pop();
                        }),
                    Text('Please Complete this form before Uploading..',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.none)),
                  ],
                )),
            Container(
                margin: EdgeInsets.only(top: 30),
                child: TextFormField(
                  initialValue: _mapName,
                  onChanged: (text) {
                    setState(() {
                      _mapName = text;
                    });
                  },
                  decoration: InputDecoration(
                      labelText: 'Enter map name',
                      border: OutlineInputBorder(),
                      hintText: 'Kabaragala'),
                )),
            Container(
                margin: EdgeInsets.only(top: 30),
                child: TextFormField(
                  decoration: InputDecoration(
                      labelText: 'Enter Description',
                      border: OutlineInputBorder(),
                      hintText: 'minimum 20 words'),
                )),
            Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.only(top: 30),
                child: ElevatedButton(
                    child: Text('Select Main Map'),
                    onPressed: () {
                      setState(() {
                        _select = true;
                      });
                    })),
            Container(
                margin: EdgeInsets.only(top: 30),
                child: TextFormField(
                  onChanged: (text) {
                    setState(() {
                      _mapName = text;
                    });
                  },
                  decoration: InputDecoration(
                      labelText: 'Price',
                      border: OutlineInputBorder(),
                      hintText: (_sl) ? '300 lkr' : "2 \$"),
                )),
            Container(
                alignment: Alignment.topLeft,
                child: Row(
                  children: [
                    Text(
                        (_sl)
                            ? 'maximum amount is 600 lkr'
                            : 'maximum amount is 2 \$',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.none)),
                  ],
                )),
          ])),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [mmain(), (_select) ? map() : Container()],
    );
  }

  void findCountry() async {
    final result =
        await IpStack("09b1ead3190a2d33180630b1c4fc6f44").requester();
    setState(() {
      _country = result.countryCode;
    });
    print(_country);
  }
}
