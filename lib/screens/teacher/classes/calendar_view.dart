import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../services/class_service.dart';
import '../../../models/class_model.dart';
import 'create_class_dialog.dart';
import 'class_details_sheet.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({Key? key}) : super(key: key);

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  
  final ClassService _classService = ClassService();
  final String _uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  List<ClassModel> _allClasses = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  // Filter classes active on a specific date
  List<ClassModel> _getClassesForDay(DateTime day) {
    // Weekday string: Mon, Tue...
    final dayName = DateFormat('E').format(day);
    
    return _allClasses.where((c) {
      // Check date range
      if (day.isBefore(c.startDate) || day.isAfter(c.endDate)) return false;
      // Check days array
      return c.days.contains(dayName);
    }).toList();
  }

  void _showCreateDialog() async {
    if (_selectedDay == null) return;
    
    await showDialog(
      context: context,
      builder: (_) => CreateClassDialog(
        preFilledDate: _selectedDay,
      ),
    );
     // Re-fetching is automatic via StreamBuilder, but we are using a StreamBuilder below?
     // Actually I should wrap the whole body in StreamBuilder or just the list.
     // For simplicity, let's wrap the Scaffold body or just the list part. 
     // Better pattern: Listening to stream in build or initState.
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ClassModel>>(
      stream: _classService.getClassesForTeacher(_uid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _allClasses = snapshot.data!;
        }

        final selectedClasses = _selectedDay == null ? <ClassModel>[] : _getClassesForDay(_selectedDay!);

        return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: _showCreateDialog,
            child: const Icon(Icons.add),
          ),
          body: Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2020, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                eventLoader: _getClassesForDay, // Shows dots
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  }
                },
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
              ),
              const Divider(),
              Expanded(
                child: selectedClasses.isEmpty 
                  ? const Center(child: Text("No classes for this day"))
                  : ListView.builder(
                      itemCount: selectedClasses.length,
                      itemBuilder: (context, index) {
                        final cls = selectedClasses[index];
                        return ListTile(
                          title: Text(cls.title),
                          subtitle: Text("${cls.startTime} - ${cls.endTime}"),
                          trailing: Chip(label: Text(cls.status)),
                          onTap: () {
                             showModalBottomSheet(
                               context: context,
                               isScrollControlled: true,
                               builder: (_) => ClassDetailsSheet(classModel: cls),
                             );
                          },
                        );
                      },
                    ),
              ),
            ],
          ),
        );
      }
    );
  }
}
