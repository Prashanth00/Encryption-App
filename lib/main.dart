import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:imagepicker/encrypt.dart';
import 'package:imagepicker/decrypt.dart';
import 'package:imagepicker/form.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:after_layout/after_layout.dart';

void main() {
  runApp(
    MaterialApp(
      home: MyApp(),
      routes: {
        '/MyApp': (context) => MyApp(),
        '/Form': (context) => Formdetail()
      },
      debugShowCheckedModeBanner: false,
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with AfterLayoutMixin<MyApp> {
  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('hasfirstseen97') ?? false);

    if (_seen) {
      Navigator.of(context).pushReplacement(
          new MaterialPageRoute(builder: (context) => MainApp()));
    } else {
      await prefs.setBool('hasfirstseen97', true);
      Navigator.of(context).pushReplacement(
          new MaterialPageRoute(builder: (context) => Formdetail()));
    }
  }

  @override
  void afterFirstLayout(BuildContext context) => checkFirstSeen();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SpinKitFadingCircle(
          color: Colors.blue,
          size: 50,
        ),
      ),
    );
  }
}

class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedPage = 0;
  final _pageOption = [Encrypt(), Decrypt()];
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pageOption[_selectedPage],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.black,
        items: <Widget>[
          Icon(Icons.enhanced_encryption),
          Icon(Icons.repeat_rounded)
        ],
        onTap: (index) async {
          setState(
            () {
              _selectedPage = index;
            },
          );
        },
      ),
    );
  }
}
