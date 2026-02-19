// lib/services/pin_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// Servicio para gestionar PINs de seguridad desde Firestore
class PinService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // Cache local de PINs para evitar múltiples llamadas
  static final Map<String, String> _pinCache = {};
  static DateTime? _lastFetch;
  static const Duration _cacheDuration = Duration(minutes: 5);

  /// Obtiene un PIN específico desde Firestore
  /// 
  /// [pinType] puede ser:
  /// - 'admin_access': Para acceder a pantallas de administración
  /// - 'product_management': Para agregar/editar/eliminar productos
  /// - 'artisan_delete': Para eliminar artesanos
  static Future<String> getPin(String pinType) async {
    // Verificar si el cache es válido
    if (_pinCache.containsKey(pinType) && 
        _lastFetch != null && 
        DateTime.now().difference(_lastFetch!) < _cacheDuration) {
      return _pinCache[pinType]!;
    }

    try {
      final doc = await _db.collection('config').doc('pins').get();
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        
        // Actualizar cache
        _pinCache.clear();
        _pinCache.addAll(Map<String, String>.from(data));
        _lastFetch = DateTime.now();
        
        return _pinCache[pinType] ?? _getDefaultPin(pinType);
      }
    } catch (e) {
      print('Error obteniendo PIN desde Firestore: $e');
    }
    
    // Si falla, usar PIN por defecto
    return _getDefaultPin(pinType);
  }

  /// Obtiene todos los PINs de una vez
  static Future<Map<String, String>> getAllPins() async {
    // Verificar cache
    if (_pinCache.isNotEmpty && 
        _lastFetch != null && 
        DateTime.now().difference(_lastFetch!) < _cacheDuration) {
      return Map.from(_pinCache);
    }

    try {
      final doc = await _db.collection('config').doc('pins').get();
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _pinCache.clear();
        _pinCache.addAll(Map<String, String>.from(data));
        _lastFetch = DateTime.now();
        return Map.from(_pinCache);
      }
    } catch (e) {
      print('Error obteniendo PINs desde Firestore: $e');
    }
    
    // Si falla, retornar PINs por defecto
    return {
      'admin_access': '4628',
      'product_management': '1234',
      'artisan_delete': '919345',
    };
  }

  /// Limpia el cache de PINs (útil para forzar actualización)
  static void clearCache() {
    _pinCache.clear();
    _lastFetch = null;
  }

  /// Retorna el PIN por defecto según el tipo (fallback)
  static String _getDefaultPin(String pinType) {
    switch (pinType) {
      case 'admin_access':
        return '4628';
      case 'product_management':
        return '1234';
      case 'artisan_delete':
        return '919345';
      default:
        return '0000';
    }
  }

  /// Actualiza un PIN en Firestore (solo para uso administrativo)
  static Future<void> updatePin(String pinType, String newPin) async {
    try {
      await _db.collection('config').doc('pins').set({
        pinType: newPin,
      }, SetOptions(merge: true));
      
      // Limpiar cache para forzar actualización
      clearCache();
    } catch (e) {
      print('Error actualizando PIN: $e');
      rethrow;
    }
  }
}
