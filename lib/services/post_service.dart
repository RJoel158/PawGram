import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class PostService {
  static final _db = FirebaseDatabase.instance.ref();
  static final _storage = FirebaseStorage.instance;
  static final _uuid = Uuid();

  static Future<String> uploadMedia(File file, String ext) async {
    final id = _uuid.v4();
    final ref = _storage.ref("posts/$id.$ext");
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  static Future<void> createPost({
    required String userId,
    required String description,
    required String mediaUrl,
    required String mediaType,
  }) async {
    final id = _uuid.v4();

    await _db.child("posts/$id").set({
      "postId": id,
      "userId": userId,
      "description": description,
      "mediaUrl": mediaUrl,
      "mediaType": mediaType,
      "createdAt": DateTime.now().millisecondsSinceEpoch,
      "reactionsCount": {
        "like": 0,
        "love": 0,
        "wow": 0,
      }
    });
  }

  static Stream<DatabaseEvent> feedStream() =>
      _db.child("posts").orderByChild("createdAt").onValue;

  static Future<void> deletePost(String postId) =>
      _db.child("posts/$postId").remove();
}
