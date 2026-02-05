import 'package:flutter/material.dart';
import 'package:malahari_yoga/screens/teacher/classes/category_view.dart';
import 'package:malahari_yoga/screens/teacher/classes/calendar_view.dart';

class TeacherClassesTab extends StatelessWidget {
  const TeacherClassesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manage Classes'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.list), text: 'Category View'),
              Tab(icon: Icon(Icons.calendar_month), text: 'Calendar View'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
             CategoryView(),
             CalendarView(),
          ],
        ),
      ),
    );
  }
}
