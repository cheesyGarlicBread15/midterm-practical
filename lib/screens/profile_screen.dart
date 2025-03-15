import 'package:flutter/material.dart';
import 'package:midterm_practice/model/profile_model.dart';

class ProfileScreen extends StatelessWidget {
  final ProfileModel profileModel;
  const ProfileScreen({super.key, required this.profileModel});

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
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
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Profile Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(
                profileModel.firstName[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 40,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Full Name
            Text(
              '${profileModel.firstName} ${profileModel.lastName}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            // Email
            Text(
              profileModel.email,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 32),
            // Details Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildDetailRow(
                      icon: Icons.person,
                      label: 'First Name',
                      value: profileModel.firstName,
                    ),
                    const Divider(),
                    _buildDetailRow(
                      icon: Icons.person_outline,
                      label: 'Last Name',
                      value: profileModel.lastName,
                    ),
                    const Divider(),
                    _buildDetailRow(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: profileModel.email,
                    ),
                    const Divider(),
                    _buildDetailRow(
                      icon: Icons.calendar_today,
                      label: 'Age',
                      value: '${profileModel.age} years',
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
