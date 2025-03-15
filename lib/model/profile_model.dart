import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileModel {
  final String? id, uid;
  final Timestamp? createdAt;
  final String firstName, lastName, email, password;
  final int age;

  const ProfileModel({
    this.id,
    this.uid,
    this.createdAt,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.age,
  });

  ProfileModel copyWith({
    String? id,
    String? uid,
    Timestamp? createdAt,
    String? firstName,
    String? lastName,
    String? email,
    String? password,
    int? age,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      uid: uid,
      createdAt: createdAt ?? this.createdAt,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      password: password ?? this.password,
      age: age ?? this.age,
    );
  }

  /// for creating profiles
  toJsonForCreate() {
    return {
      'uid': uid,
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
      uid: data!['uid'],
      firstName: data['first_name'],
      lastName: data['last_name'],
      email: data['email'],
      password: data['password'],
      age: data['age'],
      createdAt: data['created_at'],
    );
  }
}
