// lib/screens/admin/add_artisan_screen.dart
import 'package:flutter/material.dart';
import '../../models/artisan.dart';
import '../../services/firestore_service.dart';
import '../../services/image_upload_service.dart';
import '../../services/pin_service.dart';

class AddArtisanScreen extends StatefulWidget {
  const AddArtisanScreen({super.key});

  @override
  State<AddArtisanScreen> createState() => _AddArtisanScreenState();
}

class _AddArtisanScreenState extends State<AddArtisanScreen> {
  final _formKey = GlobalKey<FormState>();

  // Generar ID único al inicio
  late final String _artisanId;

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

  bool _isPinVerified = false;
  final _pinController = TextEditingController();

  String? _fotoUrl;
  bool _isUploading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Generar ID único al inicializar
    _artisanId = "a${DateTime.now().millisecondsSinceEpoch}";
  }

  Future<void> _pickAndUploadImage() async {
    setState(() => _isUploading = true);
    try {
      // Usar el ID real del artesano para la carpeta de Storage
      final url = await ImageUploadService.uploadArtisanProfileImage(_artisanId);
      setState(() => _fotoUrl = url);
    } catch (e) {
      debugPrint("Error subiendo imagen: $e");
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _saveArtisan() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    // Usar el ID generado al inicio
    final newArtisan = Artisan(
      id: _artisanId,
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

  Future<void> _verifyPin() async {
    final correctPin = await PinService.getPin('admin_access');
    
    if (_pinController.text.trim() == correctPin) {
      setState(() => _isPinVerified = true);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PIN incorrecto'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildPinGate() {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_person, size: 60, color: Colors.brown),
              const SizedBox(height: 20),
              const Text(
                'Acceso Administrativo',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _pinController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Ingresar PIN',
                  prefixIcon: Icon(Icons.password),
                ),
                keyboardType: TextInputType.number,
                obscureText: true,
                onSubmitted: (_) => _verifyPin(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _verifyPin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  foregroundColor: Colors.white,
                ),
                child: const Text('VERIFICAR'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Añadir Nuevo Artesano'), elevation: 0),
      body: !_isPinVerified
          ? _buildPinGate()
          : SingleChildScrollView(
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
                              child: CircularProgressIndicator(
                                color: Colors.brown,
                              ),
                            ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: FloatingActionButton.small(
                              onPressed: _isUploading
                                  ? null
                                  : _pickAndUploadImage,
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
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
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
