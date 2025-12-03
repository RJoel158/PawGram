import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../models/post_tag.dart';

class EditPostPage extends StatefulWidget {
  final String postId;
  final String currentCaption;
  final String currentTag;

  const EditPostPage({
    super.key,
    required this.postId,
    required this.currentCaption,
    required this.currentTag,
  });

  @override
  State<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  late TextEditingController _captionController;
  late PostTag _selectedTag;
  bool _loading = false;
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    _captionController = TextEditingController(text: widget.currentCaption);
    _selectedTag = PostTag.fromId(widget.currentTag);
    _charCount = widget.currentCaption.length;

    _captionController.addListener(() {
      setState(() {
        _charCount = _captionController.text.length;
      });
    });
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_captionController.text.trim().length > 150) {
      _showError('La descripción no puede tener más de 150 caracteres');
      return;
    }

    setState(() => _loading = true);

    try {
      await FirebaseDatabase.instance.ref('posts/${widget.postId}').update({
        'description': _captionController.text.trim(),
        'tag': _selectedTag.id,
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ ¡Publicación actualizada!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showError('😞 No pudimos actualizar la publicación. Intenta de nuevo.');
      setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.orange),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Editar Publicación")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                TextField(
                  controller: _captionController,
                  maxLength: 150,
                  decoration: InputDecoration(
                    labelText: "Descripción",
                    hintText: "Escribe algo sobre tu mascota...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    counterText: '$_charCount/150',
                    counterStyle: TextStyle(
                      color: _charCount > 150 ? Colors.red : Colors.grey,
                    ),
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<PostTag>(
                  value: _selectedTag,
                  decoration: InputDecoration(
                    labelText: "Categoría de mascota",
                    prefixIcon: const Icon(Icons.pets),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  items: PostTag.availableTags.map((tag) {
                    return DropdownMenuItem<PostTag>(
                      value: tag,
                      child: Text(tag.displayName),
                    );
                  }).toList(),
                  onChanged: (PostTag? newTag) {
                    if (newTag != null) {
                      setState(() {
                        _selectedTag = newTag;
                      });
                    }
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Guardar Cambios",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
