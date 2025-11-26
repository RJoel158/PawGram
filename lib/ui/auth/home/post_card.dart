import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  final String username;
  final String userPhotoUrl;
  final String postImageUrl;
  final String caption;
  final int likes;
  final bool isLiked;
  final VoidCallback? onLike;
  final VoidCallback? onComment;

  const PostCard({
    super.key,
    required this.username,
    required this.userPhotoUrl,
    required this.postImageUrl,
    required this.caption,
    required this.likes,
    this.isLiked = false,
    this.onLike,
    this.onComment,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ----- HEADER -----
        ListTile(
          leading: CircleAvatar(
            backgroundImage: userPhotoUrl.isNotEmpty
                ? NetworkImage(userPhotoUrl)
                : null,
            backgroundColor: Colors.grey.shade300,
            child: userPhotoUrl.isEmpty ? const Icon(Icons.pets) : null,
          ),
          title: Text(
            username,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: const Text("🐾 Pet Lover"),
        ),

        // ----- IMAGE -----
        AspectRatio(
          aspectRatio: 1,
          child: postImageUrl.isNotEmpty
              ? Image.network(
                  postImageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade300,
                      child: const Center(child: Icon(Icons.error, size: 50)),
                    );
                  },
                )
              : Container(
                  color: Colors.grey.shade300,
                  child: const Center(child: Icon(Icons.image, size: 50)),
                ),
        ),

        // ----- ACTIONS -----
        Row(
          children: [
            IconButton(
              icon: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                color: isLiked ? Colors.red : null,
              ),
              onPressed: onLike,
            ),
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline),
              onPressed: onComment,
            ),
          ],
        ),

        // ----- LIKES -----
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            "$likes likes",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),

        // ----- CAPTION -----
        if (caption.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black),
                children: [
                  TextSpan(
                    text: username,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: "  "),
                  TextSpan(text: caption),
                ],
              ),
            ),
          ),

        const SizedBox(height: 20),
      ],
    );
  }
}
