import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesProvider extends ChangeNotifier {
  List<String> _favoriteIds = [];

  // Getter público
  List<String> get favorites => _favoriteIds;

  FavoritesProvider() {
    _loadFavorites();
  }

  // --- CARGAR DATOS ---
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    _favoriteIds = prefs.getStringList('userFavorites') ?? [];
    
    // ESTO SALDRÁ EN TU CONSOLA AL INICIAR
    print("💾 Datos cargados desde memoria: $_favoriteIds"); 
    
    notifyListeners();
  }

  // --- GUARDAR / BORRAR ---
  Future<void> toggleFavorite(String productId) async {
    // 1. CAMBIO VISUAL PRIMERO (Para que se sienta rápido)
    if (_favoriteIds.contains(productId)) {
      _favoriteIds.remove(productId);
    } else {
      _favoriteIds.add(productId);
    }
    // Avisamos a la pantalla YA MISMO
    notifyListeners(); 

    // 2. GUARDAR EN DISCO DESPUÉS (Segundo plano)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('userFavorites', _favoriteIds);
    
    // ESTO SALDRÁ EN TU CONSOLA AL TOCAR EL CORAZÓN
    print("💾 Lista actualizada guardada: $_favoriteIds");
  }

  // Saber si es favorito
  bool isFavorite(String productId) {
    return _favoriteIds.contains(productId);
  }
}