import 'package:flutter/material.dart';
import '../models/cooperative_model.dart';

class CooperativeProvider extends ChangeNotifier {
  List<CooperativeModel> _cooperatives = [];
  CooperativeModel? _currentCooperative;
  List<CooperativeMemberModel> _members = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<CooperativeModel> get cooperatives => _cooperatives;
  CooperativeModel? get currentCooperative => _currentCooperative;
  List<CooperativeMemberModel> get members => _members;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  CooperativeProvider() {
    _loadMockData();
  }

  void _loadMockData() {
    _cooperatives = [
      CooperativeModel(
        id: 'coop1',
        name: 'Farmers United Cooperative',
        description: 'A collective of local farmers working together to provide fresh, organic produce. We support sustainable farming practices and fair trade.',
        logo: 'https://via.placeholder.com/150',
        coverImage: 'https://via.placeholder.com/800x300',
        address: '123 Cooperative Lane',
        city: 'Springfield',
        state: 'IL',
        phone: '+1-555-0123',
        email: 'info@farmersunited.com',
        website: 'www.farmersunited.com',
        memberCount: 150,
        productCount: 500,
        rating: 4.8,
        isVerified: true,
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        categories: ['Vegetables', 'Fruits', 'Grains', 'Dairy'],
        adminId: 'admin1',
      ),
      CooperativeModel(
        id: 'coop2',
        name: 'Organic Valley Co-op',
        description: 'Dedicated to organic farming and sustainable agriculture. We provide certified organic products directly from our member farms.',
        logo: 'https://via.placeholder.com/150',
        coverImage: 'https://via.placeholder.com/800x300',
        address: '456 Organic Road',
        city: 'Eco City',
        state: 'CA',
        phone: '+1-555-0456',
        email: 'hello@organicvalley.com',
        website: 'www.organicvalley.com',
        memberCount: 89,
        productCount: 250,
        rating: 4.9,
        isVerified: true,
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
        categories: ['Vegetables', 'Fruits', 'Organic'],
        adminId: 'admin2',
      ),
      CooperativeModel(
        id: 'coop3',
        name: 'Local Harvest Co-op',
        description: 'Connecting local farmers with community buyers for fresh, seasonal produce.',
        logo: 'https://via.placeholder.com/150',
        coverImage: 'https://via.placeholder.com/800x300',
        address: '789 Harvest Street',
        city: 'Farmville',
        state: 'TX',
        phone: '+1-555-0789',
        email: 'contact@localharvest.com',
        website: 'www.localharvest.com',
        memberCount: 45,
        productCount: 120,
        rating: 4.5,
        isVerified: false,
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        categories: ['Vegetables', 'Fruits'],
        adminId: 'admin3',
      ),
    ];

    _members = [
      CooperativeMemberModel(
        id: 'member1',
        cooperativeId: 'coop1',
        userId: 'farmer1',
        userName: 'John Farmer',
        userEmail: 'john@example.com',
        userImage: 'https://via.placeholder.com/100',
        role: 'admin',
        joinedAt: DateTime.now().subtract(const Duration(days: 365)),
        isActive: true,
      ),
      CooperativeMemberModel(
        id: 'member2',
        cooperativeId: 'coop1',
        userId: 'farmer2',
        userName: 'Jane Smith',
        userEmail: 'jane@example.com',
        userImage: 'https://via.placeholder.com/100',
        role: 'manager',
        joinedAt: DateTime.now().subtract(const Duration(days: 200)),
        isActive: true,
      ),
      CooperativeMemberModel(
        id: 'member3',
        cooperativeId: 'coop1',
        userId: 'farmer3',
        userName: 'Bob Johnson',
        userEmail: 'bob@example.com',
        userImage: 'https://via.placeholder.com/100',
        role: 'member',
        joinedAt: DateTime.now().subtract(const Duration(days: 150)),
        isActive: true,
      ),
      CooperativeMemberModel(
        id: 'member4',
        cooperativeId: 'coop2',
        userId: 'farmer4',
        userName: 'Alice Brown',
        userEmail: 'alice@example.com',
        userImage: 'https://via.placeholder.com/100',
        role: 'admin',
        joinedAt: DateTime.now().subtract(const Duration(days: 180)),
        isActive: true,
      ),
    ];
  }

