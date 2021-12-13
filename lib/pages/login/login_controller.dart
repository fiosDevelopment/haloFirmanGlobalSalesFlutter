import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:halo_firman_sales/core.dart';
import 'package:halo_firman_sales/managers/call_manager.dart';
import 'package:halo_firman_sales/managers/push_notifications_manager.dart';
import 'package:halo_firman_sales/utils/pref_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core.dart';

class LoginController extends GetxController {
  FirebaseApp firebaseApp;
  User userF;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseMessaging messaging;

  Future<void> initlizeFirebaseApp() async {
    firebaseApp = await Firebase.initializeApp();
  }

  read() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'uid';
    final value = prefs.get(key) ?? 0;
    if (value != 0) {
      Get.offNamed(Routes.HOME);
    }
  }

  void signInWithGoogle() async {
    try {
      await initlizeFirebaseApp();
      UserCredential userCredential;

      final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final GoogleAuthCredential googleAuthCredential =
          GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      userCredential = await _auth.signInWithCredential(googleAuthCredential);

      final user = userCredential.user;
      userF = user;
      AuthControllerss().save(userF.uid, "uid");
      print(userF.displayName);
      Get.offNamed(Routes.HOME);
    } catch (e) {
      print(e);
      Get.snackbar('Fallo', 'Failed to sign in with Google: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void loginWithEmail(String email, String password) async {
    try {
      Get.defaultDialog(
          title: "Sedang login",
          content: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(
                height: 10,
              ),
              Text("Mohon tunggu")
            ],
          ));
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      final user = userCredential.user;
      userF = user;
      loginToCC(userF.email, password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Get.back();
        Get.snackbar('Gagal login', 'Email tidak ditemukan',
            snackPosition: SnackPosition.BOTTOM);
      } else if (e.code == 'wrong-password') {
        Get.back();
        Get.snackbar('Gagal login', 'Password yang anda masukan salah',
            snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  void loginToCC(String email, String password) {
    getUserByEmail(email).then((cubeUser) {
      CubeUser user = CubeUser(
          login: cubeUser.login,
          fullName: cubeUser.fullName,
          password: password,
          id: cubeUser.id);

      if (CubeSessionManager.instance.isActiveSessionValid() &&
          CubeSessionManager.instance.activeSession.user != null) {
        if (CubeChatConnection.instance.isAuthenticated()) {
          AuthControllerss().save(userF.uid, "uid");
          Get.offNamed(Routes.HOME);
        } else {
          _loginToCubeChat(user);
        }
      } else {
        createSession(user).then((cubeSession) {
          _loginToCubeChat(user);
        }).catchError(_processLoginError);
      }
    }).catchError((error) {
      Get.snackbar('Gagal login', 'Silahkan coba lagi',
          snackPosition: SnackPosition.BOTTOM);
    });
  }

  void _loginToCubeChat(CubeUser user) {
    CubeChatConnection.instance.login(user).then((cubeUser) {
      SharedPrefs.instance.init().then((prefs) {
        prefs.saveNewUser(user);
        AuthControllerss().save(userF.uid, "uid");
        Get.offNamed(Routes.HOME);
      });
    }).catchError(_processLoginError);
  }

  void _processLoginError(exception) {
    log("Login error $exception");
  }

  void signOut() async {
    CallManager.instance.destroy();
    CubeChatConnection.instance.destroy();
    await PushNotificationsManager.instance.unsubscribe();
    await SharedPrefs.instance.init().then((value) => value.deleteUserData());
    googleSignIn.signOut();
    Get.offNamed('/login');
  }

  Future<void> updateUserToken(userID, token) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    await _firestore.collection('users').doc(userID).update({
      'FCMToken': token,
    });
  }

  Future takeFCMTokenWhenAppLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userToken = prefs.get('FCMToken');
    if (userToken == null) {
      messaging = FirebaseMessaging.instance;
      messaging.getToken().then((val) async {
        print('Tokensss: ' + val);

        prefs.setString('FCMToken', val);
        String userID = prefs.get('uid');
        if (userID != null) {
          updateUserToken(userID, val);
        }
      });
    }
  }
}
