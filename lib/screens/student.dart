import 'package:flutter/material.dart';

class Student extends StatefulWidget {
  const Student({super.key});

  @override
  State<Student> createState() => _StudentState();
}

class _StudentState extends State<Student> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    StudentDashboard(),
    StudentSchedule(),
    StudentContent(),
    StudentProfile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student"),
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.schedule), label: "Schedule"),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: "Content"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          dashboardCard(
            "Next Session",
            "Morning Yoga Flow\nTue, 9:00 AM • Instructor: Walt",
            action: ElevatedButton(
              onPressed: () {},
              child: const Text("Join Class"),
            ),
          ),
          const SizedBox(height: 12),
          dashboardCard(
            "Payment Due",
            "₹2000 • Due Feb 1",
            action: ElevatedButton(
              onPressed: () {},
              child: const Text("Pay Now"),
            ),
          ),
          const SizedBox(height: 12),
          dashboardCard("New Content Added", "Breathing Exercises"),
          const SizedBox(height: 12),
          dashboardCard("Feedback Available", "Last session summary"),
        ],
      ),
    );
  }
}

class StudentSchedule extends StatelessWidget {
  const StudentSchedule({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          dashboardCard(
            "Morning Yoga Flow",
            "Tue, 9:00 AM • Walt",
            action: ElevatedButton(
              onPressed: () {},
              child: const Text("Join"),
            ),
          ),
          const SizedBox(height: 12),
          dashboardCard(
            "Evening Stretch",
            "Wed, 6:30 PM • Jesse",
            action: ElevatedButton(
              onPressed: () {},
              child: const Text("View"),
            ),
          ),
          const SizedBox(height: 12),
          dashboardCard(
            "Meditation Basics",
            "Fri, 7:00 AM • Walt",
            action: ElevatedButton(
              onPressed: () {},
              child: const Text("View"),
            ),
          ),
        ],
      ),
    );
  }
}

class StudentContent extends StatelessWidget {
  const StudentContent({super.key});

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
              ChoiceChip(label: Text("Morning Yoga"), selected: false),
              ChoiceChip(label: Text("Meditation"), selected: false),
            ],
          ),
          const SizedBox(height: 16),

          const Text(
            "STUDIO (GLOBAL)",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),

          dashboardCard("Breathing Exercises", "Article"),
          const SizedBox(height: 12),
          dashboardCard("Beginner Mobility Guide", "PDF"),

          const SizedBox(height: 24),
          const Text(
            "YOUR CLASSES",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),

          dashboardCard("Week 2 Routine – Morning Yoga", "PDF"),
          const SizedBox(height: 12),
          dashboardCard("Balance Practice Video", "External Link"),
        ],
      ),
    );
  }
}

class StudentProfile extends StatelessWidget {
  const StudentProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Student Profile",
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