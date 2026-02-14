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
  late TextEditingController _newCategoryController;
  
  String? _selectedCategoryId;
  bool _isCreatingCategory = false;

  DateTime? _startDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descController = TextEditingController();
    _newCategoryController = TextEditingController();
    _selectedCategoryId = widget.preFilledCategoryId;
    
    _startDate = widget.preFilledDate ?? DateTime.now();
    _startTime = widget.preFilledTime ?? const TimeOfDay(hour: 9, minute: 0);
    _endTime = _startTime?.replacing(hour: _startTime!.hour + 1);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select date and times")));
      return;
    }
    
    // Determine category ID
    String? categoryId = _selectedCategoryId;
    
    if (_isCreatingCategory) {
      if (_newCategoryController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a category name")));
        return;
      }
    } else if (categoryId == null || categoryId.isEmpty) {
      // Logic handled in UI, but double check
      // If we are NOT creating, and id is null, we might be in the "empty list" state which forces creation?
      // Or user just didn't select.
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("No user logged in");

      // Create category if needed
      if (_isCreatingCategory) {
         categoryId = await _categoryService.createCategory(_newCategoryController.text);
      } else if (categoryId == null) {
        throw Exception("Please select or create a category");
      }

      final dayName = DateFormat('E').format(_startDate!);

      await _classService.createClass(
        title: _titleController.text,
        description: _descController.text,
        teacherId: user.uid,
        categoryId: categoryId!,
        parentCategoryId: 'root', 
        startTime: '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}',
        endTime: '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}',
        days: [dayName],
        startDate: _startDate!,
        endDate: _startDate!,
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
              
              // Category Selection
              StreamBuilder<List<CategoryModel>>(
                stream: _categoryService.getTopLevelCategories(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const LinearProgressIndicator();
                  
                  final categories = snapshot.data!;
                  
                  // If no categories exist, force create mode
                  if (categories.isEmpty) {
                     _isCreatingCategory = true;
                     return TextFormField(
                       controller: _newCategoryController,
                       decoration: const InputDecoration(
                         labelText: "Create New Category",
                         hintText: "No categories found. Enter name...",
                       ),
                       validator: (v) => v!.isEmpty ? "Required" : null,
                     );
                  }

                  return Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       if (!_isCreatingCategory)
                         DropdownButtonFormField<String>(
                           value: _selectedCategoryId,
                           decoration: const InputDecoration(labelText: "Category"),
                           items: categories.map((c) {
                             return DropdownMenuItem(value: c.id, child: Text(c.name));
                           }).toList(),
                           onChanged: (val) => setState(() => _selectedCategoryId = val),
                           validator: (v) => v == null ? "Required" : null,
                         ),
                       
                       if (_isCreatingCategory)
                         TextFormField(
                           controller: _newCategoryController,
                           decoration: const InputDecoration(labelText: "New Category Name"),
                           validator: (v) => v!.isEmpty ? "Required" : null,
                         ),

                       TextButton(
                         onPressed: () {
                           setState(() {
                             _isCreatingCategory = !_isCreatingCategory;
                             if (_isCreatingCategory) _selectedCategoryId = null;
                           });
                         },
                         child: Text(_isCreatingCategory ? "Select Existing Category" : "Create New Category"),
                       ),
                     ],
                  );
                },
              ),

              const SizedBox(height: 16),
              
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
