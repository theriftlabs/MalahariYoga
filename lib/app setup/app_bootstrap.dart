import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:malahari_yoga/app%20setup/splashScreen.dart';
import '../appEntry.dart';
import '../firebase_options.dart';
import '../nav/appRouter.dart';
import 'FirebaseFailedScreen.dart';

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _initFirebaseSafe();
  }

  Future<void> _initFirebaseSafe() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      // ✅ If default app already exists, ignore
      final msg = e.toString();
      if (msg.contains("duplicate-app") || msg.contains("already exists")) {
        return;
      }
      rethrow; // real error -> show failure screen
    }
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        // Loading screen
        if (snapshot.connectionState != ConnectionState.done) {
          return const SplashScreen();
        }

        // If Firebase failed -> show safe error UI, no white screen
        if (snapshot.hasError) {
          return FirebaseFailedScreen(
            error: snapshot.error.toString(),
            onRetry: () {
              setState(() {
                _initFuture = _initFirebaseSafe();
              });
            },
          );
        }

        // Firebase ok -> continue app
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: appRouter,
        );
      },
    );
  }
}
