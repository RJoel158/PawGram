import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _loading = false;

  Future<void> _register() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _usernameController.text.isEmpty) {
      _showError('⚠️ Por favor completa todos los campos para continuar');
      return;
    }

    if (_usernameController.text.length < 3) {
      _showError('👤 El nombre de usuario debe tener al menos 3 caracteres');
      return;
    }

    if (_passwordController.text.length < 6) {
      _showError(
        '🔒 La contraseña debe tener al menos 6 caracteres para mayor seguridad',
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await _authService.register(
        _usernameController.text,
        _emailController.text,
        _passwordController.text,
      );
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      String errorMessage = 'Ocurrió un error al crear tu cuenta';

      if (e.toString().contains('email-already-in-use')) {
        errorMessage =
            '📧 Este email ya está registrado. ¿Ya tienes una cuenta? Intenta iniciar sesión.';
      } else if (e.toString().contains('invalid-email')) {
        errorMessage =
            '⚠️ El email ingresado no es válido. Por favor verifica el formato.';
      } else if (e.toString().contains('weak-password')) {
        errorMessage =
            '🔒 Elige una contraseña más segura. Usa al menos 6 caracteres.';
      } else if (e.toString().contains('operation-not-allowed')) {
        errorMessage =
            '🚫 El registro no está disponible en este momento. Intenta más tarde.';
      } else if (e.toString().contains('network')) {
        errorMessage =
            '📶 Sin conexión a internet. Verifica tu conexión y vuelve a intentar.';
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
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const Icon(Icons.pets, size: 80, color: Colors.purple),
                const SizedBox(height: 20),
                const Text(
                  "PawGram",
                  style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    hintText: "Elige un nombre de usuario",
                    labelText: "Nombre de usuario",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: "tu@email.com",
                    labelText: "Email",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: "Mínimo 6 caracteres",
                    labelText: "Contraseña",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Crear Cuenta",
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "¿Ya tienes cuenta? Inicia sesión",
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
