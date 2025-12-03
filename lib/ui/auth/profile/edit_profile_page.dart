import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/user_service.dart';

class EditProfilePage extends StatefulWidget {
  final String currentUsername;
  final String currentBio;
  final String currentPhotoUrl;

  const EditProfilePage({
    super.key,
    required this.currentUsername,
    required this.currentBio,
    required this.currentPhotoUrl,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  final _picker = ImagePicker();
  File? _imageFile;
  XFile? _pickedFile;
  bool _loading = false;
  int _bioCharCount = 0;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentUsername);
    _bioController = TextEditingController(text: widget.currentBio);
    _bioCharCount = widget.currentBio.length;
    
    _bioController.addListener(() {
      setState(() {
        _bioCharCount = _bioController.text.length;
      });
    });
  }

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

  Future<void> _saveProfile() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // Validaciones
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El nombre de usuario no puede estar vacío'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_bioController.text.length > 90) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La biografía no puede tener más de 90 caracteres'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      if (kIsWeb && _pickedFile != null) {
        final bytes = await _pickedFile!.readAsBytes();
        await UserService.updateProfile(
          uid: currentUser.uid,
          name: _nameController.text.trim(),
          bio: _bioController.text.trim(),
          photoBytes: bytes,
        );
      } else {
        await UserService.updateProfile(
          uid: currentUser.uid,
          name: _nameController.text.trim(),
          bio: _bioController.text.trim(),
          photo: _imageFile,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ ¡Perfil actualizado con éxito!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      String errorMessage = '😞 No pudimos actualizar tu perfil';

      if (e.toString().contains('permission') ||
          e.toString().contains('unauthorized')) {
        errorMessage = '🔒 No tienes permisos para editar. Verifica tu sesión.';
      } else if (e.toString().contains('network')) {
        errorMessage = '📶 Sin conexión a internet. Verifica tu conexión.';
      } else if (e.toString().contains('storage')) {
        errorMessage = '💾 Error al subir la foto. Intenta con otra imagen.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
        setState(() => _loading = false);
      }
    }
  }

  Widget _buildProfileImage() {
    if (_pickedFile != null) {
      if (kIsWeb) {
        return FutureBuilder<Uint8List>(
          future: _pickedFile!.readAsBytes(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return CircleAvatar(
                radius: 50,
                backgroundImage: MemoryImage(snapshot.data!),
              );
            }
            return CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey.shade300,
              child: const CircularProgressIndicator(),
            );
          },
        );
      } else {
        return CircleAvatar(
          radius: 50,
          backgroundImage: FileImage(_imageFile!),
        );
      }
    } else if (widget.currentPhotoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 50,
        backgroundImage: NetworkImage(widget.currentPhotoUrl),
      );
    } else {
      return CircleAvatar(
        radius: 50,
        backgroundColor: Colors.grey.shade300,
        child: const Icon(Icons.pets, size: 50),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Editar Perfil")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Stack(
                  children: [
                    _buildProfileImage(),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.brown.shade600,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, size: 18),
                          color: Colors.white,
                          onPressed: _pickImage,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Nombre de usuario",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.person),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _bioController,
                  maxLines: 3,
                  maxLength: 90,
                  decoration: InputDecoration(
                    labelText: "Biografía",
                    hintText: "Cuéntanos sobre tu mascota...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.edit_note),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    counterText: '$_bioCharCount/90',
                    counterStyle: TextStyle(
                      color: _bioCharCount > 90 ? Colors.red : Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _saveProfile,
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
