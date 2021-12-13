import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthControllerss extends GetxController {
  void save(String result, String val) async {
    final prefs = await SharedPreferences.getInstance();
    final key = val;
    final value = result;
    print('token : ' + value);
    prefs.setString(key, value);
  }

  Future<String> readPreference(String val) async {
    final prefs = await SharedPreferences.getInstance();
    final key = val;
    String result = prefs.get(key) ?? 0;
    return result;
  }
}
