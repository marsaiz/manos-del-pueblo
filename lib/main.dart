import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/favorites_provider.dart';
import 'screens/home_screen.dart';
import 'screens/about_screen.dart';
import 'screens/privacy_policy_screen.dart';
import 'firebase_options.dart';
import 'screens/admin/add_artisan_screen.dart';
import 'screens/admin/add_product_screen.dart';
import 'screens/admin/admin_courses_screen.dart';
import 'screens/courses_screen.dart';
import 'services/remote_config_service.dart';
import 'services/version_check_service.dart';
import 'widgets/update_dialog.dart';
import 'screens/admin/admin_artisans_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await RemoteConfigService().initialize();

  runApp(
    ChangeNotifierProvider(
      create: (context) => FavoritesProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: const MyCustomScrollBehavior(),
      debugShowCheckedModeBanner: false,
      title: 'Manos del Pueblo',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        scaffoldBackgroundColor: const Color(0xFFF5F5DC),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Color(0xFF5D4037),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          prefixIconColor: Colors.brown,
        ),
      ),
      home: const AppInitializer(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/about': (context) => const AboutScreen(),
        '/privacy-policy': (context) => const PrivacyPolicyScreen(),
        '/add-artisan': (context) => const AddArtisanScreen(),
        '/add-product': (context) => const AddProductScreen(),
        '/courses': (context) => const CoursesScreen(),
        '/admin-courses': (context) => const AdminCoursesScreen(),
        '/admin-artisans': (context) => const AdminArtisansScreen(),
      },
    );
  }
}

/// Widget que verifica la versión antes de mostrar la app
class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  final VersionCheckService _versionCheckService = VersionCheckService();
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkVersion();
  }

  Future<void> _checkVersion() async {
    try {
      final result = await _versionCheckService.checkVersion();

      if (!mounted) return;

      if (result.status == UpdateStatus.forceUpdate) {
        // Mostrar diálogo de actualización forzada (no se puede cerrar)
        _showUpdateDialog(result);
      } else if (result.status == UpdateStatus.updateAvailable) {
        // Mostrar diálogo de actualización opcional
        _showUpdateDialog(result);
        // Continuar a la app después de mostrar el diálogo
        _navigateToHome();
      } else {
        // App actualizada, continuar normalmente
        _navigateToHome();
      }
    } catch (e) {
      debugPrint('Error al verificar versión: $e');
      // En caso de error, continuar a la app
      if (mounted) {
        _navigateToHome();
      }
    }
  }

  void _showUpdateDialog(VersionCheckResult result) {
    showDialog(
      context: context,
      barrierDismissible: result.status != UpdateStatus.forceUpdate,
      builder: (context) => UpdateDialog(result: result),
    );
  }

  void _navigateToHome() {
    setState(() {
      _isChecking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Verificando actualizaciones...'),
            ],
          ),
        ),
      );
    }

    return const HomeScreen();
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  const MyCustomScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
