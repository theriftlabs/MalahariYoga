import 'package:flutter/material.dart';

class StudentContentTab extends StatelessWidget {
  const StudentContentTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Content')),
      body: const Center(child: Text('Student Content Tab (Mockup)')),
    );
  }
}
