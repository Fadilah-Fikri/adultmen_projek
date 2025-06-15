import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 80),
            Text("Welcome back", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text("Please enter your email and password to access your account."),
            SizedBox(height: 20),
            TextField(decoration: InputDecoration(hintText: "Email")),
            SizedBox(height: 10),
            TextField(obscureText: true, decoration: InputDecoration(hintText: "Password")),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: Text("Forgot password?"),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
              onPressed: () {
                Navigator.pushNamed(context, '/home');
              },
              child: Text("Login"),
            ),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: Text("Don't have an account? Sign up"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
