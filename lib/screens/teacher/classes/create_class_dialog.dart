import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../services/class_service.dart';

class CreateClassDialog extends StatefulWidget {
  final String? preFilledCategoryId;
  final DateTime? preFilledDate;
  final TimeOfDay? preFilledTime;

  const CreateClassDialog({
    super.key,
    this.preFilledCategoryId,
    this.preFilledDate,
    this.preFilledTime,
  });

  @override
  State<CreateClassDialog> createState() => _CreateClassDialogState();
}

class _CreateClassDialogState extends State<CreateClassDialog> {
  final _formKey = GlobalKey<FormState>();
  final _classService = ClassService();

  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _categoryIdController;

  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  
  // Simple day toggles
  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final Set<String> _selectedDays = {};

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descController = TextEditingController();
    _categoryIdController = TextEditingController(text: widget.preFilledCategoryId ?? '');
    
    _startDate = widget.preFilledDate ?? DateTime.now();
    _endDate = _startDate?.add(const Duration(days: 90)); // Default ~3 months
    _startTime = widget.preFilledTime ?? const TimeOfDay(hour: 9, minute: 0);
    _endTime = _startTime?.replacing(hour: _startTime!.hour + 1);
    
    // Auto-select the day of the week if date is provided
    if (widget.preFilledDate != null) {
      final dayName = DateFormat('E').format(widget.preFilledDate!); // Mon, Tue...
      _selectedDays.add(dayName);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null || _startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select all dates and times")));
      return;
    }
    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select at least one day")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("No user logged in");

      await _classService.createClass(
        title: _titleController.text,
        description: _descController.text,
        teacherId: user.uid,
        categoryId: _categoryIdController.text.isEmpty ? 'uncategorized' : _categoryIdController.text,
        parentCategoryId: 'root', // Simplified for demo
        startTime: '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}',
        endTime: '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}',
        days: _selectedDays.toList(),
        startDate: _startDate!,
        endDate: _endDate!,
        capacity: 20, // Default
        inviteEnabled: true,
      );

      if (mounted) Navigator.pop(context, true); // Return true on success
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now()),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          // Ensure end date is after start
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
             _endDate = _startDate!.add(const Duration(days: 90));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _pickTime(bool isStart) async {
     final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? (_startTime ?? TimeOfDay.now()) : (_endTime ?? TimeOfDay.now()),
    );
    if (picked != null) {
      setState(() {
        if (isStart) _startTime = picked;
        else _endTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Create Class"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Class Title"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: "Description"),
              ),
              TextFormField(
                controller: _categoryIdController,
                decoration: const InputDecoration(labelText: "Category ID (Optional)"),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => _pickDate(true),
                      child: Text(_startDate == null ? "Start Date" : DateFormat('yyyy-MM-dd').format(_startDate!)),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () => _pickDate(false),
                      child: Text(_endDate == null ? "End Date" : DateFormat('yyyy-MM-dd').format(_endDate!)),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                   Expanded(
                    child: TextButton(
                      onPressed: () => _pickTime(true),
                      child: Text(_startTime == null ? "Start Time" : _startTime!.format(context)),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () => _pickTime(false),
                      child: Text(_endTime == null ? "End Time" : _endTime!.format(context)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: _days.map((day) {
                  final isSelected = _selectedDays.contains(day);
                  return FilterChip(
                    label: Text(day),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                         if (selected) _selectedDays.add(day);
                         else _selectedDays.remove(day);
                      });
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Create"),
        )
      ],
    );
  }
}
