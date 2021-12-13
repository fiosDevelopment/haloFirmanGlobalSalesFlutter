import 'dart:async';
import 'dart:io';

import 'package:device_id/device_id.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_voip_push_notification/flutter_voip_push_notification.dart';

import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'call_manager.dart';
import '../utils/consts.dart';
import '../utils/pref_utils.dart';
import '../utils/configs.dart' as config;

class PushNotificationsManager {
  static const TAG = "PushNotificationsManager";

  static final PushNotificationsManager _instance =
      PushNotificationsManager._internal();

  PushNotificationsManager._internal() {
    Firebase.initializeApp();
  }

  BuildContext applicationContext;

  static PushNotificationsManager get instance => _instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  FlutterVoipPushNotification _voipPush = FlutterVoipPushNotification();

  init() async {
    if (Platform.isAndroid) {
      _initFcm();
    } else if (Platform.isIOS) {
      _initIosVoIP();
    }

    FirebaseMessaging.onMessage.listen((remoteMessage) async {
      // processCallNotification(remoteMessage.data);
      if (remoteMessage.notification == null) {
        processCallNotification(remoteMessage.data);
      } else {
        print(remoteMessage.notification.body);
        _showNotification(
            remoteMessage.notification.title, remoteMessage.notification.body);
      }
    });

    FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);

    FirebaseMessaging.onMessageOpenedApp.listen((remoteMessage) {
      log('[onMessageOpenedApp] remoteMessage: $remoteMessage', TAG);
    });

    if (Platform.isIOS) {
      // set iOS Local notification.
      var initializationSettingsAndroid =
          AndroidInitializationSettings('ic_stat_name');
      var initializationSettingsIOS = IOSInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
        onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
      );
      final InitializationSettings initializationSettings =
          InitializationSettings(
              android: initializationSettingsAndroid,
              iOS: initializationSettingsIOS);
      await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
          onSelectNotification: _selectNotification);
    } else {
      // set Android Local notification.
      var initializationSettingsAndroid =
          AndroidInitializationSettings('ic_stat_name');
      var initializationSettingsIOS = IOSInitializationSettings(
          onDidReceiveLocalNotification: _onDidReceiveLocalNotification);
      final InitializationSettings initializationSettings =
          InitializationSettings(
              android: initializationSettingsAndroid,
              iOS: initializationSettingsIOS);
      await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
          onSelectNotification: _selectNotification);
    }
  }

  _initIosVoIP() async {
    await _voipPush.requestNotificationPermissions();
    _voipPush.configure(onMessage: onMessage, onResume: onResume);

    _voipPush.onTokenRefresh.listen((token) {
      log('[onTokenRefresh] VoIP token: $token', TAG);
      subscribe(token);
    });
  }

  _initFcm() async {
    FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

    await firebaseMessaging.requestPermission(
        alert: true, badge: true, sound: true);

    firebaseMessaging.getToken().then((token) {
      log('[getToken] FCM token: $token', TAG);
      subscribe(token);
    }).catchError((onError) {
      log('[getToken] onError: $onError', TAG);
    });

    firebaseMessaging.onTokenRefresh.listen((newToken) {
      log('[onTokenRefresh] FCM token: $newToken', TAG);
      subscribe(newToken);
    });
  }

  Future _onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {}

  Future _selectNotification(String payload) async {}

  Future<void> _showNotification(name, body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'your channel id', 'your channel name', 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin
        .show(0, name, body, platformChannelSpecifics, payload: 'item x');
  }

  subscribe(String token) async {
    log('[subscribe] token: $token', PushNotificationsManager.TAG);

    SharedPrefs sharedPrefs = await SharedPrefs.instance.init();
    if (sharedPrefs.getSubscriptionToken() == token) {
      log('[subscribe] skip subscription for same token',
          PushNotificationsManager.TAG);
      return;
    }

    CreateSubscriptionParameters parameters = CreateSubscriptionParameters();
    parameters.environment = CubeEnvironment.PRODUCTION;
    bool isProduction = bool.fromEnvironment('dart.vm.product');
    parameters.environment =
        isProduction ? CubeEnvironment.PRODUCTION : CubeEnvironment.DEVELOPMENT;

    if (Platform.isAndroid) {
      parameters.channel = NotificationsChannels.GCM;
      parameters.platform = CubePlatform.ANDROID;
      parameters.bundleIdentifier = "com.halo_firman_sales";
    } else if (Platform.isIOS) {
      parameters.channel = NotificationsChannels.APNS_VOIP;
      parameters.platform = CubePlatform.IOS;
      parameters.bundleIdentifier = "com.halo_firman_sales";
    }

    String deviceId = await DeviceId.getID;
    parameters.udid = deviceId;
    parameters.pushToken = token;

    createSubscription(parameters.getRequestParameters())
        .then((cubeSubscription) {
      log('[subscribe] subscription SUCCESS', PushNotificationsManager.TAG);
      sharedPrefs.saveSubscriptionToken(token);
      cubeSubscription.forEach((subscription) {
        if (subscription.device.clientIdentificationSequence == token) {
          sharedPrefs.saveSubscriptionId(subscription.id);
        }
      });
    }).catchError((error) {
      log('[subscribe] subscription ERROR: $error',
          PushNotificationsManager.TAG);
    });
  }

  Future<void> unsubscribe() {
    return SharedPrefs.instance.init().then((sharedPrefs) async {
      int subscriptionId = sharedPrefs.getSubscriptionId();
      if (subscriptionId != 0) {
        return deleteSubscription(subscriptionId).then((voidResult) {
          FirebaseMessaging.instance.deleteToken();
          sharedPrefs.saveSubscriptionId(0);
        });
      } else {
        return Future.value();
      }
    }).catchError((onError) {
      log('[unsubscribe] ERROR: $onError', PushNotificationsManager.TAG);
    });
  }
}

