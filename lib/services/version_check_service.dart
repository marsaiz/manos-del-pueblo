import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'remote_config_service.dart';

enum UpdateStatus {
  upToDate,
  updateAvailable,
  forceUpdate,
}

class VersionCheckResult {
  final UpdateStatus status;
  final String currentVersion;
  final String latestVersion;
  final String message;
  final String? storeUrl;

  VersionCheckResult({
    required this.status,
    required this.currentVersion,
    required this.latestVersion,
    required this.message,
    this.storeUrl,
  });
}

class VersionCheckService {
  final RemoteConfigService _remoteConfig = RemoteConfigService();

  Future<VersionCheckResult> checkVersion() async {
    try {
      // Obtener versión actual de la app
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      // Obtener versiones desde Remote Config
      final minVersion = _remoteConfig.getMinVersion();
      final latestVersion = _remoteConfig.getLatestVersion();
      final forceUpdate = _remoteConfig.isForceUpdateEnabled();

      // Comparar versiones
      final isOutdated = _compareVersions(currentVersion, minVersion) < 0;
      final hasUpdate = _compareVersions(currentVersion, latestVersion) < 0;

      if (isOutdated || forceUpdate) {
        // Actualización obligatoria
        return VersionCheckResult(
          status: UpdateStatus.forceUpdate,
          currentVersion: currentVersion,
          latestVersion: latestVersion,
          message: _remoteConfig.getForceUpdateMessage(),
          storeUrl: _remoteConfig.getStoreUrl(),
        );
      } else if (hasUpdate) {
        // Actualización opcional disponible
        return VersionCheckResult(
          status: UpdateStatus.updateAvailable,
          currentVersion: currentVersion,
          latestVersion: latestVersion,
          message: _remoteConfig.getUpdateMessage(),
          storeUrl: _remoteConfig.getStoreUrl(),
        );
      } else {
        // App actualizada
        return VersionCheckResult(
          status: UpdateStatus.upToDate,
          currentVersion: currentVersion,
          latestVersion: latestVersion,
          message: 'La aplicación está actualizada',
        );
      }
    } catch (e) {
      debugPrint('Error al verificar versión: $e');
      // En caso de error, permitir continuar
      return VersionCheckResult(
        status: UpdateStatus.upToDate,
        currentVersion: '0.0.0',
        latestVersion: '0.0.0',
        message: 'No se pudo verificar la versión',
      );
    }
  }

  /// Compara dos versiones en formato semántico (x.y.z)
  /// Retorna: -1 si v1 < v2, 0 si v1 == v2, 1 si v1 > v2
  int _compareVersions(String v1, String v2) {
    final parts1 = v1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final parts2 = v2.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    // Asegurar que ambas listas tengan 3 elementos
    while (parts1.length < 3) {
      parts1.add(0);
    }
    while (parts2.length < 3) {
      parts2.add(0);
    }

    for (int i = 0; i < 3; i++) {
      if (parts1[i] < parts2[i]) return -1;
      if (parts1[i] > parts2[i]) return 1;
    }

    return 0;
  }
}
