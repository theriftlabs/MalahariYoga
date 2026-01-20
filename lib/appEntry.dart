import "package:flutter/material.dart";

class AppEntry extends StatelessWidget {
  const AppEntry({super.key});

  @override
  Widget build(BuildContext context) {
    // Later:
    // if (!loggedIn) return LoginScreen();
    // if (loggedIn && !enrolled) return EnrollScreen();
    // return StudentDashboard();

    return const Scaffold(
      body: Center(child: Text("App Loaded ✅")),
    );
  }
}
