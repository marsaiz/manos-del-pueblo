// lib/services/image_upload_service.dart
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'image_picker_bridge.dart';

class ImageUploadService {
  static FirebaseStorage get _storage => FirebaseStorage.instance;

  // Se utiliza la instancia por defecto inicializada en main.dart

  // Sube la imagen de perfil de un artesano
  static Future<String?> uploadArtisanProfileImage(String artisanId) async {
    return await _uploadImage('artesanos/$artisanId/perfil', 'profile_');
  }

  // --- MODIFICACIÓN AQUÍ ---
  // Ahora pedimos también el productId para generar un nombre de archivo ordenado
  static Future<String?> uploadProductImage(
    String artisanId,
    String productId,
  ) async {
    // Guardamos en: artesanos/a1/productos/product_p1.jpg
    // Usamos el productId en el nombre del archivo
    return await _uploadImage(
      'artesanos/$artisanId/productos',
      'product_${productId}_',
    );
  }

  // Método privado para manejar la subida de imágenes
  static Future<String?> _uploadImage(String folder, String prefix) async {
    try {
      // Seleccionar imagen
      final mediaData = await pickImageData();
      if (mediaData == null) return null;

      // Crear referencia al almacenamiento
      final storageRef = _storage.ref().child(
        '$folder/$prefix${DateTime.now().millisecondsSinceEpoch}',
      );

      // Subir la imagen (usando putData para Uint8List)
      final uploadTask = storageRef.putData(
        mediaData.bytes,
        SettableMetadata(contentType: mediaData.mimeType ?? 'image/jpeg'),
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

  // Elimina toda la carpeta de un artesano (perfil y productos)
  static Future<void> deleteArtisanFolder(String artisanId) async {
    try {
      final listResult = await _storage.ref('artesanos/$artisanId').listAll();

      // Eliminar archivos en la raíz (como el perfil si estuviera ahí) y subcarpetas
      for (var prefix in listResult.prefixes) {
        // Recursivamente para 'productos' y 'perfil'
        final subList = await prefix.listAll();
        for (var item in subList.items) {
          await item.delete();
        }
      }
      for (var item in listResult.items) {
        await item.delete();
      }
      debugPrint("✅ Carpeta de Storage del artesano $artisanId eliminada");
    } catch (e) {
      debugPrint('Error al eliminar carpeta de Storage: $e');
    }
  }
}
