// lib/screens/admin/edit_artisan_screen.dart
import 'package:flutter/material.dart';
import '../../models/artisan.dart';
import '../../services/firestore_service.dart';
import '../../services/image_upload_service.dart';
import '../../services/pin_service.dart';
import '../../widgets/pin_dialog.dart';

class EditArtisanScreen extends StatefulWidget {
  final Artisan artisan;
  
  const EditArtisanScreen({super.key, required this.artisan});

  @override
  State<EditArtisanScreen> createState() => _EditArtisanScreenState();
}

class _EditArtisanScreenState extends State<EditArtisanScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  late TextEditingController _nombreController;
  late TextEditingController _historiaController;
  late TextEditingController _telefonoController;
  late TextEditingController _whatsappController;
  late TextEditingController _ubicacionController;
  late TextEditingController _direccionController;
  late TextEditingController _localidadController;
  late TextEditingController _cpController;
  late TextEditingController _provinciaController;
  late TextEditingController _instagramController;
  late TextEditingController _facebookController;

  String? _fotoUrl;
  bool _isUploading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Inicializar controladores con los datos del artesano
    _nombreController = TextEditingController(text: widget.artisan.nombre);
    _historiaController = TextEditingController(text: widget.artisan.historia);
    _telefonoController = TextEditingController(text: widget.artisan.telefono);
    _whatsappController = TextEditingController(text: widget.artisan.whatsapp);
    _ubicacionController = TextEditingController(text: widget.artisan.ubicacion);
    _direccionController = TextEditingController(text: widget.artisan.direccion);
    _localidadController = TextEditingController(text: widget.artisan.localidad);
    _cpController = TextEditingController(text: widget.artisan.codigoPostal);
    _provinciaController = TextEditingController(text: widget.artisan.provincia);
    _instagramController = TextEditingController(text: widget.artisan.instagram);
    _facebookController = TextEditingController(text: widget.artisan.facebook);
    
    _fotoUrl = widget.artisan.fotoPerfil;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _historiaController.dispose();
    _telefonoController.dispose();
    _whatsappController.dispose();
    _ubicacionController.dispose();
    _direccionController.dispose();
    _localidadController.dispose();
    _cpController.dispose();
    _provinciaController.dispose();
    _instagramController.dispose();
    _facebookController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    // Guardar la URL anterior
    final oldPhotoUrl = _fotoUrl;
    
    setState(() => _isUploading = true);
    try {
      final url = await ImageUploadService.uploadArtisanProfileImage(widget.artisan.id);
      
      if (url != null) {
        setState(() => _fotoUrl = url);
        
        // Eliminar la foto anterior si existía y era de Firebase
        if (oldPhotoUrl != null && 
            oldPhotoUrl.isNotEmpty && 
            oldPhotoUrl.startsWith('http') &&
            oldPhotoUrl != url) {
          try {
            await ImageUploadService.deleteImage(oldPhotoUrl);
            debugPrint("✅ Foto de perfil anterior eliminada: $oldPhotoUrl");
          } catch (e) {
            debugPrint("⚠️ Error al eliminar foto anterior: $e");
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir imagen: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _updateArtisan() async {
    if (!_formKey.currentState!.validate()) return;

    final adminPin = await PinService.getPin('admin_access');
    
    if (!mounted) return;

    showPinDialog(
      context: context,
      title: 'Confirmar Actualización',
      message: '¿Deseas actualizar los datos de este artesano?',
      correctPin: adminPin,
      onConfirm: () async {
        await _performUpdate();
      },
    );
  }

  Future<void> _performUpdate() async {
    setState(() => _isSaving = true);

    final updatedArtisan = Artisan(
      id: widget.artisan.id,
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
      await FirestoreService.updateArtisan(updatedArtisan);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Artesano actualizado con éxito')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error al actualizar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Artesano'),
        elevation: 0,
      ),
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
                      backgroundImage: _fotoUrl != null && _fotoUrl!.startsWith('http')
                          ? NetworkImage(_fotoUrl!)
                          : null,
                      child: _fotoUrl == null || !_fotoUrl!.startsWith('http')
                          ? const Icon(Icons.person, size: 60, color: Colors.brown)
                          : null,
                    ),
                    if (_isUploading)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          ),
                        ),
                      ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _isUploading ? null : _pickAndUploadImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.brown,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              _buildSectionTitle("Información Personal"),
              _buildTextField(_nombreController, "Nombre Completo", Icons.person),
              _buildTextField(
                _historiaController,
                "Historia del Artesano",
                Icons.history_edu,
                maxLines: 4,
              ),

              const SizedBox(height: 24),
              _buildSectionTitle("Contacto"),
              _buildTextField(_telefonoController, "Teléfono", Icons.phone),
              _buildTextField(_whatsappController, "WhatsApp", Icons.chat),
              _buildTextField(_instagramController, "Instagram", Icons.camera_alt),
              _buildTextField(_facebookController, "Facebook", Icons.facebook),

              const SizedBox(height: 24),
              _buildSectionTitle("Ubicación"),
              _buildTextField(_direccionController, "Dirección", Icons.home),
              _buildTextField(_localidadController, "Localidad", Icons.location_city),
              _buildTextField(_cpController, "Código Postal", Icons.markunread_mailbox),
              _buildTextField(_provinciaController, "Provincia", Icons.map),
              _buildTextField(_ubicacionController, "Ubicación (Coordenadas)", Icons.place),

              const SizedBox(height: 40),
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _updateArtisan,
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
                          "ACTUALIZAR ARTESANO",
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
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.brown),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "Este campo es obligatorio";
          }
          return null;
        },
      ),
    );
  }
}
