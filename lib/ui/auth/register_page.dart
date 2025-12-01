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
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  // Stack para superponer el círculo sobre el recuadro
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topCenter,
                    children: [
                      // Recuadro principal con sombra
                      Container(
                        margin: const EdgeInsets.only(top: 60),
                        padding: const EdgeInsets.fromLTRB(24, 80, 24, 32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "PawGram",
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Billabong',
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Crea tu cuenta",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 30),
                            TextField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                hintText: "Elige un nombre de usuario",
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
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                hintText: "tu@email.com",
                                labelText: "Email",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.email),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                            ),
                            const SizedBox(height: 15),
                            TextField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                hintText: "Mínimo 6 caracteres",
                                labelText: "Contraseña",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.lock),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                            ),
                            const SizedBox(height: 25),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _loading ? null : _register,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: _loading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white)
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
                                style: TextStyle(
                                    color: Colors.purple,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Círculo con patita que sobresale
                      Positioned(
                        top: 0,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.purple,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.purple.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.pets,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
