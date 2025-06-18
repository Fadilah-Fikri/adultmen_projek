import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Theme.of(context).primaryColor),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Color(0xFFE4D8C7),
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          children: [
            SizedBox(height: 20),
            Center(
              child: Text(
                "Create Account",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 28),
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Start your new journey with us.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 40),
            TextField(decoration: InputDecoration(hintText: "Full name", prefixIcon: Icon(Icons.person_outline))),
            SizedBox(height: 16),
            TextField(decoration: InputDecoration(hintText: "Email", prefixIcon: Icon(Icons.email_outlined))),
            SizedBox(height: 16),
            TextField(obscureText: true, decoration: InputDecoration(hintText: "Password", prefixIcon: Icon(Icons.lock_outline))),
            SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
              onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false),
              child: Text("CREATE ACCOUNT"),
            ),
            SizedBox(height: 10),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Already have an account? Sign in"),
              ),
            )
          ],
        ),
      ),
    );
  }
}