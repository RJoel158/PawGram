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
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    _commentController.addListener(() {
      setState(() {
        _charCount = _commentController.text.length;
      });
    });
  }

  Future<void> _addComment() async {
    final text = _commentController.text.trim();
    
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No puedes publicar un comentario vacío'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (text.length > 150) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El comentario no puede tener más de 150 caracteres'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_currentUser == null) return;

    await CommentService.addComment(
      postId: widget.postId,
      userId: _currentUser.uid,
      text: text,
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
      appBar: AppBar(title: const Text("Comentarios")),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
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
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 60,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay comentarios todavía',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '¡Sé el primero en comentar!',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
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
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _commentController,
                              maxLength: 150,
                              decoration: InputDecoration(
                                hintText: "Agrega un comentario...",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                counterText: '$_charCount/150',
                                counterStyle: TextStyle(
                                  color: _charCount > 150
                                      ? Colors.red
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.send),
                            color: _charCount > 0 && _charCount <= 150
                                ? Colors.brown.shade600
                                : Colors.grey,
                            onPressed: _addComment,
                            style: IconButton.styleFrom(
                              backgroundColor: _charCount > 0 && _charCount <= 150
                                  ? Colors.brown.shade50
                                  : Colors.grey.shade100,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
