import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'colors.dart'; // Import colors file
import 'package:rounds/UserLogin/Login.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isFirstTime = true;

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

    if (isFirstTime) {
      await prefs.setBool('isFirstTime', false);
    }

    setState(() {
      _isFirstTime = isFirstTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<PageViewModel> pages = [
      PageViewModel(
        title: "Welcome",
        body: "Welcome to the Rounds Medical App.",
        image: Center(
          child: SizedBox(
            width: 280, // Adjust the width
            height: 280, // Adjust the height
            child: Image.asset('images/Untitled-1.png'),
          ),
        ),
        decoration: const PageDecoration(
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          bodyTextStyle: TextStyle(color: Colors.white, fontSize: 18),
          pageColor: teal,
        ),
      ),
      PageViewModel(
        title: "Ease of Use",
        body: "The app is easy to use and helps you monitor your health.",
        image: Center(
          child: SizedBox(
            width: 280, // Adjust the width
            height: 280, // Adjust the height
            child: Image.asset('images/welocme2.png'),
          ),
        ),
        decoration: const PageDecoration(
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          bodyTextStyle: TextStyle(color: Colors.white, fontSize: 18),
          pageColor: teal,
        ),
      ),
      PageViewModel(
        title: "Continuous Monitoring",
        body: "Track your health data regularly and in real-time.",
        image: Center(
          child: SizedBox(
            width: 280, // Adjust the width
            height: 280, // Adjust the height
            child: Image.asset('images/welcom2.png'),
          ),
        ),
        decoration: const PageDecoration(
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          bodyTextStyle: TextStyle(color: Colors.white, fontSize: 18),
          pageColor: teal,
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: teal,
      body: Stack(
        children: [
          Positioned(
            top: -50,
            left: -50,
            child: CircleAvatar(
              radius: 100,
              backgroundColor: Colors.white.withOpacity(0.2),
            ),
          ),
          Positioned(
            top: 100,
            right: -100,
            child: CircleAvatar(
              radius: 150,
              backgroundColor: Colors.white.withOpacity(0.2),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: CircleAvatar(
              radius: 100,
              backgroundColor: Colors.white.withOpacity(0.2),
            ),
          ),
          Positioned(
            bottom: 100,
            right: -100,
            child: CircleAvatar(
              radius: 150,
              backgroundColor: Colors.white.withOpacity(0.2),
            ),
          ),
          IntroductionScreen(
            pages: pages,
            onDone: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => Login(), // Login page
                  transitionsBuilder: (_, animation, __, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(1.0, 0.0), // Slide in from the right
                        end: Offset.zero, // Slide to the center
                      ).animate(animation),
                      child: child,
                    );
                  },
                  transitionDuration: Duration(milliseconds: 650), // Slide transition duration
                ),
              );
            },
            onSkip: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => Login(), // Login page
                  transitionsBuilder: (_, animation, __, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(1.0, 0.0), // Slide in from the right
                        end: Offset.zero, // Slide to the center
                      ).animate(animation),
                      child: child,
                    );
                  },
                  transitionDuration: Duration(milliseconds: 650), // Slide transition duration
                ),
              );
            },

            showSkipButton: true,
            skip: const Text("Skip", style: TextStyle(color: Colors.white)),
            next: const Icon(Icons.arrow_forward, color: Colors.white),
            done: const Text("Done", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
            dotsDecorator: DotsDecorator(
              size: const Size.square(10.0),
              activeSize: const Size(22.0, 10.0),
              activeShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
              activeColor: Colors.deepOrangeAccent, // Change active dot color
            ),
            globalBackgroundColor: teal,
            animationDuration: 500, // Add animation duration
          ),
        ],
      ),
    );
  }
}
