import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:midterm_practice/model/profile_model.dart';

class ProfileRepository {
  final _db = FirebaseFirestore.instance;

  Future<void> createProfile(ProfileModel profileModel) async {
    try {
      await _db
          .collection('Profiles')
          .add(profileModel.toJsonForCreate());
    } catch (error) {
      print('Error creating profile: $error');
      rethrow; // Rethrow to handle in AuthService
    }
  }

  Future<List<ProfileModel>> getAllProfiles() async {
    final snapshot = await _db.collection('Profiles').orderBy('last_name').get();
    final profiles = snapshot.docs.map((p) => ProfileModel.toModel(p)).toList();
    return profiles;
  }
}