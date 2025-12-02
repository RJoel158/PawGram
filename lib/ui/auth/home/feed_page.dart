import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../services/post_service.dart';
import '../../../services/reaction_service.dart';
import '../posts/comments_page.dart';
import 'post_card.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "PawGram",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
        ),
        actions: [IconButton(icon: const Icon(Icons.pets), onPressed: () {})],
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: PostService.feedStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.pets, size: 80, color: AppColors.softRed),
                  SizedBox(height: 20),
                  Text(
                    'No hay posts todavía',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '¡Crea el primero!',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final postsMap = snapshot.data!.snapshot.value as Map;
          final posts = postsMap.entries.map((e) {
            final data = Map<String, dynamic>.from(e.value as Map);
            data['postId'] = e.key;
            return data;
          }).toList();

          // Ordenar por fecha descendente
          posts.sort(
            (a, b) => (b['createdAt'] ?? 0).compareTo(a['createdAt'] ?? 0),
          );

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  final postId = post['postId'];

                  return FutureBuilder<DataSnapshot>(
                    future: FirebaseDatabase.instance
                        .ref('users/${post['userId']}')
                        .get(),
                    builder: (context, userSnapshot) {
                      if (!userSnapshot.hasData) {
                        return const SizedBox();
                      }

                      final userData = userSnapshot.data!.value as Map?;
                      final username = userData?['username'] ?? 'Usuario';
                      final userPhoto = userData?['photoUrl'] ?? '';

                      return StreamBuilder<DatabaseEvent>(
                        stream: ReactionService.postReactionsStream(postId),
                        builder: (context, reactionsSnapshot) {
                          int likesCount = 0;
                          bool isLiked = false;

                          if (reactionsSnapshot.hasData &&
                              reactionsSnapshot.data!.snapshot.value != null) {
                            final reactions =
                                reactionsSnapshot.data!.snapshot.value as Map;
                            likesCount = reactions.length;
                            isLiked = reactions.containsKey(currentUser?.uid);
                          }

                          return PostCard(
                            username: username,
                            userPhotoUrl: userPhoto,
                            postImageUrl: post['mediaUrl'] ?? '',
                            caption: post['description'] ?? '',
                            likes: likesCount,
                            isLiked: isLiked,
                            onLike: () async {
                              if (currentUser != null) {
                                if (isLiked) {
                                  await ReactionService.removeReaction(
                                    postId: postId,
                                    userId: currentUser.uid,
                                  );
                                } else {
                                  await ReactionService.addReaction(
                                    postId: postId,
                                    userId: currentUser.uid,
                                    type: 'like',
                                  );
                                }
                              }
                            },
                            onComment: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CommentsPage(postId: postId),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
