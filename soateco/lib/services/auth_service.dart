import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  String _userRole = '';
  bool _isLoading = false;

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
  }

  User? get user => _user;
  String get userRole => _userRole;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  bool get isLeader => _userRole == 'leader';

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
      print('Error loading user role: $e');
      _userRole = '';
      notifyListeners();
    }
  }

  Future<String?> signInWithAdmissionNumberAndPassword(String admissionNumber, String password) async {
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

  Future<String?> registerLeader(String email, String password, String name, String phone, String admissionNumber) async {
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
    }
  }

  Future<String?> registerStudent(String email, String password, String name, String phone, String admissionNumber, String department) async {
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
        'department': department,
        'role': 'student',
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      _isLoading = false;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.message;
    }
  }
}
