// lib/services/admin_session_service.dart
class AdminSessionService {
  static final AdminSessionService _instance = AdminSessionService._internal();
  factory AdminSessionService() => _instance;
  AdminSessionService._internal();

  bool _isAuthenticated = false;
  DateTime? _authenticationTime;
  
  // Duración de la sesión (30 minutos)
  static const Duration _sessionDuration = Duration(minutes: 30);

  bool get isAuthenticated {
    if (!_isAuthenticated) return false;
    
    // Verificar si la sesión ha expirado
    if (_authenticationTime != null) {
      final now = DateTime.now();
      final difference = now.difference(_authenticationTime!);
      
      if (difference > _sessionDuration) {
        // Sesión expirada
        logout();
        return false;
      }
    }
    
    return _isAuthenticated;
  }

  void login() {
    _isAuthenticated = true;
    _authenticationTime = DateTime.now();
  }

  void logout() {
    _isAuthenticated = false;
    _authenticationTime = null;
  }

  void extendSession() {
    if (_isAuthenticated) {
      _authenticationTime = DateTime.now();
    }
  }
}
