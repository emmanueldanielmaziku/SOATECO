import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'post_news_screen.dart';
import 'send_notification_screen.dart';
import 'register_leader_screen.dart';
import 'voting_polls_screen.dart';

class LeaderDashboard extends StatelessWidget {
  const LeaderDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leader Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: const Icon(
                          Icons.person,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            Text(
                              authService.user?.email ?? 'Leader',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Dashboard grid
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildDashboardCard(
                      context,
                      'Post News',
                      Icons.article_outlined,
                      'Share important news with the college community',
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PostNewsScreen()),
                      ),
                    ),
                    _buildDashboardCard(
                      context,
                      'Send Announcements',
                      Icons.campaign_outlined,
                      'Send notifications to specific groups',
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SendNotificationScreen()),
                      ),
                    ),
                    _buildDashboardCard(
                      context,
                      'Register Leaders',
                      Icons.person_add_outlined,
                      'Add new leaders to the system',
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterLeaderScreen()),
                      ),
                    ),
                    _buildDashboardCard(
                      context,
                      'Voting Polls',
                      Icons.how_to_vote_outlined,
                      'Create and manage voting polls',
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const VotingPollsScreen()),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context,
    String title,
    IconData icon,
    String description,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
