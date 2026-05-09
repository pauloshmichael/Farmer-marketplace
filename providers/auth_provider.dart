import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  UserModel? _currentUser;
  String? _errorMessage;
  String? _token;
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool get isLoading => _isLoading;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  String? get token => _token;
  bool get isAuthenticated => _currentUser != null;
  String get userRole => _currentUser?.role ?? 'buyer';

  AuthProvider() {
    _checkAuthState();
  }

  void _checkAuthState() {
    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        await _loadUserData(user.uid);
        _token = await user.getIdToken();
      } else {
        _currentUser = null;
        _token = null;
        notifyListeners();
      }
    });
  }

  Future<void> _loadUserData(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        _currentUser = UserModel.fromJson(doc.data() as Map<String, dynamic>);
        notifyListeners();
      }
    } catch (e) {
      print('Error loading user: $e');
    }
  }

  // LOGIN
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      _token = await userCredential.user!.getIdToken();
      await _loadUserData(userCredential.user!.uid);
      
      _isLoading = false;
      notifyListeners();
      return true;
      
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getAuthErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An error occurred. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // REGISTER
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String role,
    required String phone,
    required String address,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      _token = await userCredential.user!.getIdToken();
      
      final user = UserModel(
        id: userCredential.user!.uid,
        name: name,
        email: email,
        role: role,
        phone: phone,
        address: address,
        createdAt: DateTime.now(),
        isVerified: false,
      );
      
      await _firestore.collection('users').doc(user.id).set(user.toJson());
      
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
      
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getAuthErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Registration failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ✅✅✅ RESET PASSWORD - WORKING VERSION ✅✅✅
  Future<bool> resetPassword({required String email}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // This sends the actual password reset email
      await _auth.sendPasswordResetEmail(email: email.trim());
      
      _isLoading = false;
      notifyListeners();
      print('✅ Password reset email sent to: $email');
      return true;
      
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase error: ${e.code} - ${e.message}');
      _errorMessage = _getAuthErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('❌ General error: $e');
      _errorMessage = 'An error occurred. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // CHANGE PASSWORD
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        _errorMessage = 'User not logged in';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      
      _isLoading = false;
      notifyListeners();
      return true;
      
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getAuthErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An error occurred. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // UPDATE PROFILE
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? address,
    String? profileImage,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user == null || _currentUser == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (phone != null) updateData['phone'] = phone;
      if (address != null) updateData['address'] = address;
      if (profileImage != null) updateData['profileImage'] = profileImage;
      updateData['updatedAt'] = FieldValue.serverTimestamp();
      
      await _firestore.collection('users').doc(user.uid).update(updateData);
      
      _currentUser = _currentUser!.copyWith(
        name: name ?? _currentUser!.name,
        phone: phone ?? _currentUser!.phone,
        address: address ?? _currentUser!.address,
        profileImage: profileImage ?? _currentUser!.profileImage,
      );
      
      _isLoading = false;
      notifyListeners();
      return true;
      
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    _token = null;
    _errorMessage = null;
    notifyListeners();
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email. Please sign up first.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}