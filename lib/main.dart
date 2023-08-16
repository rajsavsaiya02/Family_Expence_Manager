import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fem/Database/Credentials/commanValueModel.dart';
import 'package:fem/Database/Credentials/familyGroupKeyModel.dart';
import 'package:fem/Utility/Colors.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fem/Utility/Values.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:easy_splash_screen/easy_splash_screen.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Database/Credentials/commanValue.dart';
import 'Database/FireStore_Database/User_Profile/user_datamodel.dart';
import 'Screens/Home/home.dart';
import 'Screens/OnBoarding/on_boarding.dart';
import 'Screens/UserSignIn/user_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';

late Box box;

final databaseRef = FirebaseDatabase.instance.ref();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive
    ..initFlutter(appDocumentDir.path)
    ..registerAdapter(commanValueModelAdapter())
    ..registerAdapter(familyGroupKeyModelAdapter());

  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true, cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);

  final prefs = await SharedPreferences.getInstance();
  var IsSignIn = prefs.getBool('IsSignIn');
  setUserState(IsSignIn);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // initialize the plugin
  void initializeNotifications() {
    var initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    FlutterNativeSplash.remove();
    commanValue().loadFromStorage();
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor: primary,
          visualDensity: VisualDensity.adaptivePlatformDensity),
      home: SplashPage(),
    );
  }
}

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final UserController controller = Get.put(UserController());
  final cValue = Get.put(commanValue());
  @override
  Widget build(BuildContext context) {
    bool user_state = getUserState();
    cValue.loadFromStorage();
    return EasySplashScreen(
      logo: Image.asset("assets/images/App_Logo.png"),
      title: Text(
        "Family Expense Manager",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      gradientBackground: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color.fromRGBO(129, 38, 198, 1),
            Color.fromRGBO(27, 196, 231, 1)
          ]),
      showLoader: true,
      loadingText: Text(
        "Loading...",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      loaderColor: Colors.white,
      navigator: user_state ? Home() : Welcome_Screen(),
      durationInSeconds: 2,
    );
  }
}

class Welcome_Screen extends StatefulWidget {
  const Welcome_Screen({Key? key}) : super(key: key);

  @override
  State<Welcome_Screen> createState() => _Welcome_ScreenState();
}

class _Welcome_ScreenState extends State<Welcome_Screen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      // Replace with your preferred background color
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.purple,
              Colors.blue,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 40,
                left: -45,
                child: Transform.rotate(
                  angle: -math.pi / 11.0,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.centerRight,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color.fromARGB(142, 125, 192, 253),
                            Color.fromARGB(158, 172, 86, 232),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(100)),
                  ),
                ),
              ),
              Positioned(
                top: 40,
                left: -45,
                child: Transform.rotate(
                  angle: -math.pi / 11.0,
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.centerRight,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color.fromARGB(45, 125, 192, 253),
                            Color.fromARGB(42, 172, 86, 232),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(100)),
                  ),
                ),
              ),
              Positioned(
                right: -50,
                top: -80,
                child: Transform.rotate(
                  angle: -math.pi / 11.0,
                  child: Container(
                    width: 120.0,
                    height: 120.0,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.topCenter,
                        colors: [
                          Color.fromARGB(58, 154, 246, 198),
                          Color.fromARGB(21, 159, 255, 201),
                        ],
                      ),
                      shape: BoxShape.rectangle,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -20,
                right: -20,
                child: Transform.rotate(
                  angle: -math.pi / 11.0,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.centerRight,
                          end: Alignment.topCenter,
                          colors: [
                            Color.fromARGB(158, 172, 86, 232),
                            Color.fromARGB(111, 159, 255, 201),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(100)),
                  ),
                ),
              ),
              Positioned(
                bottom: -20,
                right: -20,
                child: Transform.rotate(
                  angle: -math.pi / 11.0,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.centerRight,
                          end: Alignment.topCenter,
                          colors: [
                            Color.fromARGB(29, 172, 86, 232),
                            Color.fromARGB(21, 159, 255, 201),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(100)),
                  ),
                ),
              ),
              Positioned(
                bottom: 300,
                right: 50,
                child: Transform.rotate(
                  angle: -math.pi / 11.0,
                  child: Container(
                    width: 20,
                    height: 30,
                    decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.centerRight,
                          end: Alignment.topCenter,
                          colors: [
                            Color.fromARGB(142, 125, 192, 253),
                            Color.fromARGB(58, 159, 255, 201),
                          ],
                        ),
                        shape: BoxShape.circle),
                  ),
                ),
              ),
              Positioned(
                bottom: 200,
                right: 50,
                child: Transform.rotate(
                  angle: -math.pi / 11.0,
                  child: Container(
                    width: 200,
                    height: 300,
                    decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.centerRight,
                          end: Alignment.topCenter,
                          colors: [
                            Color.fromARGB(11, 125, 192, 253),
                            Color.fromARGB(32, 159, 255, 201),
                          ],
                        ),
                        shape: BoxShape.circle),
                  ),
                ),
              ),
              Positioned(
                bottom: 200,
                right: 40,
                child: Transform.rotate(
                  angle: -math.pi / 11.0,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.centerRight,
                          end: Alignment.topCenter,
                          colors: [
                            Color.fromARGB(11, 125, 192, 253),
                            Color.fromARGB(32, 159, 255, 201),
                          ],
                        ),
                        shape: BoxShape.circle),
                  ),
                ),
              ),
              Positioned(
                left: -10,
                bottom: -20,
                child: Transform.rotate(
                  angle: -math.pi / 11.0,
                  child: Container(
                    width: 90.0,
                    height: 90.0,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.topCenter,
                        colors: [
                          Color.fromARGB(142, 125, 192, 253),
                          Color.fromARGB(58, 159, 255, 201),
                        ],
                      ),
                      shape: BoxShape.rectangle,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: -50,
                bottom: -40,
                child: Transform.rotate(
                  angle: -math.pi / 11.0,
                  child: Container(
                    width: 120.0,
                    height: 90.0,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.topCenter,
                        colors: [
                          Color.fromARGB(58, 154, 246, 198),
                          Color.fromARGB(21, 159, 255, 201),
                        ],
                      ),
                      shape: BoxShape.rectangle,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: -50,
                bottom: -80,
                child: Transform.rotate(
                  angle: -math.pi / 11.0,
                  child: Container(
                    width: 120.0,
                    height: 120.0,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.topCenter,
                        colors: [
                          Color.fromARGB(58, 154, 246, 198),
                          Color.fromARGB(21, 159, 255, 201),
                        ],
                      ),
                      shape: BoxShape.rectangle,
                    ),
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'WELCOME',
                    style: GoogleFonts.robotoSlab(
                      fontSize: 50.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Text color
                    ),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Image.asset(
                    'assets/images/welcome_screen.png',
                  ),
                  Text(
                    'To',
                    style: TextStyle(
                      fontSize: 28.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.white, // Text c// olor
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    'Family Expense Manager',
                    style: TextStyle(
                      fontSize: 28.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.white, // Text c// olor
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text('Make it Simple, To Manage Finance',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.raleway(
                          fontSize: 18.0,
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                        )),
                  ),
                  SizedBox(height: 32.0),
                  ElevatedButton(
                    onPressed: () => {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UserSignIn())),
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 14, // Elevation to add shadow to the button
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(16), // Button border radius
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32.0, vertical: 18.0),
                      child: Text(
                        'Get Started',
                        style: TextStyle(
                          color: Colors.blue, // Button text color
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.0),
                  TextButton(
                    child: Text(
                      "Create an New Account",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          fontStyle: FontStyle.italic),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => OnBoarding()));
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
