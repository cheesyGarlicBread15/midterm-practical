import 'package:flutter/material.dart';
import 'package:midterm_practice/model/profile_model.dart';
import 'package:midterm_practice/repository/profile_repository.dart';

class ProfileScreen extends StatefulWidget {
  final ProfileModel profileModel;
  const ProfileScreen({super.key, required this.profileModel});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isEditing = false;
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController ageController;
  final ProfileRepository _profileRepository = ProfileRepository();

  @override
  void initState() {
    super.initState();
    firstNameController =
        TextEditingController(text: widget.profileModel.firstName);
    lastNameController =
        TextEditingController(text: widget.profileModel.lastName);
    ageController =
        TextEditingController(text: widget.profileModel.age.toString());
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    ageController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    final updatedData = {
      'first_name': firstNameController.text,
      'last_name': lastNameController.text,
      'age': int.tryParse(ageController.text) ?? widget.profileModel.age,
    };

    try {
      await _profileRepository.updateProfile(
          widget.profileModel.id!, updatedData);
      setState(() {
        isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required Widget valueWidget,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                valueWidget,
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: () {
                setState(() {
                  isEditing = false;
                  firstNameController.text = widget.profileModel.firstName;
                  lastNameController.text = widget.profileModel.lastName;
                  ageController.text = widget.profileModel.age.toString();
                });
              },
            ),
          IconButton(
            icon: Icon(isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              if (isEditing) {
                _updateProfile();
              } else {
                setState(() {
                  isEditing = true;
                });
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(
                widget.profileModel.firstName[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 40,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '${widget.profileModel.firstName} ${widget.profileModel.lastName}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              widget.profileModel.email,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildDetailRow(
                      icon: Icons.person,
                      label: 'First Name',
                      valueWidget: isEditing
                          ? TextField(controller: firstNameController)
                          : Text(firstNameController.text,
                              style: const TextStyle(fontSize: 16)),
                    ),
                    const Divider(),
                    _buildDetailRow(
                      icon: Icons.person_outline,
                      label: 'Last Name',
                      valueWidget: isEditing
                          ? TextField(controller: lastNameController)
                          : Text(lastNameController.text,
                              style: const TextStyle(fontSize: 16)),
                    ),
                    const Divider(),
                    _buildDetailRow(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      valueWidget: Text(widget.profileModel.email,
                          style: const TextStyle(fontSize: 16)),
                    ),
                    const Divider(),
                    _buildDetailRow(
                      icon: Icons.calendar_today,
                      label: 'Age',
                      valueWidget: isEditing
                          ? TextField(
                              controller: ageController,
                              keyboardType: TextInputType.number)
                          : Text('${ageController.text} years',
                              style: const TextStyle(fontSize: 16)),
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
