import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rounds/UserLogin/Login.dart';
import '../SplashScreen.dart'; // تحديث المسار إذا كان مختلفًا
import 'package:rounds/Screens/HomeScreen.dart';
import 'package:rounds/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // تهيئة Firebase

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Poppins',
        primaryColor: teal,
        appBarTheme: AppBarTheme(color: teal, centerTitle: true),
      ),
      routes: {
        '/home': (context) => HomeScreen(), // تعريف صفحة HomeScreen
        '/login': (context) => Login(), // تعريف صفحة HomeScreen

        // يمكنك تعريف مزيد من الصفحات هنا إذا لزم الأمر
      },
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), // استخدام صفحة البداية كصفحة رئيسية
    );
  }
}
