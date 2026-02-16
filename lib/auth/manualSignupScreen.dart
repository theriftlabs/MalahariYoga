import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManualSignupScreen extends StatefulWidget {
  const ManualSignupScreen({super.key});

  @override
  State<ManualSignupScreen> createState() => _ManualSignupScreenState();
}

class _ManualSignupScreenState extends State<ManualSignupScreen> {
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
                              "Sign up",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Create your account to get started",
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
                                      hintText: "you@example.com",
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
                                      hintText: "Create a password",
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
                                      if (!isStrongPassword(password)) return "Enter a stronger password";
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 18),

                            SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                onPressed: () async{
                                  if (!_formKey.currentState!.validate()) return;
                                  try{
                                    final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                                        email: emailController.text.trim(),
                                        password: passController.text.trim()
                                    );

                                    await cred.user!.sendEmailVerification();

                                    if(!context.mounted) return;
                                    context.go('/verify');
                                  } on FirebaseAuthException catch(e){
                                    if(!context.mounted) return;

                                    String msg = "Signup failed. Try again.";

                                    if (e.code == "email-already-in-use") {
                                      msg = "This email is already in use. Try logging in.";
                                    } else if (e.code == "invalid-email") {
                                      msg = "That email address looks invalid.";
                                    } else if (e.code == "weak-password") {
                                      msg = "Password is too weak.";
                                    }

                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(duration: Duration(seconds: 5), content: Text(msg)));
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text("Create account"),
                              ),
                            ),

                            const SizedBox(height: 14),

                            TextButton(
                              onPressed: () {
                                context.go('/login');
                              },
                              child: const Text("Already have an account? Log in"),
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

bool isStrongPassword(String password) {
  return RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
  ).hasMatch(password);
}
