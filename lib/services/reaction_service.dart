import 'package:firebase_database/firebase_database.dart';

class ReactionService {
  static final _db = FirebaseDatabase.instance.ref();

  static Future<void> addReaction({
    required String postId,
    required String userId,
    required String type,
  }) async {
    await _db.child("reactions/$postId/$userId").set(type);
  }

  static Future<void> removeReaction({
    required String postId,
    required String userId,
  }) async {
    await _db.child("reactions/$postId/$userId").remove();
  }

  static Stream<DatabaseEvent> postReactionsStream(String postId) =>
      _db.child("reactions/$postId").onValue;

  static Future<void> react({
    required String postId,
    required String userId,
    required String reaction,
  }) async {
    final ref = _db.child("reactions/$postId/$userId");

    final snap = await ref.get();

    if (snap.exists && snap.value == reaction) {
      await ref.remove();
      await _db
          .child("posts/$postId/reactionsCount/$reaction")
          .set(ServerValue.increment(-1));
      return;
    }

    // Si tenía otra reacción, restarla
    if (snap.exists) {
      final old = snap.value;
      await _db
          .child("posts/$postId/reactionsCount/$old")
          .set(ServerValue.increment(-1));
    }

    // agregar nueva
    await ref.set(reaction);

    await _db
        .child("posts/$postId/reactionsCount/$reaction")
        .set(ServerValue.increment(1));
  }
}
