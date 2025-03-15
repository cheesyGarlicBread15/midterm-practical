import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:midterm_practice/model/profile_model.dart';
import 'package:midterm_practice/repository/profile_repository.dart';
import 'package:midterm_practice/services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? _currentUser;
  ProfileModel? _currentProfile;
  bool _isLoading = false;
  final _repository = ProfileRepository();
  List<ProfileModel> _profiles = [];

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _loadProfiles();
    _loadCurrentProfile();
  }

  Future<void> _loadProfiles() async {
    setState(() => _isLoading = true);
    try {
      final profiles = await _repository.getAllProfiles();
      setState(() {
        _profiles = profiles;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading profiles: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadCurrentProfile() async {
    final profile = await _repository.getProfileByEmail(_currentUser!.email!);
    setState(() {
      _currentProfile = profile;
    });
  }

  void _logout() async {
    try {
      setState(() => _isLoading = true);

      final (success, message) = await AuthService().logout();

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully logged out'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, '/');
      } else if (message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error logging out: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showDeleteDialog(ProfileModel profile) {
    final TextEditingController passwordController = TextEditingController();
    bool isPasswordIncorrect = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Delete User'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Are you sure you want to delete ${profile.firstName} ${profile.lastName}?',
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      errorText: isPasswordIncorrect ? 'Incorrect password' : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('CANCEL'),
                ),
                TextButton(
                  onPressed: () async {
                    try {
                      // Authenticate using the target user's credentials
                      UserCredential userCredential = await FirebaseAuth
                          .instance
                          .signInWithEmailAndPassword(
                        email: profile.email, // Target user's email
                        password: passwordController.text, // Entered password
                      );

                      // If sign-in is successful, close dialog and proceed with deletion
                      Navigator.pop(dialogContext, true);
                    } catch (e) {
                      // If authentication fails, show error message
                      setDialogState(() => isPasswordIncorrect = true);
                    }
                  },
                  child:
                      const Text('DELETE', style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        );
      },
    ).then((confirmed) async {
      if (confirmed ?? false) {
        setState(() => _isLoading = true);
        try {
          final auth = FirebaseAuth.instance;
          final firestore = FirebaseFirestore.instance;
          final User? originalUser = auth.currentUser;

          if (originalUser == null)
            throw Exception("No user is currently logged in.");

          final String originalEmail = _currentProfile!.email;
          final String originalPassword = _currentProfile!.password;

          // Sign out the current user
          await auth.signOut();

          // Sign in as the target user to delete
          final UserCredential targetUserCredential =
              await auth.signInWithEmailAndPassword(
            email: profile.email,
            password: passwordController.text,
          );

          final User targetUser = targetUserCredential.user!;

          // Delete profile from Firestore
          await firestore.collection('Profiles').doc(profile.id).delete();

          // Delete user from Firebase Auth
          await targetUser.delete();

          // Sign back in as original user
          await auth.signInWithEmailAndPassword(
            email: originalEmail,
            password: originalPassword,
          );

          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );

          // Refresh profiles list
          await _loadProfiles();
        } catch (e, stackTrace) {
          print(stackTrace);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting user: $e'),
              backgroundColor: Colors.red,
            ),
          );
        } finally {
          if (mounted) {
            setState(() => _isLoading = false);
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profiles'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: Text(
                _currentProfile?.email ?? 'No user',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProfiles,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            Navigator.pushNamed(context, '/register', arguments: true),
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadProfiles,
              child: _profiles.isEmpty
                  ? const Center(child: Text('No profiles found'))
                  : ListView.builder(
                      itemCount: _profiles.length,
                      itemBuilder: (context, index) {
                        final profile = _profiles[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            onTap: () {
                              Navigator.pushNamed(context, '/profile-screen',
                                  arguments: profile);
                            },
                            leading: CircleAvatar(
                              child: Text(profile.firstName[0].toUpperCase()),
                            ),
                            title: Text(
                                '${profile.firstName} ${profile.lastName}'),
                            subtitle: Text(profile.email),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('${profile.age} years'),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _showDeleteDialog(profile),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
