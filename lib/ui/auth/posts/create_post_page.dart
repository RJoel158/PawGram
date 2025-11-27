import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/post_service.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _captionController = TextEditingController();
  final _picker = ImagePicker();
  File? _imageFile;
  XFile? _pickedFile;
  bool _loading = false;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedFile = pickedFile;
        if (!kIsWeb) {
          _imageFile = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> _createPost() async {
    if (_pickedFile == null) {
      _showError('📷 Selecciona una foto de tu mascota para compartir');
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    setState(() => _loading = true);

    try {
      String imageUrl;
      if (kIsWeb) {
        final bytes = await _pickedFile!.readAsBytes();
        imageUrl = await PostService.uploadMediaBytes(bytes, 'jpg');
      } else {
        imageUrl = await PostService.uploadMedia(_imageFile!, 'jpg');
      }

      await PostService.createPost(
        userId: currentUser.uid,
        description: _captionController.text.trim(),
        mediaUrl: imageUrl,
        mediaType: 'image',
      );

      if (mounted) {
        _captionController.clear();
        setState(() {
          _imageFile = null;
          _pickedFile = null;
          _loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ ¡Tu post se publicó exitosamente!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      String errorMessage = '😞 No pudimos publicar tu post';

      if (e.toString().contains('permission') ||
          e.toString().contains('unauthorized')) {
        errorMessage =
            '🔒 No tienes permisos para publicar. Verifica tu sesión.';
      } else if (e.toString().contains('network')) {
        errorMessage = '📶 Sin conexión a internet. Verifica tu conexión.';
      } else if (e.toString().contains('storage')) {
        errorMessage = '💾 Error al subir la imagen. Intenta con otra foto.';
      }

      _showError(errorMessage);
      setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Post"),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _pickedFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: kIsWeb
                            ? FutureBuilder<Uint8List>(
                                future: _pickedFile!.readAsBytes(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Image.memory(
                                      snapshot.data!,
                                      fit: BoxFit.cover,
                                    );
                                  }
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                },
                              )
                            : Image.file(_imageFile!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate,
                            size: 60,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Toca para seleccionar una foto",
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _captionController,
              decoration: const InputDecoration(
                hintText: "Escribe algo sobre tu mascota...",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : _createPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Publicar", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
