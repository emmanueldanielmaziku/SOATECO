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

  Future<String?> signInWithEmailAndPassword(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      
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
      return e.message;
    }
  }

  Future<String?> signInWithPhoneAndAdmissionNumber(String phone, String admissionNumber) async {
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
      
      // This is a simplified version. In a real app, you would implement
      // phone verification with SMS code
      final userDoc = querySnapshot.docs.first;
      if (userDoc.data()['phone'] != phone) {
        _isLoading = false;
        notifyListeners();
        return 'Phone number does not match records';
      }
      
      // Manually set the user and role for demonstration
      // In a real app, you would use proper Firebase Auth phone verification
      _user = await _auth.signInAnonymously().then((result) => result.user);
      _userRole = userDoc.data()['role'] ?? '';
      
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<String?> registerLeader(String email, String password, String name, String phone) async {
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
}
