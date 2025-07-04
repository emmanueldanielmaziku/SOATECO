import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_container.dart';

class StudentLeadersContactScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const StudentLeadersContactScreen({super.key, this.onBack});

  @override
  State<StudentLeadersContactScreen> createState() =>
      _StudentLeadersContactScreenState();
}

class _StudentLeadersContactScreenState
    extends State<StudentLeadersContactScreen> {
  bool _isLoading = true;
  List<UserModel> _leaders = [];

  @override
  void initState() {
    super.initState();
    _loadLeaders();
  }

  Future<void> _loadLeaders() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'leader')
          .orderBy('name')
          .get();

      final leaders = querySnapshot.docs.map((doc) {
        return UserModel.fromMap(doc.data(), doc.id);
      }).toList();

      setState(() {
        _leaders = leaders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading leaders: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not launch phone dialer'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

Future<void> _openWhatsApp(
      BuildContext context, String phoneNumber, String name) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    String formattedPhone = cleanPhone;
    if (!cleanPhone.startsWith('255')) {
      formattedPhone = '255$cleanPhone';
    }

    final message =
        'Hello $name, I am a student from SOATECO. I would like to get in touch with you.';
    final whatsappUrl =
        'https://wa.me/$formattedPhone?text=${Uri.encodeComponent(message)}';

    final Uri whatsappUri = Uri.parse(whatsappUrl);

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not launch WhatsApp'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.primaryColor),
                      ),
                    )
                  : _leaders.isEmpty
                      ? _buildEmptyState()
                      : _buildLeadersList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            onPressed: () {
              if (widget.onBack != null) {
                widget.onBack!();
              } else {
                Navigator.pop(context);
              }
            },
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Contact Leaders',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                '${_leaders.length} leaders available',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLeaders,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: AppTheme.textSecondaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Leaders Found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textSecondaryColor,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'There are currently no leaders registered in the system.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadLeaders,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildLeadersList() {
    return RefreshIndicator(
      onRefresh: _loadLeaders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _leaders.length,
        itemBuilder: (context, index) {
          final leader = _leaders[index];
          return _buildLeaderCard(leader);
        },
      ),
    );
  }

  Widget _buildLeaderCard(UserModel leader) {
    return CustomContainer.card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Leader name and role
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: Text(
                    leader.name.isNotEmpty ? leader.name[0].toUpperCase() : 'L',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        leader.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        'Leader',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),


            if (leader.phone.isNotEmpty) ...[
              _buildContactItem(
                Icons.phone_outlined,
                'Phone',
                leader.phone,
                () => _makePhoneCall(leader.phone),
                Colors.green[700]!,
              ),
              const SizedBox(height: 12),
            ],

            // Action buttons
            Row(
              children: [
                if (leader.phone.isNotEmpty)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _openWhatsApp(context, leader.phone, leader.name),
                      icon: const Icon(Icons.chat_bubble_outline,
                          color: Colors.green),
                      label: const Text('WhatsApp'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.green),
                        foregroundColor: Colors.green,
                      ),
                    ),
                  ),
            
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(
    IconData icon,
    String label,
    String value,
    VoidCallback onTap,
    Color color,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondaryColor,
                          fontWeight: FontWeight.w500,
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
            Icon(
              Icons.arrow_forward_ios,
              color: color,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
