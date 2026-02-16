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
import 'package:malahari_yoga/screens/main_scaffold_screen.dart';
import 'package:malahari_yoga/screens/teacher/dashboard_tab.dart';
import 'package:malahari_yoga/screens/teacher/classes/classes_tab.dart';
import 'package:malahari_yoga/screens/teacher/profile_tab.dart';

import 'package:malahari_yoga/screens/student/home_tab.dart';
import 'package:malahari_yoga/screens/student/schedule_tab.dart';
import 'package:malahari_yoga/screens/student/content_tab.dart';
import 'package:malahari_yoga/screens/student/profile_tab.dart';

import 'package:malahari_yoga/screens/admin/dashboard_tab.dart';
import 'package:malahari_yoga/screens/admin/manage_tab.dart';
import 'package:malahari_yoga/screens/admin/content_tab.dart';
import 'package:malahari_yoga/screens/admin/profile_tab.dart';


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
    
    // Teacher Shell
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScaffoldScreen(
          navigationShell: navigationShell,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.class_outlined),
              selectedIcon: Icon(Icons.class_),
              label: 'Classes',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        );
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/teacherHome',
              builder: (context, state) => const TeacherDashboardTab(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/teacherClasses',
              builder: (context, state) => const TeacherClassesTab(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/teacherProfile',
              builder: (context, state) => const TeacherProfileTab(),
            ),
          ],
        ),
      ],
    ),

    // Student Shell
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScaffoldScreen(
          navigationShell: navigationShell,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
             NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month),
              label: 'Schedule',
            ),
             NavigationDestination(
              icon: Icon(Icons.video_library_outlined),
              selectedIcon: Icon(Icons.video_library),
              label: 'Content',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        );
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/studentHome',
              builder: (context, state) => const StudentHomeTab(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/studentSchedule',
              builder: (context, state) => const StudentScheduleTab(),
            ),
          ],
        ),
        StatefulShellBranch(
           routes: [
            GoRoute(
              path: '/studentContent',
              builder: (context, state) => const StudentContentTab(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/studentProfile',
              builder: (context, state) => const StudentProfileTab(),
            ),
          ],
        ),
      ],
    ),

    // Admin Shell
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScaffoldScreen(
           navigationShell: navigationShell,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
             NavigationDestination(
              icon: Icon(Icons.manage_accounts_outlined),
              selectedIcon: Icon(Icons.manage_accounts),
              label: 'Manage',
            ),
             NavigationDestination(
              icon: Icon(Icons.video_library_outlined),
              selectedIcon: Icon(Icons.video_library),
              label: 'Content',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        );
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/adminHome',
              builder: (context, state) => const AdminDashboardTab(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
             path: '/adminManage',
              builder: (context, state) => const AdminManageTab(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/adminContent',
              builder: (context, state) => const AdminContentTab(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/adminProfile',
              builder: (context, state) => const AdminProfileTab(),
            ),
          ],
        ),
      ],
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

    // Prevent infinite redirect loop by checking if we are already in the correct shell
    if (role == 'teacher') {
       if (loc.startsWith('/teacher')) return null; 
       return '/teacherHome';
    }

    if (role == 'student') {
      if (loc.startsWith('/student')) return null;
      return '/studentHome';
    } else if (role == 'admin') {
      if (loc.startsWith('/admin')) return null;
      return '/adminHome';
    }

    // fallback if role is missing or invalid
    return (loc == '/loading') ? null : '/loading';
  },

  refreshListenable: Listenable.merge([
    authStateInstance,
    userProfileStateInstance,
  ]),
);
