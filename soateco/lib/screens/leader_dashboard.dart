// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:soateco/screens/login_screen.dart';
import '../services/auth_service.dart';
import 'post_news_screen.dart';
import 'send_notification_screen.dart';
import 'voting_polls_screen.dart';
import 'manage_posts_screen.dart';
import 'manage_announcements_screen.dart';
import 'manage_students_screen.dart';
import '../theme/app_theme.dart';
import 'leader_feedback_screen.dart';
import 'leader_create_campaign_screen.dart';
import 'campaign_details_screen.dart';

class LeaderDashboard extends StatefulWidget {
  const LeaderDashboard({super.key});

  @override
  State<LeaderDashboard> createState() => _LeaderDashboardState();
}

class _LeaderDashboardState extends State<LeaderDashboard> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final userId = authService.user?.uid;
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        final shouldPop = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Exit App'),
                content: const Text('Are you sure you want to exit the app?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Exit'),
                  ),
                ],
              ),
            ) ??
            false;

        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        drawer: _buildModernDrawer(authService),
        appBar: _buildModernAppBar(),
        floatingActionButton: _selectedIndex == 5
            ? FloatingActionButton.extended(
                onPressed: () async {
                  final created = await Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const LeaderCreateCampaignScreen()),
                  );
                  if (created == true && mounted) setState(() {});
                },
                icon: const Icon(Icons.add),
                label: const Text('New Campaign'),
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                elevation: 2,
              )
            : null,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildHomeTab(authService),
                    const ManagePostsScreen(),
                    const ManageAnnouncementsScreen(),
                    const ManageStudentsScreen(),
                    _buildProfileTab(authService),
                    _buildCampaignsTab(userId),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(
            Icons.menu,
            color: AppTheme.primaryColor,
          ),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: Text(
        _getAppBarTitle(_selectedIndex),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
      backgroundColor: Colors.white,
      foregroundColor: AppTheme.primaryColor,
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: Colors.grey[200],
        ),
      ),
    );
  }

  Widget _buildModernDrawer(AuthService authService) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Image.asset(
                      'lib/assets/icons/logo.png',
                      width: 32,
                      height: 32,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'SOATECO',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Leader Portal',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildModernDrawerItem(
                  context,
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard,
                  label: 'Dashboard',
                  index: 0,
                ),
                _buildModernDrawerItem(
                  context,
                  icon: Icons.article_outlined,
                  activeIcon: Icons.article,
                  label: 'News',
                  index: 1,
                ),
                _buildModernDrawerItem(
                  context,
                  icon: Icons.campaign_outlined,
                  activeIcon: Icons.campaign,
                  label: 'Announcements',
                  index: 2,
                ),
                _buildModernDrawerItem(
                  context,
                  icon: Icons.people_outlined,
                  activeIcon: Icons.people,
                  label: 'Students',
                  index: 3,
                ),
                _buildModernDrawerItem(
                  context,
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Profile',
                  index: 4,
                ),
                _buildModernDrawerItem(
                  context,
                  icon: Icons.volunteer_activism_outlined,
                  activeIcon: Icons.volunteer_activism,
                  label: 'Campaigns',
                  index: 5,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Divider(),
                ),
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.logout,
                      color: AppTheme.errorColor,
                    ),
                    title: const Text(
                      'Logout',
                      style: TextStyle(
                        color: AppTheme.errorColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () async {
                      await authService.signOut();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernDrawerItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          isSelected ? activeIcon : icon,
          color: isSelected ? AppTheme.primaryColor : Colors.grey[600],
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.primaryColor : Colors.grey[800],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        onTap: () {
          Navigator.pop(context);
          setState(() {
            _selectedIndex = index;
          });
          _pageController.jumpToPage(index);
        },
      ),
    );
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'News';
      case 2:
        return 'Announcements';
      case 3:
        return 'Students';
      case 4:
        return 'Profile';
      case 5:
        return 'Campaigns';
      default:
        return 'SOATECO';
    }
  }

  Widget _buildHomeTab(AuthService authService) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome section - Modern flat design
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 28,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                          future: FirebaseFirestore.instance
                              .collection('users')
                              .doc(authService.user?.uid)
                              .get(),
                          builder: (context, snapshot) {
                            String leaderName = 'Leader';
                            if (snapshot.hasData && snapshot.data!.exists) {
                              leaderName =
                                  snapshot.data!.data()?['name'] ?? 'Leader';
                            }
                            return Text(
                              leaderName,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Stats section - Modern flat design
          Text(
            'Overview',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildModernStatCard(
                  context,
                  'News Posts',
                  Icons.article_outlined,
                  _buildNewsCount(),
                  AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildModernStatCard(
                  context,
                  'Announcements',
                  Icons.campaign_outlined,
                  _buildAnnouncementsCount(),
                  AppTheme.accentColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
          ),

          const SizedBox(height: 16),

          // Dashboard grid - Modern flat design
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
            children: [
              _buildModernActionCard(
                context,
                'Post News',
                Icons.article_outlined,
                'Share important news with students',
                AppTheme.primaryColor,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PostNewsScreen()),
                ),
              ),
              _buildModernActionCard(
                context,
                'Send Announcements',
                Icons.campaign_outlined,
                'Notify specific student groups',
                AppTheme.accentColor,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const SendNotificationScreen()),
                ),
              ),
              _buildModernActionCard(
                context,
                'Voting Polls',
                Icons.how_to_vote_outlined,
                'Create and manage polls',
                Colors.purple[600]!,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const VotingPollsScreen()),
                ),
              ),
              _buildModernActionCard(
                context,
                'Student Feedback',
                Icons.feedback_outlined,
                'Review student suggestions',
                Colors.green[600]!,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const LeaderFeedbackScreen()),
                ),
              ),
              _buildModernActionCard(
                context,
                'Manage Students',
                Icons.people_outlined,
                'Search and promote students',
                Colors.blue[600]!,
                () => _onItemTapped(3),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildModernStatCard(
    BuildContext context,
    String title,
    IconData icon,
    Widget countWidget,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 16),
            countWidget,
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondaryColor,
                    fontWeight: FontWeight.w500,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsCount() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('news')
          .where('authorId',
              isEqualTo:
                  Provider.of<AuthService>(context, listen: false).user?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text(
            '...',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          );
        }

        final count = snapshot.data?.docs.length ?? 0;
        return Text(
          count.toString(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        );
      },
    );
  }

  Widget _buildAnnouncementsCount() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notifications')
          .where('authorId',
              isEqualTo:
                  Provider.of<AuthService>(context, listen: false).user?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text(
            '...',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          );
        }

        final count = snapshot.data?.docs.length ?? 0;
        return Text(
          count.toString(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        );
      },
    );
  }

  Widget _buildModernActionCard(
    BuildContext context,
    String title,
    IconData icon,
    String description,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: color,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondaryColor,
                          height: 1.4,
                        ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileTab(AuthService authService) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(authService.user?.uid)
          .get(),
      builder: (context, snapshot) {
        final userData = snapshot.data?.data() ?? {};
        final name = userData['name'] ?? 'Leader';
        final email =
            userData['email'] ?? authService.user?.email ?? 'Not available';
        final phone = userData['phone'] ?? 'Not available';
        final role = userData['role'] ?? 'Leader';
        final admissionNumber = userData['admissionNumber'] ?? 'Not specified';
        final ntaLevel = userData['ntaLevel'] ?? 'Not specified';
        final course = userData['course'] ?? 'Not specified';
        final createdAt = userData['createdAt'] != null
            ? (userData['createdAt'] is Timestamp
                ? userData['createdAt'].toDate()
                : DateTime.tryParse(userData['createdAt'].toString()) ??
                    DateTime.now())
            : DateTime.now();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[200]!, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        name,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimaryColor,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          role.toUpperCase(),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 24),
                      _buildModernProfileItem(
                          Icons.email_outlined, 'Email', email),
                      _buildModernProfileItem(
                          Icons.phone_outlined, 'Phone', phone),
                      _buildModernProfileItem(
                          Icons.school_outlined, 'Course', course),
                      _buildModernProfileItem(
                          Icons.layers_outlined, 'NTA Level', ntaLevel),
                      _buildModernProfileItem(
                          Icons.confirmation_number_outlined,
                          'Admission Number',
                          admissionNumber),
                      _buildModernProfileItem(
                          Icons.calendar_today_outlined,
                          'Joined',
                          '${createdAt.day}/${createdAt.month}/${createdAt.year}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.errorColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () async {
                      await authService.signOut();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.errorColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.logout,
                              color: AppTheme.errorColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sign Out',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.errorColor,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Log out from your account',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppTheme.textSecondaryColor,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: AppTheme.errorColor,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModernProfileItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryColor,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignsTab(String? userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('contribution_campaigns')
          .where('createdBy', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryColor,
            ),
          );
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.volunteer_activism_outlined,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'No campaigns yet',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textSecondaryColor,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create your first campaign to start fundraising',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
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

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!, width: 1),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CampaignDetailsScreen(campaignId: campaignId),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimaryColor,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: AppTheme.textSecondaryColor,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          description,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.textSecondaryColor,
                                    height: 1.4,
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Progress',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: AppTheme.textSecondaryColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                  Text(
                                    '${(progress * 100).toInt()}%',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: AppTheme.primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 8,
                                  backgroundColor: Colors.grey[200],
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          AppTheme.primaryColor),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Raised: TSh ${current.toStringAsFixed(0)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  Text(
                                    'Goal: TSh ${target.toStringAsFixed(0)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: AppTheme.textSecondaryColor,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today_outlined,
                                    size: 14,
                                    color: AppTheme.textSecondaryColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Deadline: ${deadline.day}/${deadline.month}/${deadline.year}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: AppTheme.textSecondaryColor,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
