import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'ui/auth/login_page.dart';
import 'ui/main_screen.dart';
import 'ui/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PawGram',
      theme: ThemeData(
        useMaterial3: true,
        // Global color scheme using the requested palette.
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: AppColors.paddingtonBlue, // titles / accents
          onPrimary: AppColors.onPaddington,
          secondary: AppColors.softBrown, // buttons / surfaces accents
          onSecondary: AppColors.onPaddington,
          error: AppColors.softRed,
          onError: AppColors.onPaddington,
          surface: AppColors.cream,
          onSurface: AppColors.onCream,
        ),
        scaffoldBackgroundColor: AppColors.cream,
        appBarTheme: AppBarTheme(centerTitle: false, elevation: 0, iconTheme: const IconThemeData(color: AppColors.softRed)),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.softBrown,
            foregroundColor: AppColors.onPaddington,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.paddingtonBlue,
            side: BorderSide(color: AppColors.paddingtonBlue.withValues(alpha: 0.12)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        textTheme: GoogleFonts.baloo2TextTheme(ThemeData.light().textTheme).apply(
          bodyColor: AppColors.paddingtonBlue,
          displayColor: AppColors.paddingtonBlue,
        ),
        // Force icons to the soft red across the app and set AppBar icons
        iconTheme: const IconThemeData(color: AppColors.softRed),
      ),
      home: StreamBuilder(
        stream: AuthService().authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData) {
            return MainScreen();
          }

          return LoginPage();
        },
      ),
    );
  }
}
