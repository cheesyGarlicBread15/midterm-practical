import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileModel {
  final String? id;
  final Timestamp? createdAt;
  final String firstName, lastName, email, password;
  final int age;

  const ProfileModel({
    this.id,
    this.createdAt,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.age,
  });

  /// for creating profiles
  toJsonForCreate() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'password': password,
      'age': age,
      'created_at': Timestamp.now(),
    };
  }

  toJsonForRead() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'password': password,
      'age': age,
      'created_at': createdAt,
    };
  }

  factory ProfileModel.toModel(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    return ProfileModel(
      id: document.id,
      firstName: data!['first_name'],
      lastName: data['last_name'],
      email: data['email'],
      password: data['password'],
      age: data['age'],
      createdAt: data['created_at'],
    );
  }
}