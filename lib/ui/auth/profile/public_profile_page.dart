import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'user_feed_page.dart';
import '../../theme/app_colors.dart';

class PublicProfilePage extends StatelessWidget {
  final String userId;

  const PublicProfilePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isOwnProfile = currentUser?.uid == userId;

    return Scaffold(
      appBar: AppBar(title: const Text("Perfil")),
      body: StreamBuilder<DatabaseEvent>(
        stream: FirebaseDatabase.instance.ref('users/$userId').onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          String username = 'Usuario';
          String bio = 'Bio sobre su mascota...';
          String photoUrl = '';

          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            final userData = snapshot.data!.snapshot.value as Map?;
            username = userData?['username'] ?? 'Usuario';
            bio = userData?['bio'] ?? 'Bio sobre su mascota...';
            photoUrl = userData?['photoUrl'] ?? '';
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    // Avatar y info del usuario
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: photoUrl.isNotEmpty
                          ? NetworkImage(photoUrl)
                          : null,
                      backgroundColor: AppColors.cream,
                      child: photoUrl.isEmpty
                          ? const Icon(
                              Icons.pets,
                              size: 60,
                              color: AppColors.softRed,
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      username,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        bio,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Divider(),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.grid_on, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            isOwnProfile
                                ? "Mis Publicaciones"
                                : "Publicaciones de $username",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Grid de posts del usuario
                    StreamBuilder<DatabaseEvent>(
                      stream: FirebaseDatabase.instance
                          .ref('posts')
                          .orderByChild('userId')
                          .equalTo(userId)
                          .onValue,
                      builder: (context, postsSnapshot) {
                        if (!postsSnapshot.hasData ||
                            postsSnapshot.data!.snapshot.value == null) {
                          return Padding(
                            padding: const EdgeInsets.all(60.0),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 60,
                                  color: AppColors.softRed,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  isOwnProfile
                                      ? 'Aún no tienes publicaciones'
                                      : 'No hay publicaciones',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        final postsMap =
                            postsSnapshot.data!.snapshot.value as Map;
                        final posts = postsMap.entries.map((e) {
                          final data = Map<String, dynamic>.from(
                            e.value as Map,
                          );
                          data['postId'] = e.key;
                          return data;
                        }).toList();

                        // Calcular número de columnas según ancho
                        final screenWidth = MediaQuery.of(context).size.width;
                        final constrainedWidth = screenWidth > 800
                            ? 800
                            : screenWidth;
                        final crossAxisCount = constrainedWidth > 600 ? 4 : 3;

                        return GridView.builder(
                          padding: const EdgeInsets.all(16),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: posts.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                              ),
                          itemBuilder: (context, index) {
                            final post = posts[index];
                            final mediaUrl = post['mediaUrl'] ?? '';

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => UserFeedPage(
                                      userId: userId,
                                      initialIndex: index,
                                    ),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: mediaUrl.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: mediaUrl,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            Container(
                                              color: Colors.grey.shade200,
                                              child: const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              ),
                                            ),
                                        errorWidget: (context, url, error) =>
                                            Container(
                                              color: Colors.grey.shade300,
                                              child: const Icon(
                                                Icons.image_not_supported,
                                                color: AppColors.softRed,
                                              ),
                                            ),
                                      )
                                    : Container(
                                        color: AppColors.cream,
                                        child: const Icon(
                                          Icons.image,
                                          color: AppColors.softRed,
                                        ),
                                      ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
