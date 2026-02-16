import 'package:flutter/material.dart';

class Admin extends StatefulWidget {
  const Admin({super.key});

  @override
  State<Admin> createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    AdminDashboard(),
    AdminUsers(),
    AdminContent(),
    AdminProfile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin"),
        centerTitle: true,
        backgroundColor: Colors.grey,
        elevation: 0,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Users"),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: "Content"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          dashboardCard("Total Students", "128 enrolled"),
          const SizedBox(height: 12),
          dashboardCard("Total Teachers", "12 active"),
          const SizedBox(height: 12),
          dashboardCard(
            "Pending Approvals",
            "3 teachers awaiting approval",
            action: ElevatedButton(
              onPressed: () {},
              child: const Text("Review"),
            ),
          ),
          const SizedBox(height: 12),
          dashboardCard(
            "Announcements",
            "Send message to all users",
            action: ElevatedButton(
              onPressed: () {},
              child: const Text("Create Announcement"),
            ),
          ),
        ],
      ),
    );
  }
}

class AdminUsers extends StatelessWidget {
  const AdminUsers({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          userRow("Ananya", "Student"),
          userRow("Rahul", "Student"),
          userRow("Walt", "Teacher"),
          userRow("Jesse", "Teacher"),
          userRow("Karan", "Pending Teacher"),
        ],
      ),
    );
  }
}

class AdminContent extends StatelessWidget {
  const AdminContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            children: const [
              ChoiceChip(label: Text("All"), selected: true),
              ChoiceChip(label: Text("Yoga"), selected: false),
              ChoiceChip(label: Text("Meditation"), selected: false),
            ],
          ),
          const SizedBox(height: 16),
          dashboardCard("Breathing Exercises", "Article"),
          const SizedBox(height: 12),
          dashboardCard("Beginner Mobility Guide", "PDF"),
          const SizedBox(height: 12),
          dashboardCard("Balance Practice Video", "External Link"),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            child: const Text("Upload Content"),
          ),
        ],
      ),
    );
  }
}

class AdminProfile extends StatelessWidget {
  const AdminProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Admin Profile",
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}

Widget dashboardCard(String title, String subtitle, {Widget? action}) {
  return Card(
    elevation: 1,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Colors.grey)),
          if (action != null) ...[
            const SizedBox(height: 12),
            action,
          ],
        ],
      ),
    ),
  );
}

Widget userRow(String name, String role) {
  return Card(
    child: ListTile(
      title: Text(name),
      subtitle: Text(role),
      trailing: ElevatedButton(
        onPressed: () {},
        child: const Text("Manage"),
      ),
    ),
  );
}