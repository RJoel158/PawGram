import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../services/auth_service.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return const Scaffold();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tu Perfil"),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout();
            },
          ),
        ],
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: FirebaseDatabase.instance
            .ref('users/${currentUser.uid}')
            .onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          String username = 'Usuario';
          String bio = 'Bio sobre tu mascota...';
          String photoUrl = '';

          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            final userData = snapshot.data!.snapshot.value as Map?;
            username = userData?['username'] ?? 'Usuario';
            bio = userData?['bio'] ?? 'Bio sobre tu mascota...';
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
                      backgroundColor: Colors.grey.shade300,
                      child: photoUrl.isEmpty
                          ? const Icon(Icons.pets, size: 60)
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
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditProfilePage(
                              currentUsername: username,
                              currentBio: bio,
                              currentPhotoUrl: photoUrl,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text("Editar Perfil"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Divider(),
                    const SizedBox(height: 10),
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(Icons.grid_on, size: 20),
                          SizedBox(width: 8),
                          Text(
                            "Mis Publicaciones",
                            style: TextStyle(
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
                          .equalTo(currentUser.uid)
                          .onValue,
                      builder: (context, postsSnapshot) {
                        if (!postsSnapshot.hasData ||
                            postsSnapshot.data!.snapshot.value == null) {
                          return Padding(
                            padding: const EdgeInsets.all(60.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 60,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Aún no tienes publicaciones',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '¡Comparte momentos de tu mascota!',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        final postsMap =
                            postsSnapshot.data!.snapshot.value as Map;
                        final posts = postsMap.entries.map((e) {
                          final data =
                              Map<String, dynamic>.from(e.value as Map);
                          data['postId'] = e.key;
                          return data;
                        }).toList();

                        // Calcular número de columnas según ancho
                        final screenWidth = MediaQuery.of(context).size.width;
                        final constrainedWidth =
                            screenWidth > 800 ? 800 : screenWidth;
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

                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: mediaUrl.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: mediaUrl,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: Colors.grey.shade200,
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                        color: Colors.grey.shade300,
                                        child: const Icon(
                                          Icons.image_not_supported,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      color: Colors.grey.shade300,
                                      child: const Icon(Icons.image),
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
