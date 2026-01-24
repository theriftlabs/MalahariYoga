import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../nav/appRouter.dart';

class StudentHomeScreen extends StatefulWidget{
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen>{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("Student"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              if (!context.mounted) return;
              context.go('/');
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Email: ${userProfileStateInstance.email}"),
            const SizedBox(height: 8),
            Text("Name: ${userProfileStateInstance.name}"),
            const SizedBox(height: 8),
            Text("Role: ${userProfileStateInstance.role}"),
            const SizedBox(height: 8),
            Text("Phone: ${userProfileStateInstance.phone}"),
            const SizedBox(height: 8),
            Text("Profile Complete: ${userProfileStateInstance.isProfileComplete}"),
          ],
        ),
      ),
    );
  }
}