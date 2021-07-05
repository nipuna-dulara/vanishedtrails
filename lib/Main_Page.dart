import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:latlong/latlong.dart';
// search for

//map
class SearchMap extends StatefulWidget {
  @override
  _SearchMapState createState() => _SearchMapState();
}

class _SearchMapState extends State<SearchMap> {
  String _marker = 'hike';

//search box
  Widget searchbox() {
    return Container(
        margin: EdgeInsets.only(top: 50, left: 15, right: 15),
        padding: EdgeInsets.only(left: 17),
        height: 45,
        width: MediaQuery.of(context).size.width * 0.8,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.grey[50],
            boxShadow: [BoxShadow(color: Colors.grey[300], spreadRadius: 1)]),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 10,
                child: TextFormField(
                  decoration: InputDecoration(labelText: 'Search'),
                ),
              ),
              Expanded(
                  flex: 2,
                  child: Container(
                      margin: EdgeInsets.only(top: 0),
                      child: IconButton(
                          icon: Icon(Icons.search_outlined),
                          iconSize: 35.0,
                          onPressed: () {
                            print('search button pressed ');
                          })))
            ]));
  }

//mapview
  Widget mapView(LatLng location) {
    return FlutterMap(
      options: MapOptions(
        center: location,
        zoom: 13.0,
      ),
      layers: [
        TileLayerOptions(
            urlTemplate:
                "https://api.mapbox.com/styles/v1/flangodev/ckphrmwfi328a17vx14jn061b/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiZmxhbmdvZGV2IiwiYSI6ImNrcGhxc2llazB2bDUycHF4ZXk1cWYyenIifQ.hLbClfM6jFfn8vXjaumbkw",
            additionalOptions: {
              'accessToken':
                  'pk.eyJ1IjoiZmxhbmdvZGV2IiwiYSI6ImNrcGhxc2llazB2bDUycHF4ZXk1cWYyenIifQ.hLbClfM6jFfn8vXjaumbkw',
              'id': 'mapbox.mapbox-streets-v8'
            }),
        MarkerLayerOptions(
          markers: [
            Marker(
              width: 70.0,
              height: 70.0,
              point: location,
              builder: (ctx) => Container(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                      icon: Icon(Icons.location_on),
                      color: Colors.red,
                      iconSize: 35.0,
                      onPressed: () {
                        print('marker clicked');
                      }),
                  Text(_marker,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: Colors.black))
                ],
              )),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Stack(children: <Widget>[
      Container(child: mapView(LatLng(7.2, 80.6))),
      searchbox()
    ]));
  }
}
