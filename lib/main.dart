import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart'; // <--- Importante
import 'providers/favorites_provider.dart'; // <--- Importante
import 'screens/home_screen.dart';
import 'screens/about_screen.dart'; // Nueva pantalla que crearemos
import 'services/image_upload_service.dart';
import 'services/firebase_config.dart'; // Importamos la configuración de Firebase


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase usando la configuración centralizada
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: FirebaseConfig.config['apiKey']!,
      authDomain: FirebaseConfig.config['authDomain']!,
      projectId: FirebaseConfig.config['projectId']!,
      storageBucket: FirebaseConfig.config['storageBucket']!,
      messagingSenderId: FirebaseConfig.config['messagingSenderId']!,
      appId: FirebaseConfig.config['appId']!,
      measurementId: FirebaseConfig.config['measurementId']!,
    ),
  );
  
  // Inicializar el servicio de subida de imágenes
  await ImageUploadService.initialize();
  
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
      },
    );
  }
}