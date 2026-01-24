import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManualLoginScreen extends StatefulWidget {
  const ManualLoginScreen({super.key});

  @override
  State<ManualLoginScreen> createState() => _ManualLoginScreenState();
}

class _ManualLoginScreenState extends State<ManualLoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool obscurePass = true;

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(22.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              "Log in",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Welcome back 👋",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 22),

                            Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  TextFormField(
                                    controller: emailController,
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      labelText: "Email",
                                      hintText: "Enter email",
                                      prefixIcon: const Icon(Icons.email_outlined),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    validator: (value) {
                                      final email = value?.trim() ?? "";
                                      if (email.isEmpty) return "Email is required";
                                      if (!isValidEmail(email)) return "Enter a valid email address";
                                      return null;
                                    },
                                  ),

                                  const SizedBox(height: 14),

                                  TextFormField(
                                    controller: passController,
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    obscureText: obscurePass,
                                    decoration: InputDecoration(
                                      labelText: "Password",
                                      hintText: "Enter password",
                                      prefixIcon: const Icon(Icons.lock_outline),
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            obscurePass = !obscurePass;
                                          });
                                        },
                                        icon: Icon(
                                          obscurePass
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                        ),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    validator: (value) {
                                      final password = value?.trim() ?? "";
                                      if (password.isEmpty) return "Password is required";
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 10),

                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  context.go('/resetPassword');
                                },
                                child: const Text("Forgot password?"),
                              ),
                            ),

                            const SizedBox(height: 8),

                            SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                onPressed: () async{
                                  if (!_formKey.currentState!.validate()) return;
                                  try{
                                    await FirebaseAuth.instance.signInWithEmailAndPassword(
                                        email: emailController.text.trim(),
                                        password: passController.text
                                    );

                                    if (!context.mounted) return;
                                    context.go('/loading');
                                  } on FirebaseAuthException catch (e) {
                                    if (!context.mounted) return;

                                    String msg = "Login failed. Please try again.";

                                    if (e.code == "invalid-email") {
                                      msg = "That email address looks invalid.";
                                    } else if (e.code == "user-disabled") {
                                      msg = "This account has been disabled. Contact support.";
                                    } else if (e.code == "user-not-found") {
                                      msg = "No account found with this email. Try signing up.";
                                    } else if (e.code == "wrong-password") {
                                      msg = "Incorrect password. Try again.";
                                    } else if (e.code == "invalid-credential") {
                                      msg = "Incorrect email or password.";
                                    } else if (e.code == "network-request-failed") {
                                      msg = "No internet connection. Please try again.";
                                    } else if (e.code == "too-many-requests") {
                                      msg = "Too many attempts. Please wait and try again.";
                                    } else if (e.code == "operation-not-allowed") {
                                      msg = "Email/password login is not enabled right now.";
                                    } else {
                                      msg = "Login failed (${e.code}). Please try again.";
                                    }

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(msg)),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text("Log in"),
                              ),
                            ),

                            const SizedBox(height: 14),

                            TextButton(
                              onPressed: () {
                                context.go('/signup');
                              },
                              child: const Text("New here? Create an account"),
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

bool isValidEmail(String email) {
  return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email.trim());
}
