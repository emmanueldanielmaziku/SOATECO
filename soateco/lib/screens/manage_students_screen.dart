import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_container.dart';

class ManageStudentsScreen extends StatefulWidget {
  const ManageStudentsScreen({super.key});

  @override
  State<ManageStudentsScreen> createState() => _ManageStudentsScreenState();
}

class _ManageStudentsScreenState extends State<ManageStudentsScreen> {
  final _searchController = TextEditingController();
  final _promoteController = TextEditingController();
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _filteredStudents = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _promoteController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    final students = await authService.searchStudents('');

    setState(() {
      _students = students;
      _filteredStudents = students;
      _isLoading = false;
    });
  }

  void _searchStudents(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredStudents = _students;
      } else {
        _filteredStudents = _students.where((student) {
          final name = student['name'].toString().toLowerCase();
          final admissionNumber =
              student['admissionNumber'].toString().toLowerCase();
          final searchQuery = query.toLowerCase();
          return name.contains(searchQuery) ||
              admissionNumber.contains(searchQuery);
        }).toList();
      }
    });
  }

  Future<void> _promoteStudent(String admissionNumber) async {
    if (admissionNumber.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter an admission number';
      });
      return;
    }

    final authService = Provider.of<AuthService>(context, listen: false);
    final error =
        await authService.promoteStudentToLeader(admissionNumber.trim());

    if (error != null) {
      setState(() {
        _errorMessage = error;
        _successMessage = null;
      });
    } else {
      setState(() {
        _successMessage = 'Student promoted to leader successfully!';
        _errorMessage = null;
      });
      _promoteController.clear();
      _loadStudents(); // Refresh the list
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search section
                    Text(
                      'Search Students',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by name or admission number...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _searchStudents('');
                          },
                        ),
                      ),
                      onChanged: _searchStudents,
                    ),

                    const SizedBox(height: 24),

                    // Promote section
                    Text(
                      'Promote Student to Leader',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    CustomContainer.card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Enter Admission Number',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _promoteController,
                                    decoration: const InputDecoration(
                                      hintText: 'Admission number',
                                      prefixIcon: Icon(Icons.badge_outlined),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: () =>
                                      _promoteStudent(_promoteController.text),
                                  child: const Text('Promote'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Messages
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red[300]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline,
                                color: Colors.red[700], size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(color: Colors.red[700]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    if (_successMessage != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green[300]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_outline,
                                color: Colors.green[700], size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _successMessage!,
                                style: TextStyle(color: Colors.green[700]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Students list
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Students (${_filteredStudents.length})',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: _loadStudents,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _filteredStudents.isEmpty
                              ? const Center(
                                  child: Text('No students found'),
                                )
                              : ListView.builder(
                                  itemCount: _filteredStudents.length,
                                  itemBuilder: (context, index) {
                                    final student = _filteredStudents[index];
                                    return CustomContainer.card(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: AppTheme.primaryColor
                                              .withOpacity(0.1),
                                          child: Text(
                                            student['name']?[0]
                                                    ?.toUpperCase() ??
                                                'S',
                                            style: const TextStyle(
                                              color: AppTheme.primaryColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          student['name'] ?? 'Unknown',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Admission: ${student['admissionNumber'] ?? 'N/A'}',
                                              style:
                                                  const TextStyle(fontSize: 12),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              'Course: ${student['course'] ?? 'N/A'}',
                                              style:
                                                  const TextStyle(fontSize: 12),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              'NTA Level: ${student['ntaLevel'] ?? 'N/A'}',
                                              style:
                                                  const TextStyle(fontSize: 12),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.person_add),
                                          onPressed: () {
                                            _promoteController.text =
                                                student['admissionNumber'] ??
                                                    '';
                                            _promoteStudent(
                                                student['admissionNumber'] ??
                                                    '');
                                          },
                                          tooltip: 'Promote to Leader',
                                        ),
                                      ),
                                    );
                                  },
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

}
