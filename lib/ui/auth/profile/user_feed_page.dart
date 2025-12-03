import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../services/reaction_service.dart';
import '../posts/comments_page.dart';
import '../home/post_card.dart';

class UserFeedPage extends StatelessWidget {
  final String userId;
  final int initialIndex;

  const UserFeedPage({
    super.key,
    required this.userId,
    this.initialIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Publicaciones"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: FirebaseDatabase.instance
            .ref('posts')
            .orderByChild('userId')
            .equalTo(userId)
            .onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(
              child: Text('No hay publicaciones'),
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
              child: PageView.builder(
                controller: PageController(initialPage: initialIndex),
                scrollDirection: Axis.vertical,
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  final postId = post['postId'];

                  return SingleChildScrollView(
                    child: FutureBuilder<DataSnapshot>(
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
                                reactionsSnapshot.data!.snapshot.value !=
                                    null) {
                              final reactions =
                                  reactionsSnapshot.data!.snapshot.value as Map;
                              likesCount = reactions.length;
                              isLiked =
                                  reactions.containsKey(currentUser?.uid);
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
                                    builder: (_) =>
                                        CommentsPage(postId: postId),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
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
