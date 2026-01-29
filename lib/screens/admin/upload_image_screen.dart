// lib/screens/admin/upload_image_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/image_upload_service.dart';
import '../../services/firestore_service.dart';

enum ImageType { artisanProfile, product }

class UploadImageScreen extends StatefulWidget {
  final String? artisanId;
  final String? productId;

  const UploadImageScreen({super.key, this.artisanId, this.productId});

  @override
  State<UploadImageScreen> createState() => _UploadImageScreenState();
}

class _UploadImageScreenState extends State<UploadImageScreen> {
  bool _isUploading = false;
  String? _imageUrl;
  ImageType _selectedType = ImageType.artisanProfile;

  final TextEditingController _artisanIdController = TextEditingController();
  final TextEditingController _productIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.artisanId != null) {
      _artisanIdController.text = widget.artisanId!;
    }
    if (widget.productId != null) {
      _productIdController.text = widget.productId!;
      _selectedType = ImageType.product;
    }
  }

  @override
  void dispose() {
    _artisanIdController.dispose();
    _productIdController.dispose();
    super.dispose();
  }

  // --- FUNCIÓN HELPER PARA MOSTRAR MENSAJES ---
  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _uploadImage() async {
    final String artisanId = _artisanIdController.text.trim();
    final String productId = _productIdController.text.trim();

    if (artisanId.isEmpty) {
      _showSnack('Por favor, ingresa el ID del artesano');
      return;
    }

    if (_selectedType == ImageType.product && productId.isEmpty) {
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
        url = await ImageUploadService.uploadArtisanProfileImage(artisanId);
      } else {
        url = await ImageUploadService.uploadProductImage(artisanId, productId);
      }

      setState(() => _imageUrl = url);

      if (url != null) {
        if (_selectedType == ImageType.artisanProfile) {
          await FirestoreService.updateArtisanPhoto(artisanId, url);
        } else {
          await FirestoreService.updateProductPhoto(productId, url);
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
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // TARJETA DE DATOS
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Datos de Identificación:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // CAMPO ARTESANO
                        TextField(
                          controller: _artisanIdController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'ID del Artesano (ej: a1)',
                            prefixIcon: Icon(Icons.person),
                          ),
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
                      Clipboard.setData(ClipboardData(text: _imageUrl!)).then((
                        _,
                      ) {
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
        ),
      ),
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
