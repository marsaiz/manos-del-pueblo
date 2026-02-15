import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart'; // <--- Importante
import 'providers/favorites_provider.dart'; // <--- Importante
import 'screens/home_screen.dart';
import 'screens/about_screen.dart'; // Nueva pantalla que crearemos
import 'firebase_options.dart';
import 'screens/admin/add_artisan_screen.dart';
import 'screens/admin/add_product_screen.dart';
import 'screens/admin/admin_courses_screen.dart';
import 'screens/courses_screen.dart';
import 'services/remote_config_service.dart';
import 'screens/admin/admin_artisans_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await RemoteConfigService().initialize();

  // No necesitamos llamar a ImageUploadService.initialize() porque ya inicializamos Firebase arriba
  // y el servicio usa FirebaseStorage.instance que se conecta automáticamente.

  runApp(
    // Envolvemos la app para que los favoritos funcionen en todos lados
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
      home: const HomeScreen(),
      // Definición de rutas
      routes: {
        '/about': (context) => const AboutScreen(),
        '/add-artisan': (context) => const AddArtisanScreen(),
        '/add-product': (context) => const AddProductScreen(),
        '/courses': (context) => const CoursesScreen(),
        '/admin-courses': (context) => const AdminCoursesScreen(),
        '/admin-artisans': (context) => const AdminArtisansScreen(),
      },
    );
  }
}
