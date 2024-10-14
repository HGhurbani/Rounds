import 'package:firebase_auth/firebase_auth.dart';

class AuthStatus {
  // تحديد ما إذا كان المستخدم قد سجل دخوله
  bool isLoggedIn() {
    // تحقق من وجود مستخدم حالي مسجل دخوله باستخدام FirebaseAuth
    return FirebaseAuth.instance.currentUser != null;
  }
}
