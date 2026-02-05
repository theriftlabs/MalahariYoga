import 'package:flutter/material.dart';

class StudentProfileTab extends StatelessWidget {
  const StudentProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Profile')),
      body: const Center(child: Text('Student Profile Tab (Mockup)')),
    );
  }
}
