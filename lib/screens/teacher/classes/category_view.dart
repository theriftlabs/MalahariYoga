import 'package:flutter/material.dart';
import 'package:malahari_yoga/screens/teacher/classes/create_class_dialog.dart';
import 'package:malahari_yoga/screens/teacher/classes/class_details_sheet.dart';
import '../../../services/category_service.dart';
import '../../../services/class_service.dart';
import '../../../models/category_model.dart';
import '../../../models/class_model.dart';

class CategoryView extends StatefulWidget {
  final String? categoryId;
  final String title;

  const CategoryView({Key? key, this.categoryId, this.title = "Categories"}) : super(key: key);

  @override
  State<CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<CategoryView> {
  final CategoryService _categoryService = CategoryService();
  final ClassService _classService = ClassService();

  void _navigateToCategory(CategoryModel category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryView(categoryId: category.id, title: category.name),
      ),
    );
  }

  void _showCreateDialog() async {
    await showDialog(
      context: context,
      builder: (_) => CreateClassDialog(
        preFilledCategoryId: widget.categoryId,
      ),
    );
    // Stream updates automatically
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.categoryId == null 
        ? null // Main tab view logic doesn't expect nested Scaffold to have AppBar unless drill down
        : AppBar(title: Text(widget.title)), 
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        label: const Text("Add Class"),
        icon: const Icon(Icons.add),
      ),
      body: CustomScrollView(
        slivers: [
          // Subcategories
          StreamBuilder<List<CategoryModel>>(
            stream: widget.categoryId == null 
               ? _categoryService.getTopLevelCategories() 
               : _categoryService.getSubCategories(widget.categoryId!),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SliverToBoxAdapter(child: LinearProgressIndicator());
              final categories = snapshot.data!;
              
              if (categories.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final cat = categories[index];
                    return ListTile(
                      leading: const Icon(Icons.folder),
                      title: Text(cat.name),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _navigateToCategory(cat),
                    );
                  },
                  childCount: categories.length,
                ),
              );
            },
          ),
          
          // Header for Classes (only if inside a category)
          if (widget.categoryId != null)
             const SliverToBoxAdapter(
               child: Padding(
                 padding: EdgeInsets.all(16.0),
                 child: Text("Classes in this Category", style: TextStyle(fontWeight: FontWeight.bold)),
               ),
             ),
             
          // Classes List
          if (widget.categoryId != null)
            StreamBuilder<List<ClassModel>>(
              stream: _classService.getClassesByCategory(widget.categoryId!),
              builder: (context, snapshot) {
                 if (!snapshot.hasData) return const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(16), child: Text("Loading classes...")));
                 final classes = snapshot.data!;
                 
                 if (classes.isEmpty) return const SliverToBoxAdapter(
                   child: Padding(padding: EdgeInsets.all(16), child: Text("No classes found. Add one!")),
                 );

                 return SliverList(
                   delegate: SliverChildBuilderDelegate(
                     (context, index) {
                       final cls = classes[index];
                       return ListTile(
                         leading: const Icon(Icons.class_),
                         title: Text(cls.title),
                         subtitle: Text("${cls.days.join(', ')} @ ${cls.startTime}"),
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
                     childCount: classes.length,
                   ),
                 );
              },
            )
        ],
      ),
    );
  }
}
