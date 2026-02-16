import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../../nav/appRouter.dart';

class StudentProfileTab extends StatefulWidget {
  const StudentProfileTab({super.key});

  @override
  State<StudentProfileTab> createState() => _StudentProfileTabState();
}

class _StudentProfileTabState extends State<StudentProfileTab> {

  bool _loadingLogout = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Profile"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// ================= PROFILE CARD =================
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.blueGrey.shade100,
                      child: Text(
                        userProfileStateInstance.name.isNotEmpty
                            ? userProfileStateInstance.name[0].toUpperCase()
                            : "T",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userProfileStateInstance.name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userProfileStateInstance.email,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        userProfileStateInstance.role,
                        style: const TextStyle(fontSize: 12),
                      ),
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// ================= MENU HEADER =================
            Text(
              "MENU",
              style: theme.textTheme.labelLarge?.copyWith(
                letterSpacing: 1.2,
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 12),

            /// LOGIN & SECURITY
            _buildMenuTile(
              title: "Login & Security",
              subtitle: "Google / Password",
              buttonText: "Open",
              onPressed: () {
                // TODO
              },
            ),

            const SizedBox(height: 12),

            /// DELETE ACCOUNT
            _buildMenuTile(
              title: "Delete Account",
              subtitle: "Remove profile access",
              buttonText: "Delete",
              destructive: true,
              onPressed: () {
                // TODO
              },
            ),

            const SizedBox(height: 12),

            /// LOGOUT
            _buildMenuTile(
              title: "Logout",
              subtitle: "Sign out",
              buttonText: _loadingLogout ? "..." : "Logout",
              onPressed: _loadingLogout ? () {} : _handleLogout,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    setState(() => _loadingLogout = true);

    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    setState(() => _loadingLogout = false);

    context.go('/');
  }

  /// ================= REUSABLE TILE =================
  Widget _buildMenuTile({
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onPressed,
    bool destructive = false,
  }) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor:
                destructive ? Colors.red : Colors.black,
                side: BorderSide(
                  color: destructive ? Colors.red : Colors.grey.shade400,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onPressed,
              child: Text(buttonText),
            )
          ],
        ),
      ),
    );
  }
}
