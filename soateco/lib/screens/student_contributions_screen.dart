import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'campaign_details_screen.dart';

class StudentContributionsScreen extends StatelessWidget {
  const StudentContributionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contributions')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('contribution_campaigns')
            .where('isActive', isEqualTo: true)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No active campaigns.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              final campaignId = docs[i].id;
              final title = data['title'] ?? '';
              final description = data['description'] ?? '';
              final target = (data['targetAmount'] ?? 0).toDouble();
              final current = (data['currentAmount'] ?? 0).toDouble();
              final deadline = (data['deadline'] as Timestamp).toDate();
              final progress =
                  target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CampaignDetailsScreen(campaignId: campaignId),
                      ),
                    );
                  },
                  title: Text(title,
                      style: Theme.of(context).textTheme.titleMedium),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(description,
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(value: progress, minHeight: 8),
                      const SizedBox(height: 6),
                      Text(
                          'Raised:  24${current.toStringAsFixed(2)} /  24${target.toStringAsFixed(2)}'),
                      Text(
                          'Deadline: ${deadline.day}/${deadline.month}/${deadline.year}',
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CampaignDetailsScreen(campaignId: campaignId),
                        ),
                      );
                    },
                    child: const Text('Contribute'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
 