Future<dynamic> onMessage(bool isLocal, Map<String, dynamic> payload) {
  log("[onMessage] received on foreground payload: $payload, isLocal=$isLocal",
      PushNotificationsManager.TAG);

  processCallNotification(payload);

  return null;
}

Future<dynamic> onResume(bool isLocal, Map<String, dynamic> payload) {
  log("[onResume] received on background payload: $payload, isLocal=$isLocal",
      PushNotificationsManager.TAG);

  return null;
}

processCallNotification(Map<String, dynamic> data) async {
  log('[processCallNotification] message: $data', PushNotificationsManager.TAG);

  String signalType = data[PARAM_SIGNAL_TYPE];
  String sessionId = data[PARAM_SESSION_ID];
  Set<int> opponentsIds = (data[PARAM_CALL_OPPONENTS] as String)
      .split(',')
      .map((e) => int.parse(e))
      .toSet();

  if (signalType == SIGNAL_TYPE_START_CALL) {
    ConnectycubeFlutterCallKit.showCallNotification(
        sessionId: sessionId,
        callType: int.parse(data[PARAM_CALL_TYPE]),
        callerId: int.parse(data[PARAM_CALLER_ID]),
        callerName: data[PARAM_CALLER_NAME],
        opponentsIds: opponentsIds);
    FlutterRingtonePlayer.play(
      android: AndroidSounds.ringtone,
      ios: IosSounds.bell,
      looping: true,
      volume: 1.0,
      asAlarm: false,
    );
  } else if (signalType == SIGNAL_TYPE_END_CALL) {
    FlutterRingtonePlayer.stop();

    ConnectycubeFlutterCallKit.reportCallEnded(
        sessionId: data[PARAM_SESSION_ID]);
  } else if (signalType == SIGNAL_TYPE_REJECT_CALL) {
    if (opponentsIds.length == 1) {
      print('gess' + signalType);
      FlutterRingtonePlayer.stop();

      CallManager.instance.hungUp();
    }
  }
}

Future<void> onBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp();
  ConnectycubeFlutterCallKit.onCallRejectedWhenTerminated = (
    sessionId,
    callType,
    callerId,
    callerName,
    opponentsIds,
    userInfo,
  ) {
    return sendPushAboutRejectFromKilledState({
      PARAM_CALL_TYPE: callType,
      PARAM_SESSION_ID: sessionId,
      PARAM_CALLER_ID: callerId,
      PARAM_CALLER_NAME: callerName,
      PARAM_CALL_OPPONENTS: opponentsIds.join(','),
    }, callerId);
  };
  ConnectycubeFlutterCallKit.initMessagesHandler();

  processCallNotification(message.data);

  return Future.value();
}

Future<void> sendPushAboutRejectFromKilledState(
  Map<String, dynamic> parameters,
  int callerId,
) {
  CubeSettings.instance.applicationId = config.APP_ID;
  CubeSettings.instance.authorizationKey = config.AUTH_KEY;
  CubeSettings.instance.authorizationSecret = config.AUTH_SECRET;
  CubeSettings.instance.accountKey = config.ACCOUNT_ID;
  CubeSettings.instance.onSessionRestore = () {
    return SharedPrefs.instance.init().then((preferences) {
      return createSession(preferences.getUser());
    });
  };

  CreateEventParams params = CreateEventParams();
  params.parameters = parameters;
  params.parameters['message'] = "Reject call";
  params.parameters[PARAM_SIGNAL_TYPE] = SIGNAL_TYPE_REJECT_CALL;
  params.parameters[PARAM_IOS_VOIP] = 1;

  params.notificationType = NotificationType.PUSH;
  params.environment = CubeEnvironment.PRODUCTION;
  bool isProduction = bool.fromEnvironment('dart.vm.product');
  params.environment =
      isProduction ? CubeEnvironment.PRODUCTION : CubeEnvironment.DEVELOPMENT;
  params.usersIds = [callerId];

  return createEvent(params.getEventForRequest());
}
