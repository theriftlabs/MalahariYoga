import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileState extends ChangeNotifier {
  User? _user;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _profileSub;

  bool _initialized = false;
  bool get isInitialized => _initialized;

  bool isProfileComplete = false;
  String email = "";
  String name = "";
  String role = "";
  String phone = "";

  void attachUser(User? user) {
    // same user -> do nothing
    if (_user?.uid == user?.uid) return;

    _user = user;

    // cancel old listener
    _profileSub?.cancel();
    _profileSub = null;

    // reset state immediately (important when switching accounts)
    _initialized = false;
    isProfileComplete = false;
    email = _user?.email ?? "";
    name = "";
    role = "";
    phone = "";
    notifyListeners();

    // logged out
    if (_user == null) {
      _initialized = true;
      notifyListeners();
      return;
    }

    // subscribe to profile doc
    _profileSub = FirebaseFirestore.instance
        .collection("users")
        .doc(_user!.uid)
        .snapshots()
        .listen((doc) {
      _initialized = true;

      if (!doc.exists) {
        // user doc not created yet
        isProfileComplete = false;
        role = "";
        name = "";
        phone = "";
        email = _user?.email ?? "";
        notifyListeners();
        return;
      }

      final data = doc.data();

      email = data?["email"] ?? _user?.email ?? "";
      name = data?["name"] ?? "";
      role = data?["role"] ?? "";
      phone = data?["number"] ?? "";
      isProfileComplete = data?["profileComplete"] ?? false;

      notifyListeners();
    }, onError: (_) {
      // If Firestore errors out, don't keep app stuck forever
      _initialized = true;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _profileSub?.cancel();
    super.dispose();
  }
}
