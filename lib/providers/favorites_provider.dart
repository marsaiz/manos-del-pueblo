import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesProvider extends ChangeNotifier {
  List<String> _favoriteIds = [];

  List<String> get favorites => _favoriteIds;

  FavoritesProvider() {
    _loadFavorites(); // Cargar datos al iniciar
  }

  // Cargar de la memoria
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    _favoriteIds = prefs.getStringList('userFavorites') ?? [];
    notifyListeners(); // Avisar a la app que ya tenemos datos
  }

  // Guardar o Borrar (Toggle)
  Future<void> toggleFavorite(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (_favoriteIds.contains(productId)) {
      _favoriteIds.remove(productId); // Si ya estaba, lo borra
    } else {
      _favoriteIds.add(productId); // Si no estaba, lo agrega
    }
    
    // Guardamos en disco
    await prefs.setStringList('userFavorites', _favoriteIds);
    notifyListeners(); // ¡Actualizar pantallas!
  }

  // Saber si un producto es favorito
  bool isFavorite(String productId) {
    return _favoriteIds.contains(productId);
  }
}