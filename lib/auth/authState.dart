import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthState extends ChangeNotifier{
  User? _user;
  late final StreamSubscription<User?> _sub;
  bool _initialized = false;

  AuthState(){
    _sub = FirebaseAuth.instance.authStateChanges().listen((User? user){
      _user = user;
      _initialized = true;
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isVerified => _user?.emailVerified ?? false;
  bool get isInitialized => _initialized;

  Future<void> reloadUser() async{
    await _user?.reload();
    _user = FirebaseAuth.instance.currentUser;
    notifyListeners();
  }

  @override
  void dispose(){
    _sub.cancel();
    super.dispose();
  }
}