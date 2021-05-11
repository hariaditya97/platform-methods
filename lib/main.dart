import 'dart:async';

import 'package:battery_level/display_ads.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'models/native_ad.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Platform Methods Demo',
      theme: ThemeData.dark(),
      home: MyHomePage(title: 'Platform Methods'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.savedAds}) : super(key: key);

  final String title;
  List<NativeAd> savedAds;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const batteryPlatform =
      const MethodChannel('samples.flutter.dev/battery');
  static const messagePlatform =
      const MethodChannel('samples.flutter.dev/message');

  String _batteryLevel = '';
  String _platformMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff121212),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: FractionalOffset.topLeft,
              end: FractionalOffset.bottomLeft,
              colors: <Color>[Color(0xff6200ee), Color(0xff121212)],
              tileMode: TileMode.clamp,
            ),
          ),
        ),
        toolbarHeight: 70,
        elevation: 0,
        backgroundColor: Color(0xff121212),
        title: Text(
          widget.title,
          style:
              GoogleFonts.nunitoSans(fontWeight: FontWeight.w600, fontSize: 25),
        ),
        actions: [
          IconButton(
              icon: Icon(
                Icons.settings,
                color: Colors.white70,
              ),
              onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DisplayAds()),
                  ))
        ],
      ),
      body: Center(
        child: ListView(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                SizedBox(height: 10),
                ListTile(
                  title: Text(
                    'Get Battery Level',
                    style: GoogleFonts.montserrat(
                        fontSize: 18, color: Colors.white),
                  ),
                  trailing: Text(
                    _batteryLevel,
                    style: GoogleFonts.montserrat(fontSize: 15),
                  ),
                  onTap: _getBatteryLevel,
                ),
                Container(
                    child: Divider(
                      thickness: 5,
                    ),
                    margin: EdgeInsets.symmetric(vertical: 3, horizontal: 13)),
                SizedBox(height: 10),
                ListTile(
                  title: Text(
                    'Say Hi! to Native Platform',
                    style: GoogleFonts.montserrat(
                        fontSize: 18, color: Colors.white),
                  ),
                  trailing: Text(
                    _platformMessage,
                    style: GoogleFonts.montserrat(fontSize: 10),
                  ),
                  onTap: _getPlatformMessage,
                ),
                Container(
                    child: Divider(
                      thickness: 5,
                    ),
                    margin: EdgeInsets.symmetric(vertical: 3, horizontal: 13)),
                SizedBox(height: 20),
                Text(
                  'Saved Advertisements',
                  style: GoogleFonts.nunitoSans(
                      fontSize: 30,
                      color: Colors.white,
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 40),
                if (widget.savedAds != null)
                  Container(
                    height: 600,
                    child: ListView.builder(
                      itemCount: widget.savedAds.length,
                      itemBuilder: (context, index) {
                        return adWidget(index);
                      },
                    ),
                  )
              ],
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print(widget.savedAds);
        },
        backgroundColor: Color(0xff6200EE),
        child: Icon(
          Icons.arrow_forward_ios,
          color: Colors.white,
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<void> _getBatteryLevel() async {
    String batteryLevel;
    try {
      final int result = await batteryPlatform.invokeMethod('getBatteryLevel');
      batteryLevel = '$result%';
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
    }

    setState(() {
      _batteryLevel = batteryLevel;
    });
  }

  Future<void> _getPlatformMessage() async {
    try {
      final message = await messagePlatform.invokeMethod('getPlatformMessage');
      print(message);
      setState(() {
        _platformMessage = message['ok'];
      });
    } on PlatformException catch (e) {
      print("Error while communicating with platform!");
    }
  }

  Container adWidget(int index) {
    return Container(
      margin: const EdgeInsets.only(right: 15.0, left: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (widget.savedAds[index].iconURL != null)
                Container(
                  color: Color(0xff1b1b1b),
                  height: 40,
                  width: 40,
                  child: Image.network(widget.savedAds[index].iconURL),
                ),
              SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.savedAds[index].title}',
                    style: GoogleFonts.montserrat(fontSize: 16),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Sponsored',
                    style: GoogleFonts.montserrat(
                        fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
              SizedBox(width: 120),
            ],
          ),
          SizedBox(height: 10),
          if (widget.savedAds[index].imageURL != null)
            Container(
              color: Color(0xff1b1b1b),
              height: 310,
              child: Image.network(widget.savedAds[index].imageURL),
            ),
          SizedBox(height: 10),
          Text(
            '${widget.savedAds[index].body}',
            style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white),
          ),
          Container(
              child: Divider(
                thickness: 5,
              ),
              margin: EdgeInsets.symmetric(vertical: 15)),
        ],
      ),
    );
  }
}

// Get battery level.
