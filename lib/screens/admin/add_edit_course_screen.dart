import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/course.dart';
import '../../services/firestore_service.dart';
import '../../services/image_upload_service.dart';

class AddEditCourseScreen extends StatefulWidget {
  final Course? course;

  const AddEditCourseScreen({super.key, this.course});

  @override
  State<AddEditCourseScreen> createState() => _AddEditCourseScreenState();
}

class _AddEditCourseScreenState extends State<AddEditCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _instructorController;
  late TextEditingController _scheduleController;
  late TextEditingController _locationController;
  late TextEditingController _imageUrlController;
  late TextEditingController _whatsappController;
  late TextEditingController _priceController;
  late TextEditingController _pinController;

  bool _isLoading = false;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.course?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.course?.description ?? '',
    );
    _instructorController = TextEditingController(
      text: widget.course?.instructor ?? '',
    );
    _scheduleController = TextEditingController(
      text: widget.course?.schedule ?? '',
    );
    _locationController = TextEditingController(
      text: widget.course?.location ?? '',
    );
    _imageUrlController = TextEditingController(
      text: widget.course?.imageUrl ?? '',
    );
    _whatsappController = TextEditingController(
      text: widget.course?.contactWhatsApp ?? '',
    );
    _priceController = TextEditingController(text: widget.course?.price ?? '');
    _pinController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _instructorController.dispose();
    _scheduleController.dispose();
    _locationController.dispose();
    _imageUrlController.dispose();
    _whatsappController.dispose();
    _priceController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    setState(() => _isUploadingImage = true);
    try {
      // Usamos una carpeta específica para cursos
      final url = await ImageUploadService.uploadProductImage(
        'admin', // Usamos 'admin' como ID de artesano para cursos generales
        'course_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (url != null) {
        setState(() => _imageUrlController.text = url);
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

  Future<void> _saveCourse() async {
    if (!_formKey.currentState!.validate()) return;

    if (_pinController.text != '4628') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN de seguridad incorrecto'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final course = Course(
      id: widget.course?.id ?? const Uuid().v4(),
      title: _titleController.text,
      description: _descriptionController.text,
      instructor: _instructorController.text,
      schedule: _scheduleController.text,
      location: _locationController.text,
      imageUrl: _imageUrlController.text,
      contactWhatsApp: _whatsappController.text,
      price: _priceController.text,
    );

    try {
      if (widget.course == null) {
        await FirestoreService.addCourse(course);
      } else {
        await FirestoreService.updateCourse(course);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course == null ? 'Nuevo Curso' : 'Editar Curso'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                        labelText: 'Título del Curso',
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
                      controller: _instructorController,
                      decoration: const InputDecoration(
                        labelText: 'Instructor',
                      ),
                      validator: (value) => value!.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _scheduleController,
                      decoration: const InputDecoration(
                        labelText: 'Horarios (ej: Lunes 10:00)',
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
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Precio (Ej: 5000 o "Consultar")',
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
                      onPressed: _saveCourse,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: Text(
                        widget.course == null ? 'Crear' : 'Guardar Cambios',
                      ),
                    ),
                  ],
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
