import 'package:shared_preferences/shared_preferences.dart';

class DoctorID {
  // استرجاع المعرف من SharedPreferences
  Future<String> readID() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'ID';
    final value = prefs.getString(key); // استخدام getString بدلاً من getInt

    return value ?? ''; // العودة بقيمة نصية مباشرة، أو العودة بقيمة فارغة إذا لم يتم العثور على المعرف
  }

  // حفظ المعرف في SharedPreferences
  Future<void> writeID(String status) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'ID';
    prefs.setString(key, status); // حفظ القيمة كنص
  }
}
