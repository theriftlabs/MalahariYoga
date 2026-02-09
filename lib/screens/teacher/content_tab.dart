import 'package:flutter/material.dart';

class TeacherContentTab extends StatelessWidget {
  const TeacherContentTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teacher Content')),
      body: const Center(child: Text('Teacher Content Tab (Mockup)')),
    );
  }
}
