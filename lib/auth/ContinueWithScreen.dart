import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ContinueWithScreen extends StatefulWidget {
  const ContinueWithScreen({super.key});

  @override
  State<ContinueWithScreen> createState() => _ContinueWithScreenState();
}

class _ContinueWithScreenState extends State<ContinueWithScreen> {
  bool _loading = false;

  Future<void> _signInWithGoogle() async {
    if (_loading) return;

    setState(() => _loading = true);

    final auth = FirebaseAuth.instance;

    try {
      final googleSignIn = GoogleSignIn();

      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        setState(() => _loading = false);
        return;
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 🔹 Sign in
      final userCredential =
      await auth.signInWithCredential(credential);

      final user = userCredential.user;
      if (user == null) {
        setState(() => _loading = false);
        return;
      }

      // 🔥 ENSURE GOOGLE IS PERMANENTLY LINKED
      final providerIds =
      user.providerData.map((e) => e.providerId).toList();

      if (!providerIds.contains('google.com')) {
        await user.linkWithCredential(credential);
      }

      // 🔹 Create / merge Firestore profile
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .set({
        "email": user.email,
        "createdAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String msg = "Google sign-in failed.";

      if (e.code == "account-exists-with-different-credential") {
        msg =
        "This email already has an account. Please log in with Email first.";
      } else if (e.code == "network-request-failed") {
        msg = "No internet connection.";
      } else {
        msg = "Google sign-in failed (${e.code}).";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong."),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
                constraints:
                BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints:
                    const BoxConstraints(maxWidth: 420),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding:
                        const EdgeInsets.all(22.0),
                        child: Column(
                          mainAxisSize:
                          MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.self_improvement,
                              size: 52,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              "Malahari Yoga",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight:
                                FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Sign in to continue",
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 22),

                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton.icon(
                                onPressed: _loading
                                    ? null
                                    : _signInWithGoogle,
                                icon: _loading
                                    ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child:
                                  CircularProgressIndicator(
                                      strokeWidth:
                                      2),
                                )
                                    : const Icon(
                                    Icons
                                        .g_mobiledata,
                                    size: 26),
                                label: Text(
                                  _loading
                                      ? "Signing in..."
                                      : "Continue with Google",
                                ),
                                style:
                                ElevatedButton
                                    .styleFrom(
                                  backgroundColor:
                                  Colors.white,
                                  foregroundColor:
                                  Colors.black87,
                                  elevation: 0,
                                  side: BorderSide(
                                      color: Colors
                                          .grey
                                          .shade300),
                                  shape:
                                  RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius
                                        .circular(
                                        12),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            Row(
                              children: [
                                Expanded(
                                    child: Divider(
                                        color: Colors
                                            .grey
                                            .shade300)),
                                Padding(
                                  padding:
                                  const EdgeInsets
                                      .symmetric(
                                      horizontal:
                                      10),
                                  child: Text(
                                    "or",
                                    style: TextStyle(
                                        color: Colors
                                            .grey
                                            .shade600),
                                  ),
                                ),
                                Expanded(
                                    child: Divider(
                                        color: Colors
                                            .grey
                                            .shade300)),
                              ],
                            ),

                            const SizedBox(height: 12),

                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child:
                              ElevatedButton.icon(
                                onPressed: () {
                                  context.go(
                                      '/login');
                                },
                                icon: const Icon(
                                    Icons
                                        .email_outlined),
                                label: const Text(
                                    "Continue with Email"),
                                style:
                                ElevatedButton
                                    .styleFrom(
                                  shape:
                                  RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius
                                        .circular(
                                        12),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            Text(
                              "By continuing, you agree to our Terms & Privacy Policy.",
                              textAlign:
                              TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                Colors.grey.shade600,
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
