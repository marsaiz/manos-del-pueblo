import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigService {
  RemoteConfigService._internal();

  static final RemoteConfigService _instance = RemoteConfigService._internal();

  factory RemoteConfigService() => _instance;

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> initialize() async {
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );

    await _remoteConfig.setDefaults({
      'home_banner_enabled': true,
      'home_banner_text': 'Bienvenidos a Manos del Pueblo',
      // Configuración de versiones con prefijo para no conflictuar con otras apps
      'manos_min_version_android': '1.2.1',
      'manos_min_version_ios': '1.2.1',
      'manos_min_version_web': '1.2.1',
      'manos_latest_version_android': '1.2.1',
      'manos_latest_version_ios': '1.2.1',
      'manos_latest_version_web': '1.2.1',
      'manos_force_update': false,
      'manos_update_message': 'Hay una nueva versión disponible. Por favor actualiza la aplicación.',
      'manos_force_update_message': 'Esta versión ya no es compatible. Debes actualizar para continuar.',
      'manos_android_store_url': 'https://play.google.com/store/apps/details?id=ar.manosdelpueblo.app',
      'manos_ios_store_url': 'https://apps.apple.com/ar/app/manos-del-pueblo/id6759227694',
      'manos_web_url': 'https://manos-del-pueblo.ar',
    });

    await _remoteConfig.fetchAndActivate();
  }

  bool getBool(String key) => _remoteConfig.getBool(key);

  String getString(String key) => _remoteConfig.getString(key);

  int getInt(String key) => _remoteConfig.getInt(key);

  double getDouble(String key) => _remoteConfig.getDouble(key);

  // Obtener versión mínima según plataforma
  String getMinVersion() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return getString('manos_min_version_android');
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return getString('manos_min_version_ios');
    } else if (kIsWeb) {
      return getString('manos_min_version_web');
    }
    return '1.0.0';
  }

  // Obtener última versión según plataforma
  String getLatestVersion() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return getString('manos_latest_version_android');
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return getString('manos_latest_version_ios');
    } else if (kIsWeb) {
      return getString('manos_latest_version_web');
    }
    return '1.0.0';
  }

  // Obtener URL de la tienda según plataforma
  String getStoreUrl() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return getString('manos_android_store_url');
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return getString('manos_ios_store_url');
    } else if (kIsWeb) {
      return getString('manos_web_url');
    }
    return '';
  }

  // Verificar si hay actualización forzada
  bool isForceUpdateEnabled() => getBool('manos_force_update');

  // Obtener mensaje de actualización
  String getUpdateMessage() => getString('manos_update_message');

  // Obtener mensaje de actualización forzada
  String getForceUpdateMessage() => getString('manos_force_update_message');
}
