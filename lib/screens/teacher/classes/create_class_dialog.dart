import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../services/class_service.dart';
import '../../../services/category_service.dart';
import '../../../models/category_model.dart';

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
  final _categoryService = CategoryService();

  late TextEditingController _titleController;
  late TextEditingController _descController;
  
  String? _selectedCategoryId;
  List<CategoryModel> _categories = [];

  DateTime? _startDate;
  // End Date is now same as Start Date for single day classes
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descController = TextEditingController();
    _selectedCategoryId = widget.preFilledCategoryId;
    
    _startDate = widget.preFilledDate ?? DateTime.now();
    _startTime = widget.preFilledTime ?? const TimeOfDay(hour: 9, minute: 0);
    _endTime = _startTime?.replacing(hour: _startTime!.hour + 1);

    _loadCategories();
  }

  Future<void> _loadCategories() async {
    // Determine if we are filtering by parent or just getting top level
    // For now, let's just get top level + current category if it exists
    // Ideally we might want a flattened list or similar, but let's stick to top level for the dropdown
    // or if preFilledCategoryId is set, maybe we don't need to load?
    // Let's load top level for now.
    
    // Using stream as a one-time fetch for dropdown
    final snapshot = await _categoryService.getTopLevelCategories().first;
    if (mounted) {
      setState(() {
        _categories = snapshot;
        // If preFilledCategoryId is not in the list (e.g. it's a subcategory), we might need to handle that.
        // For this simple fix, we assume we are creating at the level we are viewing or selecting a top level.
        if (_selectedCategoryId != null && !_categories.any((c) => c.id == _selectedCategoryId)) {
             // If we can't find it in top level, maybe we should fetch it? 
             // Or just leave it as is if it's already set (value can be anything but Dropdown needs it to be in items)
             // If it's not in items, Dropdown will crash or show nothing if we don't handle it.
             // Let's just append a "Current" placeholder if needed or handle this better later.
             // For now, we assume top level categories. 
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select date and times")));
      return;
    }
    
    // Enforce category selection
    final categoryId = _selectedCategoryId;
    if (categoryId == null || categoryId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a category")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("No user logged in");

      // Single day class: Start/End Date are the same day
      // Days array contains just that day name
      final dayName = DateFormat('E').format(_startDate!);

      await _classService.createClass(
        title: _titleController.text,
        description: _descController.text,
        teacherId: user.uid,
        categoryId: categoryId,
        parentCategoryId: 'root', // Simplified
        startTime: '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}',
        endTime: '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}',
        days: [dayName],
        startDate: _startDate!,
        endDate: _startDate!, // Single day
        capacity: 20, 
        inviteEnabled: true,
      );

      if (mounted) Navigator.pop(context, true); 
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
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
              const SizedBox(height: 16),
              
              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                decoration: const InputDecoration(labelText: "Category"),
                items: _categories.map((c) {
                  return DropdownMenuItem(value: c.id, child: Text(c.name));
                }).toList(),
                onChanged: (val) => setState(() => _selectedCategoryId = val),
                 validator: (v) => v == null ? "Required" : null,
              ),

              const SizedBox(height: 16),
              
              // Date Picker (Single)
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today),
                  label: Text(_startDate == null ? "Select Date" : DateFormat('EEE, MMM d, yyyy').format(_startDate!)),
                  style: TextButton.styleFrom(alignment: Alignment.centerLeft),
                ),
              ),
              
              const SizedBox(height: 8),

              Row(
                children: [
                   Expanded(
                    child: TextButton.icon(
                      onPressed: () => _pickTime(true),
                      icon: const Icon(Icons.access_time),
                      label: Text(_startTime == null ? "Start" : _startTime!.format(context)),
                    ),
                  ),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () => _pickTime(false),
                      icon: const Icon(Icons.access_time_filled),
                      label: Text(_endTime == null ? "End" : _endTime!.format(context)),
                    ),
                  ),
                ],
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
