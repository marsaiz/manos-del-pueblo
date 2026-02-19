// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/artisan.dart';
import '../models/product.dart';
import '../models/course.dart';
import '../data/database.dart';
import 'image_upload_service.dart';

class FirestoreService {
  static FirebaseFirestore get _db => FirebaseFirestore.instance;

  // --- MIGRACIÓN (EJECUTAR UNA VEZ) ---
  static Future<void> syncDatabaseToFirestore() async {
    try {
      // 1. Sincronizar Artesanos
      for (var artisan in globalArtisans) {
        final docRef = _db.collection('artisans').doc(artisan.id);
        final docSnap = await docRef.get();

        // Solo sobreescribimos si no existe o si la foto actual no es remota (http)
        String finalFoto = artisan.fotoPerfil;
        if (docSnap.exists) {
          final existingFoto = docSnap.data()?['fotoPerfil'] ?? '';
          if (existingFoto.startsWith('http')) {
            finalFoto = existingFoto;
          }
        }

        await docRef.set({
          'id': artisan.id,
          'nombre': artisan.nombre,
          'historia': artisan.historia,
          'fotoPerfil': finalFoto,
          'telefono': artisan.telefono,
          'whatsapp': artisan.whatsapp,
          'ubicacion': artisan.ubicacion,
          'direccion': artisan.direccion,
          'localidad': artisan.localidad,
          'codigoPostal': artisan.codigoPostal,
          'provincia': artisan.provincia,
          'instagram': artisan.instagram,
          'facebook': artisan.facebook,
        });
      }

      // 2. Sincronizar Productos
      for (var product in globalProducts) {
        final docRef = _db.collection('products').doc(product.id);
        final docSnap = await docRef.get();

        // Manejar migración de imagePath (String) a imagePaths (List)
        List<String> finalImages = product.imagePaths;
        if (docSnap.exists) {
          final data = docSnap.data();
          if (data != null) {
            if (data.containsKey('imagePaths')) {
              final List<dynamic> existingPaths = data['imagePaths'] ?? [];
              finalImages = existingPaths.cast<String>();
            } else if (data.containsKey('imagePath')) {
              final String existingPath = data['imagePath'] ?? '';
              if (existingPath.isNotEmpty) {
                finalImages = [existingPath];
              }
            }
          }
        }

        await docRef.set({
          'id': product.id,
          'artisanId': product.artisanId,
          'nombre': product.nombre,
          'descripcion': product.descripcion,
          'precio': product.precio.toString(),
          'imagePaths': finalImages, // Guardamos la lista
          'categoria': product.categoria,
        });
      }
      debugPrint("✅ Base de datos sincronizada con Firestore");
    } catch (e) {
      debugPrint("❌ Error sincronizando base de datos: $e");
    }
  }

