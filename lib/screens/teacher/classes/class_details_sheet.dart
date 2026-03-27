import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/class_model.dart';
import '../../../services/invite_service.dart';

class ClassDetailsSheet extends StatefulWidget {
  final ClassModel classModel;

  const ClassDetailsSheet({super.key, required this.classModel});

  @override
  State<ClassDetailsSheet> createState() => _ClassDetailsSheetState();
}

class _ClassDetailsSheetState extends State<ClassDetailsSheet> {
  final InviteService _inviteService = InviteService();
  String? _generatedLink;
  bool _loading = false;

  Future<void> _generateInvite() async {
    setState(() => _loading = true);
    try {
      final token = await _inviteService.createInvite(widget.classModel.id);
      setState(() {
        // Mock domain for now as per requirements
        _generatedLink = "https://yourdomain.com/join/$token";
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.classModel;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(c.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(c.description),
          const Divider(height: 32),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16),
              const SizedBox(width: 8),
              Text("Days: ${c.days.join(', ')}"),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time, size: 16),
              const SizedBox(width: 8),
              Text("${c.startTime} - ${c.endTime}"),
            ],
          ),
          const SizedBox(height: 24),
          if (_generatedLink == null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _generateInvite,
                icon: const Icon(Icons.link),
                label: _loading 
                   ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                   : const Text("Generate Invite Link"),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   const Text("Invite Link Generated:", style: TextStyle(fontSize: 12, color: Colors.grey)),
                   const SizedBox(height: 4),
                   SelectableText(
                     _generatedLink!,
                     style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                   ),
                   const SizedBox(height: 8),
                   OutlinedButton(
                     onPressed: () {
                       Clipboard.setData(ClipboardData(text: _generatedLink!));
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Link copied!")));
                     },
                     child: const Text("Copy Link"),
                   )
                ],
              ),
            ),
           const SizedBox(height: 24),
        ],
      ),
    );
  }
}
