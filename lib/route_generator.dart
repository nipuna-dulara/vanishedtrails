import 'package:flutter/material.dart';
import 'main.dart';
import 'add_page.dart';
import 'add_hike.dart';
import 'view_map.dart';

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
