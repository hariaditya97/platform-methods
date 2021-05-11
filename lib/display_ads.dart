import 'package:battery_level/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'models/native_ad.dart';

class DisplayAds extends StatefulWidget {
  @override
  _DisplayAdsState createState() => _DisplayAdsState();
}

class _DisplayAdsState extends State<DisplayAds> {
  static const audienceNetworkPlatform = const MethodChannel(
      "samples.flutter.dev/initialize_facebook_audience_network");
  static const nativeAdPlatform =
      const MethodChannel("samples.flutter.dev/native_ad");

  List<NativeAd> ads = [];
  List<NativeAd> savedAds = [];

  @override
  void initState() {
    audienceNetworkPlatform.invokeMethod("initializeFacebookAudienceNetwork");
    for (int i = 1; i <= 5; i++) {
      nativeAdPlatform.invokeMethod('getNativeAd');
    }
    nativeAdPlatform.setMethodCallHandler((call) => _handleAd(call));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff121212),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            color: Colors.white,
            size: 35,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: FractionalOffset.topLeft,
              end: FractionalOffset.bottomLeft,
              colors: <Color>[Color(0xff23403a), Color(0xff121212)],
              tileMode: TileMode.clamp,
            ),
          ),
        ),
        toolbarHeight: 70,
        elevation: 0,
        backgroundColor: Color(0xff121212),
        title: Text(
          'Display Ads',
          style:
              GoogleFonts.nunitoSans(fontWeight: FontWeight.w600, fontSize: 25),
        ),
        actions: [
          IconButton(
              icon: Icon(
                Icons.settings,
                color: Colors.white70,
              ),
              onPressed: null)
        ],
      ),
      body: ListView.builder(
        itemCount: ads.length,
        itemBuilder: (context, index) {
          return adWidget(index);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MyHomePage(
                      savedAds: savedAds,
                      title: 'Platform Methods',
                    )),
          );
        },
        backgroundColor: Color(0xff6200EE),
        child: Icon(
          Icons.arrow_back_ios,
          color: Colors.white,
        ),
      ),
    );
  }

  Container adWidget(int index) {
    return Container(
      margin: const EdgeInsets.only(right: 15.0, left: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (ads[index].iconURL != null)
                Container(
                  color: Color(0xff1b1b1b),
                  height: 40,
                  width: 40,
                  child: Image.network(ads[index].iconURL),
                ),
              SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${ads[index].title}',
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
              IconButton(
                  icon: Icon(
                    Icons.save,
                    color: Colors.amber,
                  ),
                  onPressed: () => savedAds.add(ads[index]))
            ],
          ),
          SizedBox(height: 10),
          if (ads[index].imageURL != null)
            Container(
              color: Color(0xff1b1b1b),
              height: 310,
              child: Image.network(ads[index].imageURL),
            ),
          SizedBox(height: 10),
          Text(
            '${ads[index].body}',
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

  Future<dynamic> _handleAd(MethodCall call) async {
    if (call.method == "message") {
      final adMap = call.arguments;
      print(adMap);
      setState(() {
        if (ads.contains(
                NativeAd(call.arguments['title'], call.arguments['body'])) ==
            false) {
          ads.add(NativeAd(call.arguments['title'], call.arguments['body'],
              imageURL: call.arguments['coverImage'],
              iconURL: call.arguments['iconImage']));
        }
      });
    }
  }
}
