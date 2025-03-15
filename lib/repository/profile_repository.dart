import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:midterm_practice/model/profile_model.dart';

class ProfileRepository {
  final _db = FirebaseFirestore.instance;

  Future<void> createProfile(ProfileModel profileModel) async {
    try {
      await _db.collection('Profiles').add(profileModel.toJsonForCreate());
    } catch (error) {
      print('Error creating profile: $error');
      rethrow;
    }
  }

  Future<List<ProfileModel>> getAllProfiles() async {
    final snapshot =
        await _db.collection('Profiles').orderBy('last_name').get();
    final profiles = snapshot.docs.map((p) => ProfileModel.toModel(p)).toList();
    return profiles;
  }

  Future<ProfileModel?> getProfileByEmail(String email) async {
    final snapshot =
        await _db.collection('Profiles').where('email', isEqualTo: email).get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    return ProfileModel.toModel(snapshot.docs.first);
  }

  Future<void> updateProfile(String profileId, Map<String, dynamic> updatedData) async {
    try {
      await _db.collection('Profiles').doc(profileId).update(updatedData);
    } catch (error) {
      print('Error updating profile: $error');
      rethrow;
    }
  }

  Future<void> deleteProfile(String profileId) async {
    try {
      await _db.collection('Profiles').doc(profileId).delete();
    } catch (error) {
      print('Error deleting profile: $error');
      rethrow;
    }
  }
}
