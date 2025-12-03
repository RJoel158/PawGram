import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'register_page.dart';
import '../theme/app_colors.dart';

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
      backgroundColor: AppColors.cream,
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
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              "PawGram",
                              style: const TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Billabong',
                              ).copyWith(color: AppColors.paddingtonBlue),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Inicia sesión",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 30),
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
                                fillColor: AppColors.cream,
                              ),
                            ),
                            const SizedBox(height: 15),
                            TextField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                hintText: "••••••••",
                                labelText: "Contraseña",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.lock),
                                filled: true,
                                fillColor: AppColors.cream,
                              ),
                            ),
                            const SizedBox(height: 25),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _loading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.softBrown,
                                  foregroundColor: AppColors.onPaddington,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: _loading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white)
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
                                  MaterialPageRoute(
                                      builder: (_) => RegisterPage()),
                                );
                              },
                              child: Text(
                                "¿No tienes cuenta? Regístrate aquí",
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w600)
                                    .copyWith(color: AppColors.softBrown),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Círculo con imagen que sobresale
                      Positioned(
                        top: 0,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipOval(
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Image.asset(
                                  'web/icons/pawgram.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    // Si no encuentra la imagen, muestra el icono
                                    return Icon(
                                      Icons.pets,
                                      size: 60,
                                      color: AppColors.softBrown,
                                    );
                                  },
                                ),
                              ),
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
