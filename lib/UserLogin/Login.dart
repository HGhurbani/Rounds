import 'package:flutter/material.dart';
import 'package:rounds/UserLogin/LoginScreen.dart';
import '../colors.dart';
import 'SignupScreen.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(height * 0.4),
          child: AppBar(
            elevation: 0,
            toolbarHeight: height * 0.4,
            centerTitle: true,
            title: Padding(
              padding: EdgeInsets.only(top: 20),
              child: Image.asset(
                "images/logo2.png",
                scale: 3,
              ),
            ),
            backgroundColor: Colors.white,
            bottom: TabBar(
              indicator: BoxDecoration(
                color: teal,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.all(20),
              labelColor: Colors.white,
              unselectedLabelColor: teal,
              tabs: [
                Tab(
                  child: Container(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.login),
                        SizedBox(width: 8),
                        Text(
                          "Login",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                Tab(
                  child: Container(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_add),
                        SizedBox(width: 8),
                        Text(
                          "Sign up",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Container(
          color: Colors.white,
          child: TabBarView(
            children: [
              LoginScreen(),
              SignupScreen(),
            ],
          ),
        ),
      ),
    );
  }
}
