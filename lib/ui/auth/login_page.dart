import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('Por favor completa todos los campos');
      return;
    }

    setState(() => _loading = true);

    try {
      await _authService.login(_emailController.text, _passwordController.text);
    } catch (e) {
      String errorMessage = 'Ocurrió un error al iniciar sesión';

      if (e.toString().contains('user-not-found') ||
          e.toString().contains('wrong-password') ||
          e.toString().contains('invalid-credential')) {
        errorMessage =
            '📧 Email o contraseña incorrectos. Verifica tus datos e intenta nuevamente.';
      } else if (e.toString().contains('invalid-email')) {
        errorMessage =
            '⚠️ El email ingresado no es válido. Por favor verifica el formato.';
      } else if (e.toString().contains('user-disabled')) {
        errorMessage =
            '🚫 Esta cuenta ha sido deshabilitada. Contacta con soporte.';
      } else if (e.toString().contains('too-many-requests')) {
        errorMessage =
            '⏰ Demasiados intentos fallidos. Por favor espera unos minutos.';
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
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Billabong',
                  ),
                ),
                const SizedBox(height: 40),
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
                    hintText: "••••••••",
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
                    onPressed: _loading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Iniciar Sesión",
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => RegisterPage()),
                    );
                  },
                  child: const Text(
                    "¿No tienes cuenta? Regístrate aquí",
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
