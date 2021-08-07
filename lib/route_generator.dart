import 'package:flutter/material.dart';
import 'main.dart';
import 'add/add_page.dart';
import 'add/add_hike.dart';
import 'mymaps/view_map.dart';
import 'mymaps/upload.dart';

class routeGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => MyStatefulWidget());
      case '/addpage':
        return MaterialPageRoute(builder: (_) => AddPage(data: args));
      case '/addhike':
        return MaterialPageRoute(builder: (_) => AddHike(data: args));
      case '/viewMap':
        return MaterialPageRoute(builder: (_) => ViewedMap(data: args));
      case '/uploadmap':
        return MaterialPageRoute(builder: (_) => upload(data: args));
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
          appBar: AppBar(
            title: Text('Error'),
          ),
          body: Center(
            child: Text('error'),
          ));
    });
  }
}
