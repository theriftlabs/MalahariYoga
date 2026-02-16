import 'package:flutter/material.dart';

class Teacher extends StatefulWidget {
  const Teacher({super.key});

  @override
  State<Teacher> createState() => _TeacherState();
}

class _TeacherState extends State<Teacher> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    TeacherDashboard(),
    TeacherSchedule(),
    TeacherContent(),
    TeacherProfile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Teacher"),
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
          BottomNavigationBarItem(icon: Icon(Icons.schedule), label: "Schedule"),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: "Content"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          dashboardCard("Today's Sessions", "2 sessions scheduled"),
          const SizedBox(height: 12),
          dashboardCard("Students Enrolled", "Total: 42"),
          const SizedBox(height: 12),
          dashboardCard(
            "Announcements",
            "Post updates to students",
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

class TeacherSchedule extends StatelessWidget {
  const TeacherSchedule({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          studentRow("Ananya", "Present"),
          studentRow("Rahul", "Absent"),
          studentRow("Meera", "Present"),
          studentRow("Karan", "Unmarked"),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            child: const Text("Save Attendance"),
          ),
        ],
      ),
    );
  }
}

class TeacherContent extends StatelessWidget {
  const TeacherContent({super.key});

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
              ChoiceChip(label: Text("Morning Yoga"), selected: true),
              ChoiceChip(label: Text("Meditation"), selected: false),
              ChoiceChip(label: Text("Beginners"), selected: false),
            ],
          ),
          const SizedBox(height: 16),
          dashboardCard("Week 2 Routine (PDF)", "Morning Yoga"),
          const SizedBox(height: 12),
          dashboardCard("Balance Practice (Link)", "Morning Yoga"),
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

class TeacherProfile extends StatelessWidget {
  const TeacherProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Teacher Profile",
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
          Text(title,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600)),
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

Widget studentRow(String name, String status) {
  return Card(
    child: ListTile(
      title: Text(name),
      subtitle: Text(status),
      trailing: ElevatedButton(
        onPressed: () {},
        child: Text(status == "Present" ? "Present" : "Mark"),
      ),
    ),
  );
}