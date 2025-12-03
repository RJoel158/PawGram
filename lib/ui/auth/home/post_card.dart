import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PostCard extends StatefulWidget {
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
        tween: Tween<double>(begin: 0.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ----- HEADER -----
        ListTile(
          leading: CircleAvatar(
            backgroundImage: widget.userPhotoUrl.isNotEmpty
                ? NetworkImage(widget.userPhotoUrl)
                : null,
            backgroundColor: Colors.grey.shade300,
            child: widget.userPhotoUrl.isEmpty ? const Icon(Icons.pets) : null,
          ),
          title: Text(
            widget.username,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: const Text("🐾 Pet Lover"),
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
                                    child: CircularProgressIndicator()),
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
                            child: const Center(child: Icon(Icons.image, size: 50)),
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
