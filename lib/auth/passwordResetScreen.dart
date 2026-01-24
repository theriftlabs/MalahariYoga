import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _loading = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Reset password"),
        centerTitle: true,
      ),
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
                            Text(
                              "Forgot your password?",
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Enter your email and we’ll send you a reset link.",
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 20),

                            Form(
                              key: _formKey,
                              child: TextFormField(
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                decoration: InputDecoration(
                                  labelText: "Email",
                                  hintText: "Enter your email",
                                  prefixIcon: const Icon(Icons.email_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (value) {
                                  final email = value?.trim() ?? "";
                                  if (email.isEmpty) return "Email is required";
                                  if (!isValidEmail(email)) {
                                    return "Enter a valid email address";
                                  }
                                  return null;
                                },
                              ),
                            ),

                            const SizedBox(height: 18),

                            SizedBox(
                              height: 48,
                              child: ElevatedButton.icon(
                                onPressed: _loading
                                    ? null
                                    : () async {
                                  if (!_formKey.currentState!.validate()) return;

                                  try{
                                    setState(() => _loading = true);
                                    await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text.trim());
                                    await Future.delayed(const Duration(milliseconds: 600));

                                    if (!context.mounted) return;
                                    setState(() => _loading = false);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Reset link sent."),
                                      ),
                                    );
                                  } on FirebaseAuthException catch (e) {
                                    if (!mounted) return;

                                    String msg = "Could not send reset email. Please try again.";

                                    if (e.code == "invalid-email") {
                                      msg = "That email address looks invalid.";
                                    } else if (e.code == "user-not-found") {
                                      msg = "No account found with this email.";
                                    } else if (e.code == "network-request-failed") {
                                      msg = "No internet connection. Please try again.";
                                    } else if (e.code == "too-many-requests") {
                                      msg = "Too many attempts. Please wait and try again.";
                                    } else if (e.code == "operation-not-allowed") {
                                      msg = "Password reset is not enabled right now.";
                                    } else {
                                      msg = "Could not send reset email (${e.code}).";
                                    }

                                    setState(() => _loading = false);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(msg)),
                                    );
                                  }
                                },
                                icon: _loading
                                    ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                                    : const Icon(Icons.send_outlined),
                                label: Text(_loading ? "Sending..." : "Send reset link"),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            TextButton(
                              onPressed: () {
                                context.go('/login');
                              },
                              child: const Text("Back to login"),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              "Tip: check Spam/Promotions if you don’t see it.",
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                              ),
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
