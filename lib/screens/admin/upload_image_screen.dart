// lib/screens/admin/upload_image_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/artisan.dart';
import '../../services/image_upload_service.dart';
import '../../services/firestore_service.dart';

enum ImageType { artisanProfile, product }

class UploadImageScreen extends StatefulWidget {
  const UploadImageScreen({super.key});

  @override
  State<UploadImageScreen> createState() => _UploadImageScreenState();
}

class _UploadImageScreenState extends State<UploadImageScreen> {
  bool _isUploading = false;
  String? _imageUrl;
  ImageType _selectedType = ImageType.artisanProfile;
  bool _isPinVerified = false;

  Artisan? _selectedArtisan;
  final TextEditingController _productIdController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  @override
  void dispose() {
    _productIdController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _verifyPin() {
    if (_pinController.text == '4628') {
      setState(() => _isPinVerified = true);
      _showSnack('✅ PIN correcto');
    } else {
      _showSnack('❌ PIN incorrecto');
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedArtisan == null) {
      _showSnack('Por favor, selecciona un artesano');
      return;
    }

    if (_selectedType == ImageType.product &&
        _productIdController.text.trim().isEmpty) {
      _showSnack('Por favor, ingresa el ID del producto');
      return;
    }

    setState(() {
      _isUploading = true;
      _imageUrl = null;
    });

    try {
      String? url;
      if (_selectedType == ImageType.artisanProfile) {
        url = await ImageUploadService.uploadArtisanProfileImage(
          _selectedArtisan!.id,
        );
      } else {
        url = await ImageUploadService.uploadProductImage(
          _selectedArtisan!.id,
          _productIdController.text.trim(),
        );
      }

      setState(() => _imageUrl = url);

      if (url != null) {
        if (_selectedType == ImageType.artisanProfile) {
          await FirestoreService.updateArtisanPhoto(_selectedArtisan!.id, url);
        } else {
          await FirestoreService.updateProductPhoto(
            _productIdController.text.trim(),
            url,
          );
        }
        _showSnack('¡Imagen subida y base de datos actualizada!');
      }
    } catch (e) {
      _showSnack('Error al subir la imagen: $e');
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subir Imágenes')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: !_isPinVerified
            ? _buildPinVerification()
            : _buildUploadInterface(),
      ),
    );
  }

  Widget _buildPinVerification() {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock, size: 60, color: Colors.brown),
              const SizedBox(height: 20),
              const Text(
                'Verificación de Seguridad',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _pinController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'PIN de Administrador',
                  prefixIcon: Icon(Icons.password),
                ),
                keyboardType: TextInputType.number,
                obscureText: true,
                onSubmitted: (_) => _verifyPin(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _verifyPin,
                child: const Text('VERIFICAR'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadInterface() {
    return StreamBuilder<List<Artisan>>(
      stream: FirestoreService.getArtisans(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final artisans = snapshot.data!;

        return Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // SELECTOR DE ARTESANO
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selecciona el Artesano:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<Artisan>(
                          value: _selectedArtisan,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                          hint: const Text('Selecciona un artesano'),
                          items: artisans.map((artisan) {
                            return DropdownMenuItem<Artisan>(
                              value: artisan,
                              child: Text(
                                '${artisan.nombre} (${artisan.id})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedArtisan = value);
                          },
                        ),

                        // CAMPO PRODUCTO (Visible solo si es tipo producto)
                        if (_selectedType == ImageType.product) ...[
                          const SizedBox(height: 15),
                          TextField(
                            controller: _productIdController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'ID del Producto (ej: p1)',
                              hintText: 'El ID que tiene en la base de datos',
                              prefixIcon: Icon(Icons.shopping_bag),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // SELECTOR DE TIPO
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Tipo de imagen:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildTypeSelector(
                              'Perfil',
                              ImageType.artisanProfile,
                            ),
                            const SizedBox(width: 20),
                            _buildTypeSelector('Producto', ImageType.product),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // BOTÓN SUBIR
                ElevatedButton(
                  onPressed: _isUploading ? null : _uploadImage,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: _isUploading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Seleccionar y Subir Imagen'),
                ),

                // VISTA PREVIA Y URL
                if (_imageUrl != null) ...[
                  const SizedBox(height: 30),
                  const Text(
                    'Vista previa:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Image.network(_imageUrl!, height: 200),
                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: SelectableText(
                      _imageUrl!,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 10),

                  ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _imageUrl!))
                          .then((_) {
                        _showSnack('URL copiada al portapapeles');
                      });
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Copiar URL'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTypeSelector(String label, ImageType type) {
    final isSelected = _selectedType == type;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _selectedType = type);
      },
      selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
      backgroundColor: Colors.grey[200],
    );
  }
}
