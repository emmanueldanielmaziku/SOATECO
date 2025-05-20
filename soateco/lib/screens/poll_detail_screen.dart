import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_container.dart';

class PollDetailScreen extends StatefulWidget {
  final String pollId;
  final String title;
  final Map<String, dynamic> options;
  final DateTime startDate;
  final DateTime endDate;
  final bool active;
  final bool hasVoted;
  final String? userVote;

  const PollDetailScreen({
    super.key,
    required this.pollId,
    required this.title,
    required this.options,
    required this.startDate,
    required this.endDate,
    required this.active,
    required this.hasVoted,
    this.userVote,
  });

  @override
  State<PollDetailScreen> createState() => _PollDetailScreenState();
}

class _PollDetailScreenState extends State<PollDetailScreen> {
  String? _selectedOption;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedOption = widget.userVote;
  }

  Future<void> _submitVote() async {
    if (_selectedOption == null) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.user!.uid;
      
      // Get current poll data
      final pollDoc = await FirebaseFirestore.instance
          .collection('polls')
          .doc(widget.pollId)
          .get();
      
      if (!pollDoc.exists) {
        throw Exception('Poll not found');
      }
      
      final pollData = pollDoc.data() as Map<String, dynamic>;
      final options = Map<String, dynamic>.from(pollData['options'] as Map<String, dynamic>);
      
      // Initialize userVotes if it doesn't exist
      Map<String, dynamic> userVotes = {};
      if (pollData.containsKey('userVotes') && pollData['userVotes'] != null) {
        userVotes = Map<String, dynamic>.from(pollData['userVotes'] as Map<String, dynamic>);
      }
      
      // If user has already voted, remove their previous vote
      if (userVotes.containsKey(userId)) {
        final previousVote = userVotes[userId];
        if (options.containsKey(previousVote)) {
          options[previousVote] = (options[previousVote] as int) - 1;
        }
      }
      
      // Add new vote
      options[_selectedOption!] = (options[_selectedOption!] as int) + 1;
      userVotes[userId] = _selectedOption;
      
      // Update poll in Firestore
      await FirebaseFirestore.instance.collection('polls').doc(widget.pollId).update({
        'options': options,
        'userVotes': userVotes,
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your vote has been recorded'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        
        // Navigate back to refresh the poll list
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting vote: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate total votes
    int totalVotes = 0;
    widget.options.forEach((option, votes) {
      totalVotes += (votes as int);
    });
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomContainer.gradient(
                      gradient: LinearGradient(
                        colors: [Colors.purple[700]!, Colors.purple[900]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  widget.active ? 'Active Poll' : 'Closed Poll',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Text(
                                '$totalVotes votes',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.title,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: Colors.white.withOpacity(0.9),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${DateFormat('MMM d').format(widget.startDate)} - ${DateFormat('MMM d, yyyy').format(widget.endDate)}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    Text(
                      widget.active ? 'Cast Your Vote' : 'Poll Results',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Poll options
                    ...widget.options.entries.map((entry) {
                      final option = entry.key;
                      final votes = entry.value;
                      final percentage = totalVotes > 0 ? (votes / totalVotes) * 100 : 0.0;
                      final isSelected = _selectedOption == option;
                      final isUserVote = widget.userVote == option;
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: CustomContainer(
                          padding: const EdgeInsets.all(16),
                          backgroundColor: isSelected ? Colors.purple[50] : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? Colors.purple[700]! : Colors.grey[200]!,
                            width: isSelected ? 2 : 1,
                          ),
                          onTap: widget.active && !widget.hasVoted
                              ? () {
                                  setState(() {
                                    _selectedOption = option;
                                  });
                                }
                              : null,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (widget.active && !widget.hasVoted) ...[
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected ? Colors.purple[700]! : Colors.grey[400]!,
                                          width: 2,
                                        ),
                                        color: isSelected ? Colors.purple[700] : Colors.white,
                                      ),
                                      child: isSelected
                                          ? const Icon(
                                              Icons.check,
                                              size: 16,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 12),
                                  ],
                                  Expanded(
                                    child: Text(
                                      option,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: isSelected || isUserVote ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  if (isUserVote)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.purple[100],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Your Vote',
                                        style: TextStyle(
                                          color: Colors.purple[700],
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: percentage / 100,
                                        backgroundColor: Colors.grey[200],
                                        color: Colors.purple[700],
                                        minHeight: 8,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '${percentage.toStringAsFixed(1)}%',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '$votes votes',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    
                    const SizedBox(height: 24),
                    
                    if (widget.active && !widget.hasVoted)
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _selectedOption == null || _isSubmitting ? null : _submitVote,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple[700],
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Submit Vote'),
                        ),
                      ),
                    
                    if (widget.hasVoted)
                      CustomContainer.outlined(
                        borderColor: AppTheme.successColor,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.successColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.check_circle_outline,
                                color: AppTheme.successColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'You have already voted in this poll',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.successColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    if (!widget.active)
                      CustomContainer.outlined(
                        borderColor: Colors.grey[400]!,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.info_outline,
                                color: Colors.grey[700],
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'This poll is now closed',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Poll Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.share,color: Colors.transparent,),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Share functionality coming soon'),
                  backgroundColor: AppTheme.primaryColor,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
