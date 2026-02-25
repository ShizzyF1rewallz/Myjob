import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'controllers/auth_controller.dart';
import 'controllers/jobs_controller.dart';
import 'controllers/applications_controller.dart';
import 'controllers/favorites_controller.dart';
import 'controllers/messages_controller.dart';
import 'utils/app_theme.dart';
import 'utils/constants.dart';
import 'views/auth/login_view.dart';
import 'views/auth/register_view.dart';
import 'views/auth/forgot_password_view.dart';
import 'views/faq/faq_view.dart';
import 'views/home/home_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runZonedGuarded(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Ne pas afficher les erreurs à l'utilisateur (ex: index Firestore)
    FlutterError.onError = (_) {};
    runApp(const MyApp());
  }, (error, stack) {
    // Erreurs non gérées : pas d'affichage à l'utilisateur
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => JobsController()),
        ChangeNotifierProvider(create: (_) => ApplicationsController()),
        ChangeNotifierProvider(create: (_) => FavoritesController()),
        ChangeNotifierProvider(create: (_) => MessagesController()),
      ],
      child: MaterialApp(
        title: Constants.appName,
        theme: AppTheme.light,
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => const AuthWrapper(),
          '/login': (context) => const LoginView(),
          '/register': (context) => const RegisterView(),
          '/forgot-password': (context) => const ForgotPasswordView(),
          '/home': (context) => const HomeShell(),
          '/faq': (context) => const FaqView(),
        },
      ),
    );
  }
}

/// Affiche un écran de chargement puis redirige vers login ou home selon la session.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (_, auth, __) {
        if (auth.loading) {
          return Scaffold(
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF4F46E5),
                    Color(0xFF3730A3),
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.work_rounded,
                        size: 44,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 28),
                    const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Chargement...',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        if (auth.isLoggedIn) {
          return const HomeShell();
        }
        return const LoginView();
      },
    );
  }
}
