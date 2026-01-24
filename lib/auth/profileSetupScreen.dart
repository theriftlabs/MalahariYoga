import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:phone_number/phone_number.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final PageController _pageController = PageController();
  int _pageIndex = 0;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  String selectedRole = "student";

  final PhoneNumberUtil _phoneUtil = PhoneNumberUtil();
  bool isPhoneValid = false;
  bool _phoneChecking = false;

  final String adminEmail = "malhar.srivatsav@gmail.com";

  @override
  void dispose() {
    _pageController.dispose();
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (_pageIndex < 2) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _back() async {
    if (_pageIndex > 0) {
      await _pageController.previousPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _checkPhone(String number) async {
    final input = number.trim();

    if (input.isEmpty) {
      setState(() => isPhoneValid = false);
      return;
    }

    setState(() => _phoneChecking = true);

    final ok = await _phoneUtil.validate(input, regionCode: "IN");

    if (!mounted) return;
    setState(() {
      isPhoneValid = ok;
      _phoneChecking = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final user = FirebaseAuth.instance.currentUser;
    final isAdmin = (user?.email?.toLowerCase() == adminEmail.toLowerCase());

    bool isNameValid = nameController.text.trim().isNotEmpty;

    bool canGoNext() {
      if (_pageIndex == 0) return isNameValid;
      if (_pageIndex == 1) return isAdmin ? true : selectedRole.isNotEmpty;
      if (_pageIndex == 2) return isPhoneValid;
      return false;
    }

    String nextLabel = _pageIndex == 2 ? "Finish" : "Next";

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Profile Setup"),
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
                              "Complete your profile",
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Just a few quick details.",
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Progress dots
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(3, (i) {
                                final active = i == _pageIndex;
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  height: 8,
                                  width: active ? 20 : 8,
                                  decoration: BoxDecoration(
                                    color: active ? Colors.black87 : Colors.grey.shade400,
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                );
                              }),
                            ),

                            const SizedBox(height: 18),

                            SizedBox(
                              height: 220, // fixed height so buttons don’t jump
                              child: PageView(
                                controller: _pageController,
                                onPageChanged: (i) {
                                  setState(() => _pageIndex = i);
                                },
                                physics: const NeverScrollableScrollPhysics(),
                                children: [
                                  // Slide 1: Name
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        "Your name",
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "This is the name others will see.",
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      TextField(
                                        controller: nameController,
                                        textInputAction: TextInputAction.next,
                                        onChanged: (_) => setState(() {}),
                                        decoration: InputDecoration(
                                          labelText: "Full name",
                                          hintText: "e.g. Aarya Sharma",
                                          prefixIcon: const Icon(Icons.person_outline),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height:5),
                                      Text(
                                        nameController.text.trim().isEmpty ? "Name cannot be empty" : "",
                                        style: TextStyle(
                                          color: nameController.text.trim().isEmpty ? Colors.red : Colors.grey
                                        ),
                                      )
                                    ],
                                  ),

                                  // Slide 2: Role
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        isAdmin ? "Admin detected" : "Select your role",
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),

                                      Text(
                                        isAdmin
                                            ? "Your account role is locked as Admin."
                                            : "This helps us show the right features.",
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: Colors.grey.shade700,
                                        ),
                                      ),

                                      const SizedBox(height: 14),

                                      if (!isAdmin)
                                        DropdownButtonFormField<String>(
                                          value: selectedRole,
                                          decoration: InputDecoration(
                                            labelText: "Role",
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          items: const [
                                            DropdownMenuItem(
                                              value: "student",
                                              child: Text("Student"),
                                            ),
                                            DropdownMenuItem(
                                              value: "teacher",
                                              child: Text("Teacher"),
                                            ),
                                          ],
                                          onChanged: (value) {
                                            if (value == null) return;
                                            setState(() => selectedRole = value);
                                          },
                                        )
                                      else
                                        Container(
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: Colors.grey.shade300),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.lock_outline, size: 18),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  "Role: Admin",
                                                  style: theme.textTheme.bodyMedium?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                      const SizedBox(height: 10),

                                      Text(
                                        "Note: You can’t change your role later.",
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: Colors.redAccent,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Slide 3: Phone
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        "Phone number",
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Used for contact and class updates.",
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      TextField(
                                        controller: phoneController,
                                        keyboardType: TextInputType.phone,
                                        textInputAction: TextInputAction.done,
                                        onChanged: (value) {
                                          _checkPhone(value);
                                        },
                                        decoration: InputDecoration(
                                          labelText: "Phone number",
                                          hintText: "e.g. 9876543210",
                                          prefixIcon: const Icon(Icons.phone_outlined),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height:5),
                                      Text(
                                        _phoneChecking
                                            ? "Checking..."
                                            : (phoneController.text.trim().isNotEmpty && !isPhoneValid)
                                            ? "Invalid phone number"
                                            : "",
                                        style: TextStyle(
                                          color: _phoneChecking ? Colors.grey : Colors.red,
                                        ),
                                      ),
                                      const SizedBox(height:10),
                                      Text(
                                        "Tip: include country code if needed (+91).",
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 18),

                            // Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: _pageIndex == 0 ? null : _back,
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                    ),
                                    child: const Text("Back"),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: canGoNext()
                                        ? () async {
                                      if (_pageIndex < 2) {
                                        await _next();
                                      } else {
                                        final user = FirebaseAuth.instance.currentUser;
                                        if (user == null) return;

                                        final isAdmin = (user.email?.toLowerCase() == adminEmail.toLowerCase());

                                        try {
                                          await FirebaseFirestore.instance.collection("users").doc(user.uid).set(
                                            {
                                              "name": nameController.text.trim(),
                                              "role": isAdmin ? "admin" : selectedRole,
                                              "number": phoneController.text.trim(),
                                              "profileComplete": true,
                                            },
                                            SetOptions(merge: true),
                                          );

                                          if (!context.mounted) return;
                                          context.go('/loading');
                                        } on FirebaseException catch (e) {
                                          if (!context.mounted) return;

                                          String msg = "Failed to save profile. Please try again.";

                                          if (e.code == "permission-denied") {
                                            msg = "You don’t have permission to update this profile.";
                                          } else if (e.code == "unavailable") {
                                            msg = "Server is unreachable. Check your internet connection.";
                                          } else if (e.code == "cancelled") {
                                            msg = "Request cancelled. Please try again.";
                                          } else if (e.code == "deadline-exceeded") {
                                            msg = "Taking too long. Please try again.";
                                          } else if (e.code == "not-found") {
                                            msg = "Profile document not found. Please retry.";
                                          } else if (e.code == "already-exists") {
                                            msg = "Profile already exists. Please try again.";
                                          } else if (e.code == "resource-exhausted") {
                                            msg = "Too many requests. Please wait and try again.";
                                          } else if (e.code == "invalid-argument") {
                                            msg = "Some profile data is invalid. Please re-check inputs.";
                                          } else {
                                            msg = "Failed to save profile (${e.code}). Please try again.";
                                          }

                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(duration: const Duration(seconds: 4), content: Text(msg)),
                                          );
                                        } catch (_) {
                                          if (!context.mounted) return;

                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              duration: Duration(seconds: 4),
                                              content: Text("Something went wrong. Please try again."),
                                            ),
                                          );
                                        }
                                      }
                                    }
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                    ),
                                    child: Text(nextLabel),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            Center(
                              child: Text(
                                _pageIndex == 0
                                    ? "Step 1 of 3"
                                    : _pageIndex == 1
                                    ? "Step 2 of 3"
                                    : "Step 3 of 3",
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
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