  // --- ARTESANOS ---
  static Stream<List<Artisan>> getArtisans() {
    return _db.collection('artisans').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Artisan(
          id: data['id'] ?? '',
          nombre: data['nombre'] ?? '',
          historia: data['historia'] ?? '',
          fotoPerfil: data['fotoPerfil'] ?? '',
          telefono: data['telefono'] ?? '',
          whatsapp: data['whatsapp'] ?? '',
          ubicacion: data['ubicacion'] ?? '',
          direccion: data['direccion'] ?? '',
          localidad: data['localidad'] ?? '',
          codigoPostal: data['codigoPostal'] ?? '',
          provincia: data['provincia'] ?? '',
          instagram: data['instagram'] ?? '',
          facebook: data['facebook'] ?? '',
        );
      }).toList();
    });
  }

  // --- PRODUCTOS ---
  static Stream<List<Product>> getProducts() {
    return _db.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();

        // Soporte para migración: si no hay imagePaths, usamos imagePath
        List<String> paths = [];
        if (data.containsKey('imagePaths')) {
          paths = List<String>.from(data['imagePaths'] ?? []);
        } else if (data.containsKey('imagePath')) {
          paths = [data['imagePath'] ?? ''];
        }

        return Product(
          id: data['id'] ?? '',
          artisanId: data['artisanId'] ?? '',
          nombre: data['nombre'] ?? '',
          descripcion: data['descripcion'] ?? '',
          precio: (data['precio'] ?? '').toString(),
          imagePaths: paths,
          categoria: data['categoria'] ?? '',
        );
      }).toList();
    });
  }

  // --- ACTUALIZACIONES ---
  static Future<void> updateArtisanPhoto(
    String artisanId,
    String photoUrl,
  ) async {
    await _db.collection('artisans').doc(artisanId).update({
      'fotoPerfil': photoUrl,
    });
  }

  static Future<void> updateProductPhoto(
    String productId,
    String photoUrl,
  ) async {
    await _db.collection('products').doc(productId).update({
      'imagePath': photoUrl,
    });
  }

  // --- NUEVAS ALTAS ---
  static Future<void> addArtisan(Artisan artisan) async {
    await _db.collection('artisans').doc(artisan.id).set({
      'id': artisan.id,
      'nombre': artisan.nombre,
      'historia': artisan.historia,
      'fotoPerfil': artisan.fotoPerfil,
      'telefono': artisan.telefono,
      'whatsapp': artisan.whatsapp,
      'ubicacion': artisan.ubicacion,
      'direccion': artisan.direccion,
      'localidad': artisan.localidad,
      'codigoPostal': artisan.codigoPostal,
      'provincia': artisan.provincia,
      'instagram': artisan.instagram,
      'facebook': artisan.facebook,
    });
  }

  static Future<void> addProduct(Product product) async {
    await _db.collection('products').doc(product.id).set({
      'id': product.id,
      'artisanId': product.artisanId,
      'nombre': product.nombre,
      'descripcion': product.descripcion,
      'precio': product.precio,
      'imagePaths': product.imagePaths,
      'categoria': product.categoria,
    });
  }

  static Future<void> updateProduct(Product product) async {
    await _db.collection('products').doc(product.id).update({
      'nombre': product.nombre,
      'descripcion': product.descripcion,
      'precio': product.precio,
      'imagePaths': product.imagePaths,
      'categoria': product.categoria,
      'artisanId': product.artisanId,
    });
  }

  static Future<void> deleteProduct(String productId) async {
    // 1. Primero obtener el producto para acceder a sus imágenes
    final productDoc = await _db.collection('products').doc(productId).get();
    
    if (productDoc.exists) {
      final data = productDoc.data();
      if (data != null) {
        // Obtener las URLs de las imágenes
        List<String> imageUrls = [];
        if (data.containsKey('imagePaths')) {
          imageUrls = List<String>.from(data['imagePaths'] ?? []);
        } else if (data.containsKey('imagePath')) {
          final imagePath = data['imagePath'] ?? '';
          if (imagePath.isNotEmpty) {
            imageUrls = [imagePath];
          }
        }
        
        // 2. Eliminar las imágenes de Storage
        if (imageUrls.isNotEmpty) {
          // Importar ImageUploadService si no está importado
          await ImageUploadService.deleteProductImages(imageUrls);
        }
      }
    }
    
    // 3. Eliminar el documento de Firestore
    await _db.collection('products').doc(productId).delete();
    debugPrint("✅ Producto eliminado de Firestore");
  }

  // --- ELIMINACIÓN EN CASCADA ---
  static Future<void> deleteArtisanCascade(String artisanId) async {
    // 1. Obtener todos los productos del artesano
    final productsSnapshot = await _db
        .collection('products')
        .where('artisanId', isEqualTo: artisanId)
        .get();

    // 2. Eliminar imágenes de cada producto de Storage
    for (var doc in productsSnapshot.docs) {
      final data = doc.data();
      List<String> imageUrls = [];
      
      if (data.containsKey('imagePaths')) {
        imageUrls = List<String>.from(data['imagePaths'] ?? []);
      } else if (data.containsKey('imagePath')) {
        final imagePath = data['imagePath'] ?? '';
        if (imagePath.isNotEmpty) {
          imageUrls = [imagePath];
        }
      }
      
      if (imageUrls.isNotEmpty) {
        await ImageUploadService.deleteProductImages(imageUrls);
      }
    }

    // 3. Crear batch para eliminar documentos de Firestore
    final batch = _db.batch();

    // 4. Marcar productos para eliminar en el batch
    for (var doc in productsSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // 5. Marcar al artesano para eliminar
    batch.delete(_db.collection('artisans').doc(artisanId));

    // 6. Ejecutar todas las eliminaciones en Firestore
    await batch.commit();

    debugPrint("✅ Artesano, sus productos e imágenes eliminados");
  }

  // --- CURSOS ---
  static Stream<List<Course>> getCourses() {
    return _db.collection('courses').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Course.fromMap(doc.data());
      }).toList();
    });
  }

  static Future<void> addCourse(Course course) async {
    await _db.collection('courses').doc(course.id).set(course.toMap());
  }

  static Future<void> updateCourse(Course course) async {
    await _db.collection('courses').doc(course.id).update(course.toMap());
  }

  static Future<void> deleteCourse(String courseId) async {
    try {
      // Primero obtener el curso para acceder a su imageUrl
      final courseDoc = await _db.collection('courses').doc(courseId).get();
      
      if (courseDoc.exists) {
        final courseData = courseDoc.data();
        final imageUrl = courseData?['imageUrl'] as String?;
        
        // Eliminar la imagen del Storage si existe
        if (imageUrl != null && imageUrl.isNotEmpty && imageUrl.startsWith('http')) {
          try {
            await ImageUploadService.deleteImage(imageUrl);
            debugPrint("✅ Imagen del curso eliminada de Storage");
          } catch (e) {
            debugPrint("⚠️  Error al eliminar imagen del curso: $e");
            // Continuar con la eliminación del documento aunque falle la imagen
          }
        }
      }
      
      // Eliminar el documento de Firestore
      await _db.collection('courses').doc(courseId).delete();
      debugPrint("✅ Curso eliminado de Firestore");
    } catch (e) {
      debugPrint("❌ Error al eliminar curso: $e");
      rethrow;
    }
  }
}
