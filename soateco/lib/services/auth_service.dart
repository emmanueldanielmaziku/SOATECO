import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'storage_service.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  String _userRole = '';
  bool _isLoading = false;
  bool _isInitialized = false;

  AuthService() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    // Check if user is logged in from shared preferences
    final isLoggedIn = await StorageService.isLoggedIn();
    final storedRole = await StorageService.getUserRole();
    final storedUserId = await StorageService.getUserId();

    if (isLoggedIn && storedRole != null && storedUserId != null) {
      _userRole = storedRole;
      // Try to get the current Firebase user
      _user = _auth.currentUser;

      // If Firebase user doesn't match stored user, clear storage
      if (_user == null || _user!.uid != storedUserId) {
        await StorageService.clearUserData();
        _userRole = '';
        _user = null;
      }
    }

    _isInitialized = true;
    notifyListeners();

    // Listen to Firebase auth state changes
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      if (user != null) {
        loadUserRole();
      } else {
        _userRole = '';
        // Clear storage when user logs out
        StorageService.clearUserData();
      }
      notifyListeners();
    });
  }

  User? get user => _user;
  String get userRole => _userRole;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  bool get isLeader => _userRole == 'leader';
  bool get isInitialized => _isInitialized;

  // Fetch user document from Firestore
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDocument() async {
    if (_user == null) {
      throw Exception('User is not authenticated');
    }
    final userDoc = await _firestore.collection('users').doc(_user!.uid).get();
    if (userDoc.exists) {
      final email = userDoc.data()?['email'];
      if (email != null) {
        return userDoc;
      } else {
        throw Exception('Email not found for the authenticated user');
      }
    } else {
      throw Exception('User document does not exist');
    }
  }

  Future<void> loadUserRole() async {
    if (_user == null) return;

    try {
      final doc = await _firestore.collection('users').doc(_user!.uid).get();
      if (doc.exists) {
        final role = doc.data()?['role'] ?? '';
        _userRole = role;

        // Save to shared preferences
        await StorageService.saveUserData(
          userId: _user!.uid,
          email: _user!.email ?? '',
          role: role,
          admissionNumber: doc.data()?['admissionNumber'] ?? '',
        );
      } else {
        _userRole = '';
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading user role: $e');
      }
      _userRole = '';
      notifyListeners();
    }
  }

  Future<String?> signInWithAdmissionNumberAndPassword(
      String admissionNumber, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Query Firestore to find a user with matching admission number
      final querySnapshot = await _firestore
          .collection('users')
          .where('admissionNumber', isEqualTo: admissionNumber)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        _isLoading = false;
        notifyListeners();
        return 'No user found with this admission number';
      }

      final userDoc = querySnapshot.docs.first;
      final email = userDoc.data()['email'];
      final role = userDoc.data()['role'];
      if (kDebugMode) print('Fetched role: $role');

      if (email == null || role == null) {
        _isLoading = false;
        notifyListeners();
        return 'User account is not properly configured';
      }

      // Sign in with email and password
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Set the user role directly
      _userRole = role;

      // Save to shared preferences
      await StorageService.saveUserData(
        userId: _auth.currentUser!.uid,
        email: email,
        role: role,
        admissionNumber: admissionNumber,
      );

      _isLoading = false;
      notifyListeners();

      // Return the user role for further use
      return _userRole;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();

      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        return 'Invalid admission number or password';
      }
      return e.message;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    // Clear user role and storage
    _userRole = '';
    await StorageService.clearUserData();
    notifyListeners();
  }

  // New registration method for students with NTA level and course
  Future<String?> registerStudent({
    required String fullName,
    required String admissionNumber,
    required String ntaLevel,
    required String course,
    required String password,
    required String phone,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Check if admission number already exists
      final existingUser = await _firestore
          .collection('users')
          .where('admissionNumber', isEqualTo: admissionNumber)
          .limit(1)
          .get();

      if (existingUser.docs.isNotEmpty) {
        _isLoading = false;
        notifyListeners();
        return 'Admission number already exists';
      }

      // Generate email from admission number
      final email = '$admissionNumber@soateco.ac.tz';

      // Create user with email and password
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Add user details to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'id': userCredential.user!.uid,
        'name': fullName,
        'email': email,
        'phone': phone,
        'admissionNumber': admissionNumber,
        'ntaLevel': ntaLevel,
        'course': course,
        'role': 'student', // Default role is student
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Save to shared preferences
      await StorageService.saveUserData(
        userId: userCredential.user!.uid,
        email: email,
        role: 'student',
        admissionNumber: admissionNumber,
      );

      _isLoading = false;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      if (e.code == 'weak-password') {
        return 'Password is too weak. Please use a stronger password.';
      } else if (e.code == 'email-already-in-use') {
        return 'An account with this admission number already exists.';
      }
      return e.message;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }

  // Updated leader registration method
  Future<String?> registerLeader({
    required String fullName,
    required String admissionNumber,
    required String password,
    required String phone,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Check if admission number already exists
      final existingUser = await _firestore
          .collection('users')
          .where('admissionNumber', isEqualTo: admissionNumber)
          .limit(1)
          .get();

      if (existingUser.docs.isNotEmpty) {
        _isLoading = false;
        notifyListeners();
        return 'Admission number already exists';
      }

      // Generate email from admission number
      final email = '$admissionNumber@soateco.ac.tz';

      // Create user with email and password
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Add user details to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'id': userCredential.user!.uid,
        'name': fullName,
        'email': email,
        'phone': phone,
        'admissionNumber': admissionNumber,
        'role': 'leader',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Save to shared preferences
      await StorageService.saveUserData(
        userId: userCredential.user!.uid,
        email: email,
        role: 'leader',
        admissionNumber: admissionNumber,
      );

      _isLoading = false;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      if (e.code == 'weak-password') {
        return 'Password is too weak. Please use a stronger password.';
      } else if (e.code == 'email-already-in-use') {
        return 'An account with this admission number already exists.';
      }
      return e.message;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }

  // Method to promote a student to leader (only for existing leaders)
  Future<String?> promoteStudentToLeader(String studentAdmissionNumber) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Check if current user is a leader
      if (_userRole != 'leader') {
        _isLoading = false;
        notifyListeners();
        return 'Only leaders can promote students';
      }

      // Find the student by admission number
      final querySnapshot = await _firestore
          .collection('users')
          .where('admissionNumber', isEqualTo: studentAdmissionNumber)
          .where('role', isEqualTo: 'student')
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        _isLoading = false;
        notifyListeners();
        return 'Student not found with this admission number';
      }

      final studentDoc = querySnapshot.docs.first;
      final studentId = studentDoc.id;

      // Update the student's role to leader
      await _firestore.collection('users').doc(studentId).update({
        'role': 'leader',
        'promotedBy': _user!.uid,
        'promotedAt': FieldValue.serverTimestamp(),
      });

      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }

  // Method to search for students
  Future<List<Map<String, dynamic>>> searchStudents(String query) async {
    try {
      // Check if current user is a leader
      if (_userRole != 'leader') {
        return [];
      }

      // Search for students by name or admission number
      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'student')
          .get();

      final students = querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .where((student) =>
              student['name']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              student['admissionNumber']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()))
          .toList();

      return students;
    } catch (e) {
      return [];
    }
  }

  // Legacy methods for backward compatibility
  Future<String?> registerStudentLegacy(
      String email,
      String password,
      String name,
      String phone,
      String admissionNumber,
      String department) async {
    return registerStudent(
      fullName: name,
      admissionNumber: admissionNumber,
      ntaLevel: 'NTA Level 4', // Default value
      course: department,
      password: password,
      phone: phone,
    );
  }
}
