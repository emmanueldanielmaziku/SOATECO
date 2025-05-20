import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_container.dart';

class LeaderFeedbackScreen extends StatelessWidget {
  const LeaderFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Feedback'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Student Feedback & Suggestions',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          Expanded(
            child: DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TabBar(
                      indicator: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: AppTheme.textSecondaryColor,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
                      tabs: const [
                        Tab(text: 'Pending'),
                        Tab(text: 'Reviewed'),
                        Tab(text: 'Resolved'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildFeedbackList(context, 'pending'),
                        _buildFeedbackList(context, 'reviewed'),
                        _buildFeedbackList(context, 'resolved'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackList(BuildContext context, String status) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('feedback')
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        
        final feedbacks = snapshot.data?.docs ?? [];
        
        if (feedbacks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.feedback_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No $status feedback available',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: feedbacks.length,
          itemBuilder: (context, index) {
            final feedback = feedbacks[index].data() as Map<String, dynamic>;
            final feedbackId = feedbacks[index].id;
            final createdAt = (feedback['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
            final isAnonymous = feedback['isAnonymous'] ?? false;
            
            return CustomContainer.card(
              onTap: () {
                _showFeedbackDetails(context, feedbackId, feedback, status);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(feedback['category']).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getCategoryIcon(feedback['category']),
                          color: _getCategoryColor(feedback['category']),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(feedback['category']).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getCategoryName(feedback['category']),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: _getCategoryColor(feedback['category']),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        DateFormat('MMM d, yyyy').format(createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    feedback['subject'] ?? 'No Subject',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    feedback['message'] ?? 'No message',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isAnonymous ? 'Anonymous' : 'From: ${feedback['studentEmail'] ?? 'Unknown'}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondaryColor,
                          fontStyle: isAnonymous ? FontStyle.italic : FontStyle.normal,
                        ),
                      ),
                      Text(
                        'View Details',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showFeedbackDetails(BuildContext context, String feedbackId, Map<String, dynamic> feedback, String currentStatus) {
    final createdAt = (feedback['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    final isAnonymous = feedback['isAnonymous'] ?? false;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(24),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Feedback Details',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(feedback['category']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getCategoryIcon(feedback['category']),
                          color: _getCategoryColor(feedback['category']),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _getCategoryName(feedback['category']),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: _getCategoryColor(feedback['category']),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    feedback['subject'] ?? 'No Subject',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppTheme.textSecondaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('MMM d, yyyy • h:mm a').format(createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        isAnonymous ? Icons.person_off : Icons.person,
                        size: 16,
                        color: AppTheme.textSecondaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isAnonymous ? 'Anonymous' : 'From: ${feedback['studentEmail'] ?? 'Unknown'}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondaryColor,
                          fontStyle: isAnonymous ? FontStyle.italic : FontStyle.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'Message:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        feedback['message'] ?? 'No message',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'Update Status:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatusButton(
                        context,
                        'pending',
                        'Pending',
                        Colors.orange,
                        currentStatus == 'pending',
                        () => _updateFeedbackStatus(context, feedbackId, 'pending'),
                      ),
                      _buildStatusButton(
                        context,
                        'reviewed',
                        'Reviewed',
                        Colors.blue,
                        currentStatus == 'reviewed',
                        () => _updateFeedbackStatus(context, feedbackId, 'reviewed'),
                      ),
                      _buildStatusButton(
                        context,
                        'resolved',
                        'Resolved',
                        Colors.green,
                        currentStatus == 'resolved',
                        () => _updateFeedbackStatus(context, feedbackId, 'resolved'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusButton(
    BuildContext context,
    String status,
    String label,
    Color color,
    bool isActive,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: isActive ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> _updateFeedbackStatus(BuildContext context, String feedbackId, String status) async {
    try {
      await FirebaseFirestore.instance.collection('feedback').doc(feedbackId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Feedback status updated to $status'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating status: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  String _getCategoryName(String? category) {
    switch (category) {
      case 'general':
        return 'General Feedback';
      case 'academic':
        return 'Academic Issues';
      case 'facilities':
        return 'Facilities';
      case 'services':
        return 'Student Services';
      case 'suggestion':
        return 'Suggestion';
      default:
        return 'General Feedback';
    }
  }

  IconData _getCategoryIcon(String? category) {
    switch (category) {
      case 'general':
        return Icons.feedback_outlined;
      case 'academic':
        return Icons.school_outlined;
      case 'facilities':
        return Icons.apartment_outlined;
      case 'services':
        return Icons.support_agent_outlined;
      case 'suggestion':
        return Icons.lightbulb_outline;
      default:
        return Icons.feedback_outlined;
    }
  }

  Color _getCategoryColor(String? category) {
    switch (category) {
      case 'general':
        return AppTheme.primaryColor;
      case 'academic':
        return Colors.blue[700]!;
      case 'facilities':
        return Colors.orange[700]!;
      case 'services':
        return Colors.purple[700]!;
      case 'suggestion':
        return Colors.green[700]!;
      default:
        return AppTheme.primaryColor;
    }
  }
}
