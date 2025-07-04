import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class LeaderCreateCampaignScreen extends StatefulWidget {
  const LeaderCreateCampaignScreen({super.key});

  @override
  State<LeaderCreateCampaignScreen> createState() =>
      _LeaderCreateCampaignScreenState();
}

class _LeaderCreateCampaignScreenState
    extends State<LeaderCreateCampaignScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _targetAmountController = TextEditingController();
  DateTime? _deadline;
  bool _loading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _deadline == null) return;
    setState(() => _loading = true);
    final user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance.collection('contribution_campaigns').add({
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'targetAmount': double.tryParse(_targetAmountController.text.trim()) ?? 0,
      'currentAmount': 0.0,
      'createdBy': user?.uid ?? '',
      'createdAt': DateTime.now(),
      'deadline': _deadline,
      'isActive': true,
    });
    setState(() => _loading = false);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Contribution Campaign'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter a title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter a description' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _targetAmountController,
                decoration:
                    const InputDecoration(labelText: 'Target Amount (USD)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter a target amount' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_deadline == null
                    ? 'Select Deadline'
                    : 'Deadline: ${_deadline!.day}/${_deadline!.month}/${_deadline!.year}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setState(() => _deadline = picked);
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Create Campaign'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
