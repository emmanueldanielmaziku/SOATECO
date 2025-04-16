import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class SendNotificationScreen extends StatefulWidget {
  const SendNotificationScreen({Key? key}) : super(key: key);

  @override
  State<SendNotificationScreen> createState() => _SendNotificationScreenState();
}

class _SendNotificationScreenState extends State<SendNotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedGroup = 'all';
  bool _isLoading = false;

  final List<Map<String, String>> _groups = [
    {'id': 'all', 'name': 'All Students'},
    {'id': 'loan', 'name': 'Loan Beneficiaries'},
    {'id': 'hostel', 'name': 'Hostel Residents'},
    {'id': 'first_year', 'name': 'First Year Students'},
    {'id': 'final_year', 'name': 'Final Year Students'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendNotification() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      // Save notification to Firestore
      await FirebaseFirestore.instance.collection('notifications').add({
        'title': _titleController.text.trim(),
        'message': _messageController.text.trim(),
        'targetGroup': _selectedGroup,
        'authorId': authService.user!.uid,
        'authorEmail': authService.user!.email,
        'createdAt': FieldValue.serverTimestamp(),
        'read': [],
      });

      // In a real app, you would trigger FCM notifications here
      // This would typically be done via a Cloud Function

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification sent successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Clear form
        _titleController.clear();
        _messageController.clear();
        setState(() {
          _selectedGroup = 'all';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending notification: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Announcements'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Send Announcement',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Send important announcements to specific groups',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Target group
                Text(
                  'Target Group',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedGroup,
                      items: _groups.map((group) {
                        return DropdownMenuItem<String>(
                          value: group['id'],
                          child: Text(group['name']!),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGroup = value!;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Title field
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'Enter announcement title',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Message field
                TextFormField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    labelText: 'Message',
                    hintText: 'Enter announcement message',
                    alignLabelWithHint: true,
                  ),
                  maxLines: 6,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a message';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                
                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendNotification,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Send Announcement'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
