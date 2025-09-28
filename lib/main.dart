import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:suggest/firebase_options.dart';
import 'package:suggest/model/user_model.dart';
import 'package:suggest/page/admin/tab/main_admin.dart';
import 'package:suggest/page/first_page.dart';
import 'package:suggest/page/user/tab/main_user.dart';
import 'package:suggest/provider/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:math' show cos, sqrt, asin;

// const AndroidNotificationChannel channel = AndroidNotificationChannel(
//     'high_importance_channel', 'High Importance Notifications',
//     importance: Importance.high, playSound: true);

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background notifications here.
  print("Handling a background message: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(MyApp());
  configLoading();
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.green
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = false
    ..dismissOnTap = true;
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: Consumer<ThemeProvider>(
            builder: (context, ThemeProvider themeNotifier, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            //locale: languageProviderRef.appLocale,
            title: 'แอปแนะนำสถานที่ออกกำลังกาย',
            // theme: themeNotifier.isDark
            //     ? ThemeData.dark()
            //     : ThemeData.light(),
            theme: ThemeData(
              primarySwatch: Colors.green,
              // fontFamily: 'Kanit',
              scaffoldBackgroundColor: const Color(0xFFf6f5ee),
            ),

            home: const SplashScreen(), builder: EasyLoading.init(),
          );
        }));
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkData();
  }

  void checkData() async {
    final prefs = await SharedPreferences.getInstance();
    var check = prefs.getBool('check') ?? false;
    var user_id = prefs.getString('user_id') ?? '';
    var email = prefs.getString('email') ?? '';
    var name = prefs.getString('name') ?? '';
    var password = prefs.getString('password') ?? '';
    var tel = prefs.getString('tel') ?? '';
    var type = prefs.getString('type') ?? '';
    var photo = prefs.getString('photo') ?? '';
    var social = prefs.getString('social') ?? '';

    final my_account = UserModel(
        user_id: user_id,
        email: email,
        name: name,
        password: password,
        tel: tel,
        token: '',
        type: type,
        social: social,
        photo: photo);
    if (check) {
      if (type == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  MainAdmin(my_account: my_account, from: 'login')),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => MainUser(
                    my_account: my_account,
                    from: 'login',
                  )),
        );
      }
    } else {
      Timer(const Duration(seconds: 3), () {
        // นับเวลา 3 วิ
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => FirstPage(),
            ),
            (route) => false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // หน้า UI
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // แสดงรูป
            Image.asset(
              'assets/logo.png',
              height: 200,
            ),
          ],
        ),
      ),
    );
  }
}

enum ThemeMode {
  system,
  light,
  dark,
}

class TestPage extends StatefulWidget {
  @override
  _TestPage createState() => _TestPage();
}

class _TestPage extends State<TestPage> {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeProvider>(context, listen: false);
    //final isThai = Provider.of<UserProvider>(context, listen: false);

    return Scaffold(
        appBar: AppBar(
          // title: Text(isThai.isThai.toString()),
          actions: [
            IconButton(
                icon: Icon(themeNotifier.isDark
                    ? Icons.nightlight_round
                    : Icons.wb_sunny),
                onPressed: () {
                  themeNotifier.isDark
                      ? themeNotifier.isDark = false
                      : themeNotifier.isDark = true;
                })
          ],
        ),
        body: Column(
          children: [
            // TextButton(
            //   onPressed: () =>
            //       isThai.isThai ? isThai.isThai = false : isThai.isThai = true,
            //   child: isThai.isThai ? Text('Thai') : Text('EN'),
            // ),
            // Text(isThai.username!),
          ],
        ));
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;
  Location currentLocation = Location();
  Set<Marker> _markers = {};

  void getLocation() async {
    var location = await currentLocation.getLocation();
    currentLocation.onLocationChanged.listen((LocationData loc) {
      _controller
          ?.animateCamera(CameraUpdate.newCameraPosition(new CameraPosition(
        target: LatLng(loc.latitude ?? 0.0, loc.longitude ?? 0.0),
        zoom: 12.0,
      )));
      print(loc.latitude);
      print(loc.longitude);
      setState(() {
        _markers.add(Marker(
            markerId: MarkerId('Home'),
            position: LatLng(loc.latitude ?? 0.0, loc.longitude ?? 0.0)));
      });
    });
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      getLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Map"),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: GoogleMap(
          zoomControlsEnabled: false,
          initialCameraPosition: CameraPosition(
            target: LatLng(48.8561, 2.2930),
            zoom: 12.0,
          ),
          onMapCreated: (GoogleMapController controller) {
            _controller = controller;
          },
          markers: _markers,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.location_searching,
          color: Colors.white,
        ),
        onPressed: () {
          getLocation();
        },
      ),
    );
  }
}

class Palette {
  static const MaterialColor kToDark = MaterialColor(
    _greenPrimaryValue,
    <int, Color>{
      50: const Color(0xff006d38), //10%
      100: const Color(0xff006d38), //20%
      200: const Color(0xff006d38), //30%
      300: const Color(0xff006d38), //40%
      400: const Color(0xff006d38), //50%
      500: const Color(_greenPrimaryValue), //60%
      600: const Color(0xff006d38), //70%
      700: const Color(0xff006d38), //80%
      800: const Color(0xff006d38), //90%
      900: const Color(0xff006d38), //100%
    },
  );
  static const int _greenPrimaryValue = 0xff006d38;
}
