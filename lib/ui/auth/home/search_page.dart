import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../models/post_tag.dart';
import '../../../services/post_service.dart';
import 'post_card.dart';
import '../posts/comments_page.dart';
import '../posts/edit_post_page.dart';
import '../../../services/reaction_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  PostTag? _selectedTagFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesSearch(
    Map<String, dynamic> post,
    Map<String, dynamic>? userData,
  ) {
    final query = _searchQuery.toLowerCase();

    // Si no hay búsqueda y no hay filtro de etiqueta, mostrar todo
    if (query.isEmpty && _selectedTagFilter == null) {
      return true;
    }

    // Filtrar por etiqueta si hay una seleccionada
    if (_selectedTagFilter != null) {
      final postTag = post['tag'] as String?;
      if (postTag != _selectedTagFilter!.id) {
        return false;
      }
    }

    // Si hay búsqueda de texto, verificar username
    if (query.isNotEmpty) {
      final username = (userData?['username'] ?? '').toString().toLowerCase();
      if (!username.contains(query)) {
        return false;
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Buscar",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Buscar por nombre de usuario...",
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                // Filtro por etiquetas
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('Todas'),
                        selected: _selectedTagFilter == null,
                        onSelected: (selected) {
                          setState(() {
                            _selectedTagFilter = null;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      ...PostTag.availableTags.map((tag) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(tag.displayName),
                            selected: _selectedTagFilter?.id == tag.id,
                            onSelected: (selected) {
                              setState(() {
                                _selectedTagFilter = selected ? tag : null;
                              });
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Resultados
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: PostService.feedStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData ||
                    snapshot.data!.snapshot.value == null) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 80, color: Colors.grey),
                        SizedBox(height: 20),
                        Text(
                          'No hay posts todavía',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                final postsMap = snapshot.data!.snapshot.value as Map;
                final allPosts = postsMap.entries.map((e) {
                  final data = Map<String, dynamic>.from(e.value as Map);
                  data['postId'] = e.key;
                  return data;
                }).toList();

                // Ordenar por fecha descendente
                allPosts.sort(
                  (a, b) =>
                      (b['createdAt'] ?? 0).compareTo(a['createdAt'] ?? 0),
                );

                return FutureBuilder<Map<String, Map<String, dynamic>>>(
                  future: _loadUsersData(allPosts),
                  builder: (context, usersSnapshot) {
                    if (!usersSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final usersData = usersSnapshot.data!;

                    // Filtrar posts según búsqueda
                    final filteredPosts = allPosts.where((post) {
                      final userData = usersData[post['userId']];
                      return _matchesSearch(post, userData);
                    }).toList();

                    if (filteredPosts.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              _searchQuery.isEmpty && _selectedTagFilter == null
                                  ? 'No hay posts todavía'
                                  : 'No se encontraron resultados',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            if (_searchQuery.isNotEmpty ||
                                _selectedTagFilter != null)
                              const Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text(
                                  'Intenta con otros términos',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                          ],
                        ),
                      );
                    }

                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: ListView.builder(
                          itemCount: filteredPosts.length,
                          itemBuilder: (context, index) {
                            final post = filteredPosts[index];
                            final postId = post['postId'];
                            final userData = usersData[post['userId']];
                            final username = userData?['username'] ?? 'Usuario';
                            final userPhoto = userData?['photoUrl'] ?? '';

                            return StreamBuilder<DatabaseEvent>(
                              stream: ReactionService.postReactionsStream(
                                postId,
                              ),
                              builder: (context, reactionsSnapshot) {
                                int likesCount = 0;
                                bool isLiked = false;

                                if (reactionsSnapshot.hasData &&
                                    reactionsSnapshot.data!.snapshot.value !=
                                        null) {
                                  final reactions =
                                      reactionsSnapshot.data!.snapshot.value
                                          as Map;
                                  likesCount = reactions.length;
                                  isLiked = reactions.containsKey(
                                    currentUser?.uid,
                                  );
                                }

                                return PostCard(
                                  username: username,
                                  userPhotoUrl: userPhoto,
                                  postImageUrl: post['mediaUrl'] ?? '',
                                  caption: post['description'] ?? '',
                                  likes: likesCount,
                                  isLiked: isLiked,
                                  tag: post['tag'] as String?,
                                  postUserId: post['userId'] as String?,
                                  postId: postId,
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
                                  onEdit: currentUser?.uid == post['userId']
                                      ? () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => EditPostPage(
                                                postId: postId,
                                                currentCaption:
                                                    post['description'] ?? '',
                                                currentTag:
                                                    post['tag'] ?? 'other',
                                              ),
                                            ),
                                          );
                                        }
                                      : null,
                                  onDelete: currentUser?.uid == post['userId']
                                      ? () async {
                                          try {
                                            await PostService.deletePost(
                                              postId,
                                            );
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    '🗑️ Publicación eliminada',
                                                  ),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                            }
                                          } catch (e) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    '😞 Error al eliminar',
                                                  ),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          }
                                        }
                                      : null,
                                );
                              },
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<Map<String, Map<String, dynamic>>> _loadUsersData(
    List<Map<String, dynamic>> posts,
  ) async {
    final usersData = <String, Map<String, dynamic>>{};
    final uniqueUserIds = posts.map((p) => p['userId'] as String).toSet();

    for (final userId in uniqueUserIds) {
      final snapshot = await FirebaseDatabase.instance
          .ref('users/$userId')
          .get();
      if (snapshot.exists) {
        usersData[userId] = Map<String, dynamic>.from(snapshot.value as Map);
      }
    }

    return usersData;
  }
}
