import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';

class CommentService {
  static final _db = FirebaseDatabase.instance.ref();
  static final _uuid = Uuid();

  static Future<void> addComment({
    required String postId,
    required String userId,
    required String text,
    String? parentId,
  }) async {
    final id = _uuid.v4();
    await _db.child("comments/$postId/$id").set({
      "commentId": id,
      "userId": userId,
      "text": text,
      "parentId": parentId,
      "createdAt": DateTime.now().millisecondsSinceEpoch,
    });
  }

  static Stream<DatabaseEvent> getCommentsStream(String postId) =>
      _db.child("comments/$postId").onValue;

  static Stream<DatabaseEvent> commentsStream(String postId) =>
      _db.child("comments/$postId").onValue;
}
