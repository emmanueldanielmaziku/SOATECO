import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  String _userRole = '';
  bool _isLoading = false;

  // Default admin credentials (configure these as needed)
  static const String _defaultAdminEmail = 'soateco@atc.ac.tz';
  static const String _defaultAdminPassword = 'Admin@1234';
  static const String _defaultAdminName = 'SOATECO Admin';
  static const String _defaultAdminPhone = '1234567890';
  static const String _defaultAdminAdmissionNumber = '21050513029';
  static const String _defaultAdminRole = 'leader';

  AuthService() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      if (user != null) {
        _loadUserRole();
      } else {
        _userRole = '';
      }
      notifyListeners();
    });

    // Initialize default admin when the service is created
    _initializeDefaultAdmin();
  }

  User? get user => _user;
  String get userRole => _userRole;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  bool get isLeader => _userRole == 'leader';

  Future<void> _initializeDefaultAdmin() async {
    try {
      if (kDebugMode) {
        print('Checking for default admin account...');
      }

      // Check if any admin exists (or specifically our default admin)
      final adminQuery = await _firestore
          .collection('users')
          .where('admissionNumber', isEqualTo: _defaultAdminAdmissionNumber)
          .limit(1)
          .get();

      if (adminQuery.docs.isEmpty) {
        if (kDebugMode) {
          print('No default admin found. Creating one...');
        }

        // Create the default admin user
        await _auth.createUserWithEmailAndPassword(
          email: _defaultAdminEmail,
          password: _defaultAdminPassword,
        );

        // Add admin details to Firestore
        await _firestore.collection('users').doc(_auth.currentUser!.uid).set({
          'name': _defaultAdminName,
          'email': _defaultAdminEmail,
          'phone': _defaultAdminPhone,
          'admissionNumber': _defaultAdminAdmissionNumber,
          'role': _defaultAdminRole,
          'createdAt': FieldValue.serverTimestamp(),
          'isDefaultAdmin': true, // Flag to identify default admin
        });

        if (kDebugMode) {
          print('Default admin account created successfully');
          print('Email: $_defaultAdminEmail');
          print('Password: $_defaultAdminPassword');
        }
      } else {
        if (kDebugMode) {
          print('Default admin account already exists');
        }
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Error creating default admin: ${e.message}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error creating default admin: $e');
      }
    }
  }

  Future<void> _loadUserRole() async {
    if (_user == null) return;

    try {
      final doc = await _firestore.collection('users').doc(_user!.uid).get();
      if (doc.exists) {
        _userRole = doc.data()?['role'] ?? '';
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

      if (email == null) {
        _isLoading = false;
        notifyListeners();
        return 'User account is not properly configured';
      }

      // Sign in with email and password
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _loadUserRole();
      _isLoading = false;
      notifyListeners();
      return null;
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
  }

  Future<String?> registerLeader(String email, String password, String name,
      String phone, String admissionNumber) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Create user with email and password
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Add user details to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'admissionNumber': admissionNumber,
        'role': 'leader',
        'createdAt': FieldValue.serverTimestamp(),
      });

      _isLoading = false;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.message;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }
}
