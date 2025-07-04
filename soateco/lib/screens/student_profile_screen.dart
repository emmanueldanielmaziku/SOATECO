// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:soateco/screens/login_screen.dart';
import 'package:soateco/screens/student_feedback_screen.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_container.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                future: authService.getUserDocument(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(
                      child: Text('User data not found'),
                    );
                  }

                  final userData = snapshot.data!.data() ?? {};

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile header
                        CustomContainer.gradient(
                          width: double.infinity,
                          gradient: const LinearGradient(
                            colors: [
                              AppTheme.primaryColor,
                              AppTheme.primaryDarkColor
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          child: Column(
                            children: [
                              const CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.person,
                                  size: 50,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                userData['name'] ?? 'Student',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                userData['email'] ??
                                    authService.user?.email ??
                                    'No email',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  userData['role']?.toUpperCase() ?? 'STUDENT',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Additional profile information
                        Text(
                          'Personal Information',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 16),
                        CustomContainer.card(
                          child: Column(
                            children: [
                              _buildInfoItem(
                                context,
                                'Admission Number',
                                userData['admissionNumber'] ?? 'Not available',
                                Icons.badge_outlined,
                              ),
                              const Divider(),
                              _buildInfoItem(
                                context,
                                'Phone Number',
                                userData['phone'] ?? 'Not available',
                                Icons.phone_outlined,
                              ),
                              const Divider(),
                              _buildInfoItem(
                                context,
                                'Email',
                                userData['email'] ??
                                    authService.user?.email ??
                                    'Not available',
                                Icons.email_outlined,
                              ),
                              const Divider(),
                              _buildInfoItem(
                                context,
                                'NTA Level',
                                userData['ntaLevel'] ?? 'Not specified',
                                Icons.school_outlined,
                              ),
                              const Divider(),
                              _buildInfoItem(
                                context,
                                'Course',
                                userData['course'] ?? 'Not specified',
                                Icons.book_outlined,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

// Feedback redirection widget
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const StudentFeedbackScreen(),
                              ),
                            );
                          },
                          child: CustomContainer.card(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color:
                                        AppTheme.primaryColor.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.feedback_outlined,
                                    color: AppTheme.primaryColor,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Send Feedback or Suggestions',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'We value your feedback! Tap here to share your thoughts.',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color:
                                                  AppTheme.textSecondaryColor,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  color: AppTheme.textSecondaryColor,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Logout button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () async {
                              await authService.signOut();
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                                (route) => false,
                              );
                            },
                            child: const Text('Logout'),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildInfoItem(
      BuildContext context, String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
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
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
