// lib/screens/admin/add_artisan_screen.dart
import 'package:flutter/material.dart';
import '../../models/artisan.dart';
import '../../services/firestore_service.dart';
import '../../services/image_upload_service.dart';
import '../../widgets/app_drawer.dart';

class AddArtisanScreen extends StatefulWidget {
  const AddArtisanScreen({super.key});

  @override
  State<AddArtisanScreen> createState() => _AddArtisanScreenState();
}

class _AddArtisanScreenState extends State<AddArtisanScreen> {
  final _formKey = GlobalKey<FormState>();
  static const String _adminCode = '4628';

  // Controladores
  final _nombreController = TextEditingController();
  final _historiaController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _ubicacionController = TextEditingController();
  final _direccionController = TextEditingController();
  final _localidadController = TextEditingController();
  final _cpController = TextEditingController();
  final _provinciaController = TextEditingController(text: 'Córdoba');
  final _instagramController = TextEditingController();
  final _facebookController = TextEditingController();

  String? _fotoUrl;
  bool _isUploading = false;
  bool _isSaving = false;

  Future<void> _pickAndUploadImage() async {
    setState(() => _isUploading = true);
    try {
      // Usamos un ID temporal para la carpeta de Storage
      final tempId = "new_${DateTime.now().millisecondsSinceEpoch}";
      final url = await ImageUploadService.uploadArtisanProfileImage(tempId);
      setState(() => _fotoUrl = url);
    } catch (e) {
      debugPrint("Error subiendo imagen: $e");
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _saveArtisan() async {
    if (!_formKey.currentState!.validate()) return;

    final isUnlocked = await _promptAdminCode();
    if (!isUnlocked) return;

    setState(() => _isSaving = true);

    // Generar ID único
    final String newId = "a${DateTime.now().millisecondsSinceEpoch}";

    final newArtisan = Artisan(
      id: newId,
      nombre: _nombreController.text.trim(),
      historia: _historiaController.text.trim(),
      fotoPerfil: _fotoUrl ?? '',
      telefono: _telefonoController.text.trim(),
      whatsapp: _whatsappController.text.trim(),
      ubicacion: _ubicacionController.text.trim(),
      direccion: _direccionController.text.trim(),
      localidad: _localidadController.text.trim(),
      codigoPostal: _cpController.text.trim(),
      provincia: _provinciaController.text.trim(),
      instagram: _instagramController.text.trim(),
      facebook: _facebookController.text.trim(),
    );

    try {
      await FirestoreService.addArtisan(newArtisan);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Artesano creado con éxito')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ Error al guardar: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<bool> _promptAdminCode() async {
    final controller = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Codigo de administracion'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Ingresar codigo',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              context,
              controller.text.trim() == _adminCode,
            ),
            child: const Text('Ingresar'),
          ),
        ],
      ),
    );

    if (!mounted) return false;

    if (result == true) {
      return true;
    }

    if (result == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Codigo incorrecto.'),
          backgroundColor: Colors.red,
        ),
      );
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Añadir Nuevo Artesano'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Foto de Perfil
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.brown[50],
                      backgroundImage: _fotoUrl != null
                          ? NetworkImage(_fotoUrl!)
                          : null,
                      child: _fotoUrl == null && !_isUploading
                          ? const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.brown,
                            )
                          : null,
                    ),
                    if (_isUploading)
                      const Positioned.fill(
                        child: CircularProgressIndicator(color: Colors.brown),
                      ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: FloatingActionButton.small(
                        onPressed: _isUploading ? null : _pickAndUploadImage,
                        child: const Icon(Icons.camera_alt),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              _buildSectionTitle("Información Personal"),
              _buildTextField(
                _nombreController,
                "Nombre Completo",
                Icons.person,
              ),
              _buildTextField(
                _historiaController,
                "Historia / Biografía",
                Icons.history,
                maxLines: 3,
              ),

              const SizedBox(height: 24),
              _buildSectionTitle("Ubicación"),
              _buildTextField(
                _localidadController,
                "Localidad",
                Icons.location_city,
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _cpController,
                      "C.P.",
                      Icons.mark_as_unread,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      _provinciaController,
                      "Provincia",
                      Icons.map,
                    ),
                  ),
                ],
              ),
              _buildTextField(
                _ubicacionController,
                "Barrio / Zona",
                Icons.place,
              ),
              _buildTextField(
                _direccionController,
                "Dirección (Opcional)",
                Icons.home,
              ),

              const SizedBox(height: 24),
              _buildSectionTitle("Contacto y Redes"),
              _buildTextField(
                _whatsappController,
                "WhatsApp (ej: 549351...)",
                Icons.chat,
                keyboardType: TextInputType.phone,
              ),
              _buildTextField(
                _telefonoController,
                "Teléfono Fijo (Opcional)",
                Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              _buildTextField(
                _instagramController,
                "Instagram (Usuario sin @)",
                Icons.camera_alt,
              ),
              _buildTextField(
                _facebookController,
                "Facebook (URL o Usuario)",
                Icons.facebook,
              ),

              const SizedBox(height: 32),
              const SizedBox(height: 40),
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveArtisan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "GUARDAR ARTESANO",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.brown[700],
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        obscureText: isPassword,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.brown),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        validator: (value) {
          if (!label.contains("Opcional") &&
              (value == null || value.trim().isEmpty)) {
            return "Este campo es obligatorio";
          }
          return null;
        },
      ),
    );
  }
}