  // Fetch all cooperatives - FIXED METHOD
  Future<void> fetchCooperatives() async {
    _isLoading = true;
    notifyListeners();
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    _isLoading = false;
    notifyListeners();
  }

  // Fetch current user's cooperative
  Future<void> fetchCurrentCooperative() async {
    _isLoading = true;
    notifyListeners();
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    // For demo, set first cooperative as current
    if (_cooperatives.isNotEmpty) {
      _currentCooperative = _cooperatives.first;
    }
    
    _isLoading = false;
    notifyListeners();
  }

  // Fetch cooperative by ID
  Future<void> fetchCooperativeById(String cooperativeId) async {
    _isLoading = true;
    notifyListeners();
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    try {
      _currentCooperative = _cooperatives.firstWhere((c) => c.id == cooperativeId);
    } catch (e) {
      _errorMessage = 'Cooperative not found';
    }
    
    _isLoading = false;
    notifyListeners();
  }

  // Fetch members of a cooperative
  Future<void> fetchMembers({String? cooperativeId}) async {
    _isLoading = true;
    notifyListeners();
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    final coopId = cooperativeId ?? _currentCooperative?.id;
    if (coopId != null) {
      _members = _members.where((m) => m.cooperativeId == coopId).toList();
    }
    
    _isLoading = false;
    notifyListeners();
  }

  // Join a cooperative
  Future<bool> joinCooperative(String cooperativeId) async {
    _isLoading = true;
    notifyListeners();
    
    await Future.delayed(const Duration(seconds: 1));
    
    // Check if already a member
    final alreadyMember = _members.any((m) => m.cooperativeId == cooperativeId);
    if (alreadyMember) {
      _errorMessage = 'You are already a member of this cooperative';
      _isLoading = false;
      notifyListeners();
      return false;
    }
    
    // Add as pending member (in real app, would need approval)
    _isLoading = false;
    notifyListeners();
    return true;
  }

  // Leave a cooperative
  Future<bool> leaveCooperative(String cooperativeId) async {
    _isLoading = true;
    notifyListeners();
    
    await Future.delayed(const Duration(seconds: 1));
    
    _members.removeWhere((m) => m.cooperativeId == cooperativeId && m.userId == 'currentUser');
    
    if (_currentCooperative?.id == cooperativeId) {
      _currentCooperative = null;
    }
    
    _isLoading = false;
    notifyListeners();
    return true;
  }

  // Add member to cooperative (for admins)
  Future<bool> addMember(String cooperativeId, String userId, String userEmail, String userName) async {
    _isLoading = true;
    notifyListeners();
    
    await Future.delayed(const Duration(seconds: 1));
    
    final newMember = CooperativeMemberModel(
      id: 'member_${DateTime.now().millisecondsSinceEpoch}',
      cooperativeId: cooperativeId,
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      role: 'member',
      joinedAt: DateTime.now(),
      isActive: true,
    );
    
    _members.add(newMember);
    
    // Update member count in cooperative
    final coopIndex = _cooperatives.indexWhere((c) => c.id == cooperativeId);
    if (coopIndex != -1) {
      final coop = _cooperatives[coopIndex];
      _cooperatives[coopIndex] = CooperativeModel(
        id: coop.id,
        name: coop.name,
        description: coop.description,
        logo: coop.logo,
        coverImage: coop.coverImage,
        address: coop.address,
        city: coop.city,
        state: coop.state,
        phone: coop.phone,
        email: coop.email,
        website: coop.website,
        memberCount: coop.memberCount + 1,
        productCount: coop.productCount,
        rating: coop.rating,
        isVerified: coop.isVerified,
        createdAt: coop.createdAt,
        categories: coop.categories,
        adminId: coop.adminId,
      );
    }
    
    _isLoading = false;
    notifyListeners();
    return true;
  }

