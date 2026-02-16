import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ResetPasswordConfirmScreen extends StatefulWidget {
  final String oobCode;

  const ResetPasswordConfirmScreen({
    super.key,
    required this.oobCode,
  });

  @override
  State<ResetPasswordConfirmScreen> createState() =>
      _ResetPasswordConfirmScreenState();
}

class _ResetPasswordConfirmScreenState
    extends State<ResetPasswordConfirmScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();

  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
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
                              "Create a new password",
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Choose a strong password you haven’t used before.",
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 20),

                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: passwordController,
                                    obscureText: _obscurePassword,
                                    autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                    decoration: InputDecoration(
                                      labelText: "New password",
                                      prefixIcon:
                                      const Icon(Icons.lock_outline),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword =
                                            !_obscurePassword;
                                          });
                                        },
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                        BorderRadius.circular(12),
                                      ),
                                    ),
                                    validator: (value) {
                                      final password = value?.trim() ?? "";
                                      if (password.isEmpty) return "Password is required";
                                      if (!isStrongPassword(password)) return "Enter a stronger password";
                                      return null;
                                    },
                                  ),

                                  const SizedBox(height: 14),

                                  TextFormField(
                                    controller: confirmPasswordController,
                                    obscureText: _obscureConfirmPassword,
                                    autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                    decoration: InputDecoration(
                                      labelText: "Confirm password",
                                      prefixIcon:
                                      const Icon(Icons.lock_outline),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureConfirmPassword
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscureConfirmPassword =
                                            !_obscureConfirmPassword;
                                          });
                                        },
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                        BorderRadius.circular(12),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Please confirm your password";
                                      }
                                      if (value !=
                                          passwordController.text) {
                                        return "Passwords do not match";
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _loading
                                    ? null
                                    : () async {
                                  if (!_formKey.currentState!.validate()) return;

                                  setState(() => _loading = true);

                                  try {
                                    await FirebaseAuth.instance.confirmPasswordReset(
                                      code: widget.oobCode,
                                      newPassword: passwordController.text.trim(),
                                    );

                                    if (!mounted) return;

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Password updated successfully."),
                                      ),
                                    );

                                    context.go('/login');
                                  } on FirebaseAuthException catch (e) {
                                    if (!mounted) return;

                                    String msg = "Something went wrong.";

                                    if (e.code == "expired-action-code") {
                                      msg = "This reset link has expired.";
                                    } else if (e.code == "invalid-action-code") {
                                      msg = "Invalid reset link.";
                                    } else if (e.code == "weak-password") {
                                      msg = "Password is too weak.";
                                    }

                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(content: Text(msg)));
                                  } finally {
                                    if (mounted) setState(() => _loading = false);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _loading
                                    ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                )
                                    : const Text("Update password"),
                              ),
                            ),

                            const SizedBox(height: 10),

                            TextButton(
                              onPressed: () {
                                context.go('/login');
                              },
                              child: const Text("Back to login"),
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

bool isStrongPassword(String password) {
  return RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
  ).hasMatch(password);
}