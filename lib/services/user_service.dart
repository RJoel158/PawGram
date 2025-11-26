import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UserService {
  static final _db = FirebaseDatabase.instance.ref();
  static final _storage = FirebaseStorage.instance;

  static Future<void> updateProfile({
    required String uid,
    String? name,
    String? bio,
    File? photo,
    List<Map<String, dynamic>>? pets,
  }) async {
    final data = <String, Object?>{};

    if (name != null) data['name'] = name;
    if (bio != null) data['bio'] = bio;
    if (pets != null) data['pets'] = pets;

    if (photo != null) {
      final ref = _storage.ref("users/$uid/profile.jpg");
      await ref.putFile(photo);
      data['photoUrl'] = await ref.getDownloadURL();
    }

    await _db.child("users/$uid").update(data);
  }

  static Stream<DatabaseEvent> userStream(String uid) =>
      _db.child("users/$uid").onValue;
}
