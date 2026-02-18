import 'package:flutter/material.dart';

/// Diálogo para solicitar PIN de seguridad
class PinDialog extends StatefulWidget {
  final String title;
  final String message;
  final String correctPin;
  final VoidCallback onSuccess;

  const PinDialog({
    super.key,
    required this.title,
    required this.message,
    required this.correctPin,
    required this.onSuccess,
  });

  @override
  State<PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<PinDialog> {
  final _pinController = TextEditingController();
  final bool _isLoading = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _verifyPin() {
    final pin = _pinController.text;

    if (pin != widget.correctPin) {
      // PIN incorrecto
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN incorrecto'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      _pinController.clear();
      return;
    }

    // PIN correcto
    Navigator.pop(context);
    widget.onSuccess();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.message),
          const SizedBox(height: 16),
          const Text(
            'Ingresa el PIN de seguridad:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _pinController,
            keyboardType: TextInputType.number,
            maxLength: 4,
            obscureText: true,
            autofocus: true,
            enabled: !_isLoading,
            decoration: const InputDecoration(
              hintText: 'PIN de 4 dígitos',
              border: OutlineInputBorder(),
              counterText: '',
              prefixIcon: Icon(Icons.lock),
            ),
            onSubmitted: (_) => _verifyPin(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: _isLoading ? null : _verifyPin,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Verificar', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}

/// Función helper para mostrar el diálogo de PIN
Future<void> showPinDialog({
  required BuildContext context,
  required String title,
  required String message,
  String correctPin = '4628',
  required Future<void> Function() onConfirm,
}) async {
  return showDialog(
    context: context,
    builder: (context) => PinDialog(
      title: title,
      message: message,
      correctPin: correctPin,
      onSuccess: () async {
        try {
          await onConfirm();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Operación completada correctamente'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
    ),
  );
}
