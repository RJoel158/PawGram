import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../services/comments_service.dart';

class CommentsPage extends StatefulWidget {
  final String postId;

  const CommentsPage({super.key, required this.postId});

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final _commentController = TextEditingController();
  final _currentUser = FirebaseAuth.instance.currentUser;

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty || _currentUser == null) return;

    await CommentService.addComment(
      postId: widget.postId,
      userId: _currentUser.uid,
      text: _commentController.text.trim(),
    );

    _commentController.clear();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Comments")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: CommentService.commentsStream(widget.postId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData ||
                    snapshot.data!.snapshot.value == null) {
                  return const Center(
                    child: Text('No hay comentarios todavía'),
                  );
                }

                final commentsMap = snapshot.data!.snapshot.value as Map;
                final comments = commentsMap.entries.map((e) {
                  final data = Map<String, dynamic>.from(e.value as Map);
                  data['commentId'] = e.key;
                  return data;
                }).toList();

                comments.sort(
                  (a, b) =>
                      (a['createdAt'] ?? 0).compareTo(b['createdAt'] ?? 0),
                );

                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];

                    return FutureBuilder<DataSnapshot>(
                      future: FirebaseDatabase.instance
                          .ref('users/${comment['userId']}')
                          .get(),
                      builder: (context, userSnapshot) {
                        String username = 'Usuario';
                        String photoUrl = '';

                        if (userSnapshot.hasData &&
                            userSnapshot.data!.value != null) {
                          final userData = userSnapshot.data!.value as Map?;
                          username = userData?['username'] ?? 'Usuario';
                          photoUrl = userData?['photoUrl'] ?? '';
                        }

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: photoUrl.isNotEmpty
                                ? NetworkImage(photoUrl)
                                : null,
                            backgroundColor: Colors.grey.shade300,
                            child: photoUrl.isEmpty
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          title: Text(
                            username,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(comment['text'] ?? ''),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          // Input
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: "Add a comment...",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _addComment,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
