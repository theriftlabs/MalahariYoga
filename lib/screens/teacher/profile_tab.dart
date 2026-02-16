import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../../nav/appRouter.dart';

class TeacherProfileTab extends StatelessWidget {
  const TeacherProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Teacher Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: ${userProfileStateInstance.name}", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text("Email: ${userProfileStateInstance.email}"),
            const SizedBox(height: 8),
            Text("Role: ${userProfileStateInstance.role}"),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                // appRouter redirect logic should handle the rest, but explicit can be safer
                 if (context.mounted) context.pushReplacement('/');
              },
              child: const Text("Sign Out"),
            )
          ],
        ),
      ),
    );
  }
}
