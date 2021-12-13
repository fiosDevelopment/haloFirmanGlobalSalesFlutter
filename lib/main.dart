import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:halo_firman_sales/core.dart';
import 'package:halo_firman_sales/managers/call_manager.dart';
import 'package:halo_firman_sales/managers/push_notifications_manager.dart';
import 'package:halo_firman_sales/utils/pref_utils.dart';
import 'utils/configs.dart' as config;
import 'package:connectycube_sdk/connectycube_sdk.dart';

Future<void> _messageHandler(RemoteMessage message) async {
  print('background message ${message.notification.body}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  try {
    await Firebase.initializeApp(
      name: 'SecondaryApp',
      options: FirebaseOptions(
        apiKey: "AIzaSyA6ufyCAYle0UvpbrQWF_G8P8GclRXNzSE",
        appId: "1:456841047514:web:aa3c4022066429964c64e3",
        databaseURL: "https://halofirman2-4a9c7.firebaseio.com",
        projectId: "halofirman2-4a9c7",
        messagingSenderId: "456841047514",
      ),
    );
  } on FirebaseException catch (e) {
    if (e.code == 'duplicate-app') {
      Firebase.app('SecondaryApp');
    } else {
      throw e;
    }
  } catch (e) {
    rethrow;
  }
  FirebaseMessaging.onBackgroundMessage(_messageHandler);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FirebaseMessaging messaging;

  @override
  void initState() {
    super.initState();
    PushNotificationsManager.instance.init();
    LoginController().takeFCMTokenWhenAppLaunch();
    print(initConnectycube());
  }

  @override
  Widget build(BuildContext context) {
    CallManager.instance.init(context);

    return GetMaterialApp(
      title: 'Halo Firman Sales',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          textTheme: GoogleFonts.muliTextTheme()),
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.cupertino,
      opaqueRoute: Get.isOpaqueRouteDefault,
      popGesture: Get.isPopGestureEnable,
      transitionDuration: Duration(milliseconds: 230),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    );
  }
}

initConnectycube() {
  init(
    config.APP_ID,
    config.AUTH_KEY,
    config.AUTH_SECRET,
    onSessionRestore: () {
      return SharedPrefs.instance.init().then((preferences) {
        return createSession(preferences.getUser());
      });
    },
  );
}
