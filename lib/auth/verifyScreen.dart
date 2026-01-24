import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:malahari_yoga/nav/appRouter.dart';
import 'package:url_launcher/url_launcher.dart';

class VerifyScreen extends StatelessWidget {
  const VerifyScreen({super.key});

  Future<bool> openEmailApp() async {
    final Uri uri = Uri(scheme: 'mailto', path: '');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("Email Verification"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Verify your email",
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),

                            Text(
                              "We sent you a verification link. Open your email and tap the link to continue.",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[700],
                              ),
                            ),

                            const SizedBox(height: 16),

                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.blue.withOpacity(0.15),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.info_outline, size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      "Didn’t get it? Check Spam/Promotions too.",
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            SizedBox(
                              width: double.infinity,
                              height: 46,
                              child: ElevatedButton.icon(
                                onPressed: () async{
                                  final opened = await openEmailApp();

                                  if(!context.mounted) return;

                                  if(!opened){
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("No email app found. Please open your email manually.")));
                                  }
                                },
                                icon: const Icon(Icons.mail_outline),
                                label: const Text("Open Email App"),
                              ),
                            ),

                            const SizedBox(height: 10),

                            SizedBox(
                              width: double.infinity,
                              height: 46,
                              child: OutlinedButton.icon(
                                onPressed: () async{
                                  try{
                                    final user = FirebaseAuth.instance.currentUser;
                                    if(user == null) return;

                                    await user.reload();
                                    final updatedUser = FirebaseAuth.instance.currentUser;

                                    if(updatedUser != null && updatedUser.emailVerified){
                                      await FirebaseFirestore.instance.collection("users").doc(updatedUser.uid).set({
                                        "email" : updatedUser.email,
                                        "createdAt" : FieldValue.serverTimestamp()
                                      },
                                          SetOptions(merge: true)
                                      );

                                      await authStateInstance.reloadUser();

                                      if(!context.mounted) return;
                                      context.go('/profileSetup');
                                    }
                                    else{
                                      if(!context.mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text("Email is not verified. Please click the link.")),
                                      );
                                    }
                                  } on FirebaseException catch(e){
                                    String msg = "Signup failed. Please try again.";

                                    if (e.code == "email-already-in-use") {
                                      msg = "This email is already registered. Try logging in.";
                                    } else if (e.code == "invalid-email") {
                                      msg = "Please enter a valid email address.";
                                    } else if (e.code == "weak-password") {
                                      msg = "Password is too weak. Use a stronger password.";
                                    } else if (e.code == "network-request-failed") {
                                      msg = "No internet connection. Please try again.";
                                    } else if (e.code == "too-many-requests") {
                                      msg = "Too many attempts. Please try again later.";
                                    } else if (e.code == "operation-not-allowed") {
                                      msg = "Email/password signup is not enabled right now.";
                                    } else {
                                      msg = "Signup failed. Please try again.";
                                    }

                                    if(!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(msg)),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.refresh),
                                label: const Text("I Verified (Refresh)"),
                              ),
                            ),

                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Expanded(
                                  child: TextButton(
                                    onPressed: () async{
                                      try{
                                        await FirebaseAuth.instance.currentUser?.sendEmailVerification();

                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("Verification link sent again.")),
                                        );
                                      } on FirebaseAuthException catch(e){
                                        if (!context.mounted) return;

                                        String msg = "Failed to resend verification email";

                                        if(e.code == "too-many-requests"){
                                          msg = "Please wait a bit before resending.";
                                        }
                                        else if(e.code == "network-request-failed"){
                                          msg = "No internet connection.";
                                        }
                                        else if(e.code == "user-token-expired" || e.code == "invalid-user-token"){
                                          msg = "Session expired. Please enter email again.";
                                        }
                                        else{
                                          msg = "Failed to resend verification email";
                                        }

                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(msg)),
                                        );
                                      }
                                    },
                                    child: const Text("Resend link"),
                                  ),
                                ),
                                Expanded(
                                  child: TextButton(
                                    onPressed: () async{
                                      try{
                                        await FirebaseAuth.instance.currentUser?.delete();

                                        if(!context.mounted) return;
                                        context.go('/signup');
                                      } on FirebaseAuthException catch(e){
                                        if(!context.mounted) return;

                                        String msg = "Something went wrong while changing email. Please try again.";

                                        if (e.code == "requires-recent-login") {
                                          await FirebaseAuth.instance.signOut();

                                          if (!context.mounted) return;
                                          context.go('/signup');
                                          return;
                                        } else if (e.code == "network-request-failed") {
                                          msg = "No internet connection.";
                                        }

                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(msg)),
                                        );
                                      }
                                    },
                                    child: const Text("Change email"),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
