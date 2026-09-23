import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/fair.dart';
import '../../services/firestore_service.dart';
import '../../services/image_upload_service.dart';
import '../../services/pin_service.dart';

class AddEditFairScreen extends StatefulWidget {
  final Fair? fair;

  const AddEditFairScreen({super.key, this.fair});

  @override
  State<AddEditFairScreen> createState() => _AddEditFairScreenState();
}

class _AddEditFairScreenState extends State<AddEditFairScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _organizerController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late TextEditingController _scheduleController;
  late TextEditingController _locationController;
  late TextEditingController _imageUrlController;
  late TextEditingController _whatsappController;
  late TextEditingController _entryFeeController;
  late TextEditingController _pinController;

  bool _isFinished = false;
  
  bool _isLoading = false;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.fair?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.fair?.description ?? '',
    );
    _organizerController = TextEditingController(
      text: widget.fair?.organizer ?? '',
    );
    _startDateController = TextEditingController(
      text: widget.fair?.startDate ?? '',
    );
    _endDateController = TextEditingController(
      text: widget.fair?.endDate ?? '',
    );
    _scheduleController = TextEditingController(
      text: widget.fair?.schedule ?? '',
    );
    _locationController = TextEditingController(
      text: widget.fair?.location ?? '',
    );
    _imageUrlController = TextEditingController(
      text: widget.fair?.imageUrl ?? '',
    );
    _whatsappController = TextEditingController(
      text: widget.fair?.contactWhatsApp ?? '',
    );
    _entryFeeController = TextEditingController(text: widget.fair?.entryFee ?? '');
    _pinController = TextEditingController();
    _isFinished = widget.fair?.isFinished ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _organizerController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _scheduleController.dispose();
    _locationController.dispose();
    _imageUrlController.dispose();
    _whatsappController.dispose();
    _entryFeeController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    final oldImageUrl = _imageUrlController.text;
    
    setState(() => _isUploadingImage = true);
    try {
      final url = await ImageUploadService.uploadProductImage(
        'admin',
        'fair_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (url != null) {
        setState(() => _imageUrlController.text = url);
        
        if (oldImageUrl.isNotEmpty && oldImageUrl.startsWith('http')) {
          try {
            await ImageUploadService.deleteImage(oldImageUrl);
          } catch (e) {
            debugPrint("⚠️ Error al eliminar imagen anterior: $e");
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al subir imagen: $e')));
      }
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  Future<void> _saveFair() async {
    if (!_formKey.currentState!.validate()) return;

    final correctPin = await PinService.getPin('admin_access');
    
    if (_pinController.text != correctPin) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PIN de seguridad incorrecto'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    final fair = Fair(
      id: widget.fair?.id ?? const Uuid().v4(),
      title: _titleController.text,
      description: _descriptionController.text,
      organizer: _organizerController.text,
      startDate: _startDateController.text,
      endDate: _endDateController.text,
      schedule: _scheduleController.text,
      location: _locationController.text,
      imageUrl: _imageUrlController.text,
      contactWhatsApp: _whatsappController.text,
      entryFee: _entryFeeController.text,
      isFinished: _isFinished,
    );

    try {
      if (widget.fair == null) {
        await FirestoreService.addFair(fair);
      } else {
        await FirestoreService.updateFair(fair);
      }
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fair == null ? 'Nueva Feria' : 'Editar Feria'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                  children: [
                    _buildImageSection(),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de la Feria',
                      ),
                      validator: (value) => value!.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                      ),
                      maxLines: 3,
                      validator: (value) => value!.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _organizerController,
                      decoration: const InputDecoration(
                        labelText: 'Organizador',
                      ),
                      validator: (value) => value!.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _startDateController,
                      decoration: const InputDecoration(
                        labelText: 'Fecha de Inicio (ej: 12 de Octubre)',
                      ),
                      validator: (value) => value!.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _endDateController,
                      decoration: const InputDecoration(
                        labelText: 'Fecha de Fin (opcional)',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _scheduleController,
                      decoration: const InputDecoration(
                        labelText: 'Horarios (ej: 10:00 a 18:00)',
                      ),
                      validator: (value) => value!.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(labelText: 'Ubicación'),
                      validator: (value) => value!.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _entryFeeController,
                      decoration: const InputDecoration(
                        labelText: 'Entrada (Ej: Gratis o \$500)',
                      ),
                      validator: (value) => value!.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _whatsappController,
                      decoration: const InputDecoration(
                        labelText: 'WhatsApp (sin +, ej: 54911...)',
                      ),
                      validator: (value) => value!.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Marcar como Finalizada'),
                      subtitle: const Text('Mueve la feria a la sección de eventos pasados'),
                      value: _isFinished,
                      onChanged: (bool value) {
                        setState(() {
                          _isFinished = value;
                        });
                      },
                      activeColor: Colors.brown,
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    const Text(
                      'Confirmación',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _pinController,
                      decoration: const InputDecoration(
                        labelText: 'PIN de Seguridad',
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _saveFair,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: Text(
                        widget.fair == null ? 'Crear' : 'Guardar Cambios',
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildImageSection() {
    final hasImage = _imageUrlController.text.isNotEmpty;
    return GestureDetector(
      onTap: _isUploadingImage ? null : _pickAndUploadImage,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.brown[50],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.brown[200]!),
          image: hasImage
              ? DecorationImage(
                  image: NetworkImage(_imageUrlController.text),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: Stack(
          children: [
            if (!hasImage && !_isUploadingImage)
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo, color: Colors.brown, size: 50),
                    SizedBox(height: 8),
                    Text(
                      'Toca para subir imagen',
                      style: TextStyle(color: Colors.brown),
                    ),
                  ],
                ),
              ),
            if (_isUploadingImage)
              const Center(
                child: CircularProgressIndicator(color: Colors.brown),
              ),
            if (hasImage && !_isUploadingImage)
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Cambiar imagen',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
