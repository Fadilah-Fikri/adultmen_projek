import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            children: [
              SizedBox(height: 80),
              Icon(Icons.auto_awesome, color: Theme.of(context).primaryColor, size: 60),
              SizedBox(height: 20),
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: Duration(milliseconds: 500),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Padding(
                      padding: EdgeInsets.only(top: value * 20 - 20),
                      child: child,
                    ),
                  );
                },
                child: Center(
                  child: Text(
                    "Welcome Back",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 28),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Login to continue your fragrant journey.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: 40),
              TextField(decoration: InputDecoration(hintText: "Email", prefixIcon: Icon(Icons.email_outlined))),
              SizedBox(height: 16),
              TextField(obscureText: true, decoration: InputDecoration(hintText: "Password", prefixIcon: Icon(Icons.lock_outline))),
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
                onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false),
                child: Text("LOGIN"),
              ),
              SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: Text("Don't have an account? Sign up"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}