import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:malahari_yoga/app%20setup/splashScreen.dart';
import 'package:malahari_yoga/auth/ContinueWithScreen.dart';
import 'package:malahari_yoga/auth/authState.dart';
import 'package:malahari_yoga/auth/manualLoginScreen.dart';
import 'package:malahari_yoga/auth/manualSignupScreen.dart';
import 'package:malahari_yoga/auth/passwordResetScreen.dart';
import 'package:malahari_yoga/auth/profileSetupScreen.dart';
import 'package:malahari_yoga/auth/verifyScreen.dart';
import 'package:malahari_yoga/nav/userProfileState.dart';
import 'package:malahari_yoga/screens/adminHomeScreen.dart';
import 'package:malahari_yoga/screens/studentHomeScreen.dart';
import 'package:malahari_yoga/screens/teacherHomeScreen.dart';

final AuthState authStateInstance = AuthState();
final UserProfileState userProfileStateInstance = UserProfileState();

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const ContinueWithScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const ManualLoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const ManualSignupScreen(),
    ),
    GoRoute(
      path: '/profileSetup',
      builder: (context, state) => const ProfileSetupScreen(),
    ),
    GoRoute(
      path: '/verify',
      builder: (context, state) => const VerifyScreen(),
    ),
    GoRoute(
      path: '/loading',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/studentHome',
      builder: (context, state) => const StudentHomeScreen(),
    ),
    GoRoute(
      path: '/teacherHome',
      builder: (context, state) => const TeacherHomeScreen(),
    ),
    GoRoute(
      path: '/adminHome',
      builder: (context, state) => const AdminHomeScreen(),
    ),
    GoRoute(
      path: '/resetPassword',
      builder: (context, state) => const PasswordResetScreen(),
    )
  ],

  redirect: (context, state) {
    final loc = state.matchedLocation;

    // 0) Wait for FirebaseAuth to initialize
    if (!authStateInstance.isInitialized) {
      return (loc == '/loading') ? null : '/loading';
    }

    // 1) Not logged in -> only allow auth screens
    if (!authStateInstance.isLoggedIn) {
      const allowed = {'/', '/login', '/signup', '/resetPassword'};
      return allowed.contains(loc) ? null : '/';
    }

    // 2) Logged in but NOT verified -> only allow verify screen
    if (!authStateInstance.isVerified) {
      return (loc == '/verify') ? null : '/verify';
    }

    // 3) Logged in + verified -> attach Firestore profile listener
    userProfileStateInstance.attachUser(authStateInstance.user);

    // Wait until Firestore profile doc is loaded at least once
    if (!userProfileStateInstance.isInitialized) {
      return (loc == '/loading') ? null : '/loading';
    }

    // 4) Profile not complete -> go to profile setup
    if (!userProfileStateInstance.isProfileComplete) {
      return (loc == '/profileSetup') ? null : '/profileSetup';
    }

    // 5) Profile complete -> go based on role
    final role = userProfileStateInstance.role.toLowerCase();

    if (role == 'student') {
      return (loc == '/studentHome') ? null : '/studentHome';
    } else if (role == 'teacher') {
      return (loc == '/teacherHome') ? null : '/teacherHome';
    } else if (role == 'admin') {
      return (loc == '/adminHome') ? null : '/adminHome';
    }

    // fallback if role is missing or invalid
    return (loc == '/loading') ? null : '/loading';
  },

  refreshListenable: Listenable.merge([
    authStateInstance,
    userProfileStateInstance,
  ]),
);
