import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cooperative_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/colors.dart';

class CooperativeMembersScreen extends StatefulWidget {
  const CooperativeMembersScreen({super.key});

  @override
  State<CooperativeMembersScreen> createState() => _CooperativeMembersScreenState();
}

class _CooperativeMembersScreenState extends State<CooperativeMembersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedRole = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMembers();
  }

  void _loadMembers() {
    final cooperativeProvider = Provider.of<CooperativeProvider>(context, listen: false);
    cooperativeProvider.fetchMembers();
  }

  @override
  Widget build(BuildContext context) {
    final cooperativeProvider = Provider.of<CooperativeProvider>(context);
    final members = cooperativeProvider.members;
    
    final filteredMembers = members.where((member) {
      if (_searchQuery.isNotEmpty) {
        return member.userName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               member.userEmail.toLowerCase().contains(_searchQuery.toLowerCase());
      }
      return true;
    }).where((member) {
      if (_selectedRole != 'all') {
        return member.role == _selectedRole;
      }
      return true;
    }).toList();

    final adminCount = members.where((m) => m.role == 'admin').length;
    final managerCount = members.where((m) => m.role == 'manager').length;
    final memberCount = members.where((m) => m.role == 'member').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cooperative Members'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Members'),
            Tab(text: 'Requests'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search members...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          // Role Filter Chips
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: const ['all', 'admin', 'manager', 'member'].length,
              itemBuilder: (context, index) {
                final role = const ['all', 'admin', 'manager', 'member'][index];
                final displayName = role == 'all' ? 'All' : role.toUpperCase();
                final count = role == 'all' 
                    ? members.length 
                    : role == 'admin' 
                        ? adminCount 
                        : role == 'manager' 
                            ? managerCount 
                            : memberCount;
                final isSelected = _selectedRole == role;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text('$displayName ($count)'),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedRole = role;
                      });
                    },
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    checkmarkColor: AppColors.primary,
                  ),
                );
              },
            ),
          ),
          
          // Members List
          Expanded(
            child: cooperativeProvider.isLoading
                ? const LoadingWidget()
                : filteredMembers.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () async {
                          await cooperativeProvider.fetchMembers();
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: filteredMembers.length,
                          itemBuilder: (context, index) {
                            final member = filteredMembers[index];
                            return _buildMemberCard(member);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: () {
                _showInviteMemberDialog();
              },
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.person_add),
            )
          : null,
    );
  }

  Widget _buildMemberCard(member) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 30,
              backgroundImage: member.userImage != null
                  ? NetworkImage(member.userImage!)
                  : null,
              child: member.userImage == null
                  ? Text(
                      member.userName[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            
            // Member Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        member.userName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getRoleColor(member.role).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          member.role.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            color: _getRoleColor(member.role),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    member.userEmail,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Joined: ${_formatDate(member.joinedAt)}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            
            // Actions
            PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'promote',
                  child: Text('Promote to Manager'),
                ),
                const PopupMenuItem(
                  value: 'demote',
                  child: Text('Demote to Member'),
                ),
                const PopupMenuItem(
                  value: 'remove',
                  child: Text('Remove Member', style: TextStyle(color: Colors.red)),
                ),
              ],
              onSelected: (value) {
                _handleMemberAction(value, member);
              },
            ),
          ],
        ),
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
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _tabController.index == 0
                ? "No members found"
                : "No pending requests",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _tabController.index == 0
                ? "Invite members to join your cooperative"
                : "Member requests will appear here",
            style: TextStyle(color: Colors.grey.shade500),
          ),
          if (_tabController.index == 0)
            const SizedBox(height: 24),
          if (_tabController.index == 0)
            ElevatedButton(
              onPressed: () {
                _showInviteMemberDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text("Invite Member"),
            ),
        ],
      ),
    );
  }

  void _showInviteMemberDialog() {
    final emailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Invite New Member'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter the email address of the member you want to invite'),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  hintText: 'Email address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              const Text(
                'Role: Member',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (emailController.text.isNotEmpty) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invitation sent successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Send Invite'),
            ),
          ],
        );
      },
    );
  }

  void _handleMemberAction(String action, member) {
    switch (action) {
      case 'promote':
        _showPromoteDialog(member);
        break;
      case 'demote':
        _showDemoteDialog(member);
        break;
      case 'remove':
        _showRemoveDialog(member);
        break;
    }
  }

  void _showPromoteDialog(member) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Promote Member'),
          content: Text('Are you sure you want to promote ${member.userName} to Manager?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Member promoted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Promote'),
            ),
          ],
        );
      },
    );
  }

  void _showDemoteDialog(member) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Demote Member'),
          content: Text('Are you sure you want to demote ${member.userName} to Member?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Member demoted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Demote'),
            ),
          ],
        );
      },
    );
  }

  void _showRemoveDialog(member) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove Member'),
          content: Text('Are you sure you want to remove ${member.userName} from the cooperative?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Member removed successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.red;
      case 'manager':
        return Colors.orange;
      case 'member':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}