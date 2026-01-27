// lib/screens/admin/upload_image_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/image_upload_service.dart';
import '../../services/firestore_service.dart';

enum ImageType { artisanProfile, product }

class UploadImageScreen extends StatefulWidget {
  final String? artisanId; // Necesario para subir imágenes de productos

  const UploadImageScreen({super.key, this.artisanId});

  @override
  State<UploadImageScreen> createState() => _UploadImageScreenState();
}

class _UploadImageScreenState extends State<UploadImageScreen> {
  bool _isUploading = false;
  String? _imageUrl;
  ImageType _selectedType = ImageType.artisanProfile;
  final TextEditingController _artisanIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.artisanId != null) {
      _artisanIdController.text = widget.artisanId!;
    }
  }

  @override
  void dispose() {
    _artisanIdController.dispose();
    super.dispose();
  }

  Future<void> _uploadImage() async {
    final String artisanId = _artisanIdController.text.trim();

    if (artisanId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, ingresa el ID del artesano'),
          ),
        );
      }
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
        url = await ImageUploadService.uploadProductImage(artisanId);
      }

      setState(() {
        _imageUrl = url;
      });

      if (!mounted) return;
      if (url != null) {
        // --- ACTUALIZACIÓN DINÁMICA EN FIRESTORE ---
        if (_selectedType == ImageType.artisanProfile) {
          await FirestoreService.updateArtisanPhoto(artisanId, url);
        } else {
          // Si es producto, intentamos actualizar si el ID cargado es de un producto.
          // Nota: Aquí se asume que el usuario ingresó el ID del producto si eligió "Producto".
          // En una versión más pro, podrías pedir el ID del producto específicamente.
          await FirestoreService.updateProductPhoto(artisanId, url);
        }
        // -------------------------------------------

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Imagen subida y base de datos actualizada!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al subir la imagen: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
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
                // ID del Artesano
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Identificación del Artesano:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _artisanIdController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'ID del Artesano (ej: a1)',
                            hintText: 'Ingresa el ID secreto del artesano',
                            prefixIcon: Icon(Icons.vpn_key),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Selector de tipo de imagen
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
                              'Perfil de Artesano',
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
                // Botón de subida
                ElevatedButton(
                  onPressed: _isUploading ? null : _uploadImage,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: _isUploading
                      ? const CircularProgressIndicator()
                      : const Text('Seleccionar y Subir Imagen'),
                ),
                // Vista previa de la imagen subida
                if (_imageUrl != null) ...[
                  const SizedBox(height: 30),
                  const Text(
                    'Vista previa:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Image.network(_imageUrl!, height: 200),
                  const SizedBox(height: 20),
                  // URL de la imagen
                  const Text(
                    'URL de la imagen:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
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
                  const SizedBox(height: 20),
                  // Botón para copiar la URL
                  ElevatedButton.icon(
                    onPressed: () {
                      // Copiar URL al portapapeles nativo
                      Clipboard.setData(ClipboardData(text: _imageUrl!)).then((
                        _,
                      ) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('URL copiada al portapapeles'),
                            ),
                          );
                        }
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
        if (selected) {
          setState(() {
            _selectedType = type;
          });
        }
      },
      selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
      backgroundColor: Colors.grey[200],
      labelStyle: TextStyle(
        color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
