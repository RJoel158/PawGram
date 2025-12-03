import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/post_tag.dart';
import '../../auth/profile/public_profile_page.dart';

class PostCard extends StatefulWidget {
  final String username;
  final String userPhotoUrl;
  final String postImageUrl;
  final String caption;
  final int likes;
  final bool isLiked;
  final String? tag;
  final String? postUserId;
  final String? postId;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const PostCard({
    super.key,
    required this.username,
    required this.userPhotoUrl,
    required this.postImageUrl,
    required this.caption,
    required this.likes,
    this.isLiked = false,
    this.tag,
    this.postUserId,
    this.postId,
    this.onLike,
    this.onComment,
    this.onDelete,
    this.onEdit,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with SingleTickerProviderStateMixin {
  bool _showPawAnimation = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 1.2,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.2,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_animationController);

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _showPawAnimation = false);
        _animationController.reset();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    if (widget.onLike != null) {
      widget.onLike!();
      setState(() => _showPawAnimation = true);
      _animationController.forward();
    }
  }

  void _openImageFullScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: CachedNetworkImage(
                imageUrl: widget.postImageUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
                errorWidget: (context, url, error) => const Center(
                  child: Icon(Icons.error, color: Colors.white, size: 50),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget? _buildOptionsMenu(BuildContext context) {
    // Solo mostrar menú si hay callbacks de editar o eliminar
    if (widget.onEdit == null && widget.onDelete == null) {
      return null;
    }

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        if (value == 'edit' && widget.onEdit != null) {
          widget.onEdit!();
        } else if (value == 'delete' && widget.onDelete != null) {
          _confirmDelete(context);
        }
      },
      itemBuilder: (context) => [
        if (widget.onEdit != null)
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit, size: 20),
                SizedBox(width: 8),
                Text('Editar'),
              ],
            ),
          ),
        if (widget.onDelete != null)
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, size: 20, color: Colors.red),
                SizedBox(width: 8),
                Text('Eliminar', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
      ],
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar publicación'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar esta publicación? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (widget.onDelete != null) {
                widget.onDelete!();
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _navigateToProfile(BuildContext context) {
    if (widget.postUserId != null) {
      final currentUser = FirebaseAuth.instance.currentUser;
      // Si es el perfil del usuario actual, no navegar (ya está en su perfil)
      if (currentUser?.uid == widget.postUserId) {
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PublicProfilePage(userId: widget.postUserId!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ----- HEADER -----
        ListTile(
          leading: GestureDetector(
            onTap: () => _navigateToProfile(context),
            child: CircleAvatar(
              backgroundImage: widget.userPhotoUrl.isNotEmpty
                  ? NetworkImage(widget.userPhotoUrl)
                  : null,
              backgroundColor: Colors.grey.shade300,
              child: widget.userPhotoUrl.isEmpty
                  ? const Icon(Icons.pets)
                  : null,
            ),
          ),
          title: GestureDetector(
            onTap: () => _navigateToProfile(context),
            child: Text(
              widget.username,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          subtitle: Text(PostTag.fromId(widget.tag ?? 'other').displayName),
          trailing: _buildOptionsMenu(context),
        ),

        // ----- IMAGE CON DOBLE TAP Y CLIC -----
        GestureDetector(
          onDoubleTap: _handleDoubleTap,
          onTap: () => _openImageFullScreen(context),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Polaroid-style white margin around the post image
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Container(
                  color: Colors.white, // pure white margin/frame
                  padding: const EdgeInsets.all(8),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: widget.postImageUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: CachedNetworkImage(
                              imageUrl: widget.postImageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey.shade200,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey.shade300,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.image_not_supported,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Error al cargar imagen',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.grey.shade300,
                            child: const Center(
                              child: Icon(Icons.image, size: 50),
                            ),
                          ),
                  ),
                ),
              ),
              // Animación de huellita
              if (_showPawAnimation)
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _opacityAnimation.value,
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Icon(
                          Icons.pets,
                          size: 120,
                          color: Colors.brown.shade600,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),

        // ----- ACTIONS -----
        Row(
          children: [
            IconButton(
              icon: Icon(
                widget.isLiked ? Icons.favorite : Icons.favorite_border,
                color: widget.isLiked ? Colors.red : null,
              ),
              onPressed: widget.onLike,
            ),
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline),
              onPressed: widget.onComment,
            ),
          ],
        ),

        // ----- LIKES -----
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            "${widget.likes} likes",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),

        // ----- CAPTION -----
        if (widget.caption.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black),
                children: [
                  TextSpan(
                    text: widget.username,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: "  "),
                  TextSpan(text: widget.caption),
                ],
              ),
            ),
          ),

        const SizedBox(height: 20),
      ],
    );
  }
}
