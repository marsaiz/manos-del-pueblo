import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/version_check_service.dart';

class UpdateDialog extends StatelessWidget {
  final VersionCheckResult result;

  const UpdateDialog({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final isForceUpdate = result.status == UpdateStatus.forceUpdate;

    return PopScope(
      canPop: !isForceUpdate, // No permitir cerrar si es actualización forzada
      child: AlertDialog(
        title: Row(
          children: [
            Icon(
              isForceUpdate ? Icons.warning : Icons.info_outline,
              color: isForceUpdate ? Colors.red : Colors.orange,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isForceUpdate ? 'Actualización Requerida' : 'Actualización Disponible',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(result.message),
            const SizedBox(height: 16),
            Text(
              'Versión actual: ${result.currentVersion}',
              style: const TextStyle(fontSize: 12, color: Color(0xFF616161)),
            ),
            Text(
              'Versión disponible: ${result.latestVersion}',
              style: const TextStyle(fontSize: 12, color: Color(0xFF616161)),
            ),
          ],
        ),
        actions: [
          if (!isForceUpdate)
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Más tarde'),
            ),
          ElevatedButton(
            onPressed: () => _openStore(result.storeUrl),
            style: ElevatedButton.styleFrom(
              backgroundColor: isForceUpdate ? Colors.red : Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  Future<void> _openStore(String? storeUrl) async {
    if (storeUrl == null || storeUrl.isEmpty) {
      debugPrint('URL de la tienda no configurada');
      return;
    }

    final uri = Uri.parse(storeUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('No se pudo abrir la URL: $storeUrl');
    }
  }
}
