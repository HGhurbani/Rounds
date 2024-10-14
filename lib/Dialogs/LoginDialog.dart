import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginDialog extends StatefulWidget {
  final Function(Map<String, String>) onSubmit;

  LoginDialog({this.onSubmit});

  @override
  _LoginDialogState createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isFilled = false;
  bool _isError = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Login'),
          SizedBox(height: 8.0),
          Text(
            'Please enter your email and password to continue.',
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextFormField(
            onChanged: (value) {
              setState(() {
                _isFilled = value.isNotEmpty && passwordController.text.isNotEmpty;
                _isError = false; // Reset error state when input changes
              });
            },
            controller: emailController,
            decoration: InputDecoration(
              hintText: 'Enter your email',
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(
                  color: Colors.teal,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(
                  color: Colors.teal,
                ),
              ),
            ),
          ),
          SizedBox(height: 10.0),
          TextFormField(
            onChanged: (value) {
              setState(() {
                _isFilled = emailController.text.isNotEmpty && value.isNotEmpty;
                _isError = false; // Reset error state when input changes
              });
            },
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'Enter your password',
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(
                  color: Colors.teal,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(
                  color: Colors.teal,
                ),
              ),
            ),
          ),
          if (_isError) // Show error message if there is an error
            Text(
              'Invalid email or password',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12.0,
              ),
            ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            // Navigate to login page
            Navigator.of(context).pushReplacementNamed('/login');
          },
          child: Text('Cancel'),
          style: TextButton.styleFrom(
            primary: Colors.deepOrangeAccent,
          ),
        ),
        TextButton(
          onPressed: _isFilled
              ? () async {
            // Authenticate user with Firebase
            try {
              UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                email: emailController.text,
                password: passwordController.text,
              );

              // If authentication succeeds, call onSubmit callback with credentials
              widget.onSubmit({
                'email': emailController.text,
                'password': passwordController.text,
              });

              // Close the dialog
              Navigator.of(context).pop();
            } catch (e) {
              // Show error message
              setState(() {
                _isError = true;
              });
            }
          }
              : null, // Disable the button if fields are not filled
          child: Text('Submit'),
          style: TextButton.styleFrom(
            primary: _isFilled ? Colors.teal : Colors.grey, // Change button color based on filled status
          ),
        ),
      ],
    );
  }
}
