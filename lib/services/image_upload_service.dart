// lib/services/image_upload_service.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:flutter/material.dart';
import 'firebase_config.dart'; // Añade esta línea

class ImageUploadService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Inicializa Firebase
  static Future<void> initialize() async {
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
  }

  // Sube la imagen de perfil de un artesano
  static Future<String?> uploadArtisanProfileImage(String artisanId) async {
    return await _uploadImage('artesanos/$artisanId/perfil', 'profile_');
  }

  // Sube una imagen de un producto
  static Future<String?> uploadProductImage(String artisanId) async {
    return await _uploadImage('artesanos/$artisanId/productos', 'product_');
  }

  // Método privado para manejar la subida de imágenes
  static Future<String?> _uploadImage(String folder, String prefix) async {
    try {
      // Seleccionar imagen
      final mediaData = await ImagePickerWeb.getImageInfo();
      if (mediaData == null) return null;

      // Crear referencia al almacenamiento
      final storageRef = _storage.ref().child(
        '$folder/$prefix${DateTime.now().millisecondsSinceEpoch}',
      );

      // Subir la imagen (usando putData para Uint8List)
      final uploadTask = storageRef.putData(
        mediaData.data!,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Esperar a que se complete la carga
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      debugPrint('Error al subir la imagen: $e');
      return null;
    }
  }

  // Obtener URL de una imagen
  static Future<String> getImageUrl(String path) async {
    return await _storage.ref(path).getDownloadURL();
  }

  // Eliminar una imagen
  static Future<void> deleteImage(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      debugPrint('Error al eliminar la imagen: $e');
      rethrow;
    }
  }
}
