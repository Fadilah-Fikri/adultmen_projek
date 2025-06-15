import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            SizedBox(height: 80),
            Text("Create an account", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            TextField(decoration: InputDecoration(hintText: "Full name")),
            SizedBox(height: 10),
            TextField(decoration: InputDecoration(hintText: "Email")),
            SizedBox(height: 10),
            TextField(obscureText: true, decoration: InputDecoration(hintText: "Password")),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
              onPressed: () {
                Navigator.pushNamed(context, '/home');
              },
              child: Text("Create account"),
            ),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Already have an account? Sign in"),
              ),
            )
          ],
        ),
      ),
    );
  }
}