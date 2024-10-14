import 'package:shared_preferences/shared_preferences.dart';

class DoctorLogIn{


  readLogIn() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'log';
    final value = prefs.getBool(key) ?? false;
    return value;
  }

  writeLogIn(bool status)async  {
    final prefs = await SharedPreferences.getInstance();
    final key = 'log';
    prefs.setBool(key, status);
  }


}