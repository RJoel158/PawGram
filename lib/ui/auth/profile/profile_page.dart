import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../services/auth_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return const Scaffold();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Profile"),
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

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 50,
                  backgroundImage: photoUrl.isNotEmpty
                      ? NetworkImage(photoUrl)
                      : null,
                  backgroundColor: Colors.grey.shade300,
                  child: photoUrl.isEmpty
                      ? const Icon(Icons.pets, size: 50)
                      : null,
                ),
                const SizedBox(height: 10),
                Text(
                  username,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    bio,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Navegar a editar perfil
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text("Edit Profile"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    "Mis Posts",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                      return const Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Center(
                          child: Text(
                            'Aún no tienes posts',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      );
                    }

                    final postsMap = postsSnapshot.data!.snapshot.value as Map;
                    final posts = postsMap.entries.map((e) {
                      final data = Map<String, dynamic>.from(e.value as Map);
                      data['postId'] = e.key;
                      return data;
                    }).toList();

                    return GridView.builder(
                      padding: const EdgeInsets.all(12),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: posts.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 5,
                            crossAxisSpacing: 5,
                          ),
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        final mediaUrl = post['mediaUrl'] ?? '';

                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                          ),
                          child: mediaUrl.isNotEmpty
                              ? Image.network(mediaUrl, fit: BoxFit.cover)
                              : const Icon(Icons.image),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