  // Remove member from cooperative
  Future<bool> removeMember(String memberId) async {
    _isLoading = true;
    notifyListeners();
    
    await Future.delayed(const Duration(seconds: 1));
    
    final member = _members.firstWhere((m) => m.id == memberId);
    _members.removeWhere((m) => m.id == memberId);
    
    // Update member count
    final coopIndex = _cooperatives.indexWhere((c) => c.id == member.cooperativeId);
    if (coopIndex != -1) {
      final coop = _cooperatives[coopIndex];
      _cooperatives[coopIndex] = CooperativeModel(
        id: coop.id,
        name: coop.name,
        description: coop.description,
        logo: coop.logo,
        coverImage: coop.coverImage,
        address: coop.address,
        city: coop.city,
        state: coop.state,
        phone: coop.phone,
        email: coop.email,
        website: coop.website,
        memberCount: coop.memberCount - 1,
        productCount: coop.productCount,
        rating: coop.rating,
        isVerified: coop.isVerified,
        createdAt: coop.createdAt,
        categories: coop.categories,
        adminId: coop.adminId,
      );
    }
    
    _isLoading = false;
    notifyListeners();
    return true;
  }

  // Update member role
  Future<bool> updateMemberRole(String memberId, String newRole) async {
    _isLoading = true;
    notifyListeners();
    
    await Future.delayed(const Duration(seconds: 1));
    
    final index = _members.indexWhere((m) => m.id == memberId);
    if (index != -1) {
      final member = _members[index];
      _members[index] = CooperativeMemberModel(
        id: member.id,
        cooperativeId: member.cooperativeId,
        userId: member.userId,
        userName: member.userName,
        userEmail: member.userEmail,
        userImage: member.userImage,
        role: newRole,
        joinedAt: member.joinedAt,
        isActive: member.isActive,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    }
    
    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Search cooperatives
  Future<List<CooperativeModel>> searchCooperatives(String query) async {
    _isLoading = true;
    notifyListeners();
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    final results = _cooperatives.where((c) =>
      c.name.toLowerCase().contains(query.toLowerCase()) ||
      c.description.toLowerCase().contains(query.toLowerCase()) ||
      c.city.toLowerCase().contains(query.toLowerCase())
    ).toList();
    
    _isLoading = false;
    notifyListeners();
    return results;
  }

  // Get cooperatives by category
  List<CooperativeModel> getCooperativesByCategory(String category) {
    return _cooperatives.where((c) => 
      c.categories.contains(category)
    ).toList();
  }

  // Get top rated cooperatives
  List<CooperativeModel> getTopRatedCooperatives({int limit = 5}) {
    final sorted = List<CooperativeModel>.from(_cooperatives);
    sorted.sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.take(limit).toList();
  }

  // Get cooperative statistics
  Map<String, dynamic> getCooperativeStatistics(String cooperativeId) {
    final cooperative = _cooperatives.firstWhere((c) => c.id == cooperativeId);
    final coopMembers = _members.where((m) => m.cooperativeId == cooperativeId).toList();
    
    return {
      'totalMembers': cooperative.memberCount,
      'totalProducts': cooperative.productCount,
      'activeMembers': coopMembers.where((m) => m.isActive).length,
      'admins': coopMembers.where((m) => m.role == 'admin').length,
      'managers': coopMembers.where((m) => m.role == 'manager').length,
      'regularMembers': coopMembers.where((m) => m.role == 'member').length,
      'rating': cooperative.rating,
      'isVerified': cooperative.isVerified,
    };
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Reset provider (for logout)
  void reset() {
    _cooperatives = [];
    _currentCooperative = null;
    _members = [];
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}