// lib/screens/admin/add_product_screen.dart
import 'package:flutter/material.dart';
import '../../models/artisan.dart';
import '../../models/product.dart';
import '../../services/firestore_service.dart';
import '../../services/image_upload_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _precioController = TextEditingController();
  final _categoriaController = TextEditingController();
  final _pinController = TextEditingController();

  Artisan? _selectedArtisan;
  String? _fotoUrl;
  bool _isUploading = false;
  bool _isSaving = false;

  Future<void> _pickAndUploadImage() async {
    if (_selectedArtisan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona un artesano primero'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isUploading = true);
    try {
      // Usamos un ID temporal o basado en el tiempo para el nombre del archivo
      final tempId = DateTime.now().millisecondsSinceEpoch.toString();
      debugPrint(
        "Iniciando subida para artesano: ${_selectedArtisan!.id}, tempId: $tempId",
      );

      final url = await ImageUploadService.uploadProductImage(
        _selectedArtisan!.id,
        tempId,
      );

      if (url != null) {
        setState(() => _fotoUrl = url);
        debugPrint("Imagen subida con éxito: $url");
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('La subida fue cancelada o falló')),
          );
        }
      }
    } catch (e) {
      debugPrint("Error subiendo imagen: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al subir imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate() || _selectedArtisan == null) {
      if (_selectedArtisan == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecciona un artesano')),
        );
      }
      return;
    }

    if (_pinController.text != '1234') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN de seguridad incorrecto'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final String newId = "p${DateTime.now().millisecondsSinceEpoch}";

    final newProduct = Product(
      id: newId,
      artisanId: _selectedArtisan!.id,
      nombre: _nombreController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      precio: double.tryParse(_precioController.text) ?? 0.0,
      imagePath: _fotoUrl ?? '',
      categoria: _categoriaController.text.trim(),
    );

    try {
      await FirestoreService.addProduct(newProduct);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Producto guardado con éxito')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Añadir Nuevo Producto'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitle("Artesano Dueño"),
              StreamBuilder<List<Artisan>>(
                stream: FirestoreService.getArtisans(),
                builder: (context, snapshot) {
                  final artisans = snapshot.data ?? [];
                  return DropdownButtonFormField<String>(
                    value: _selectedArtisan?.id,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person, color: Colors.brown),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    hint: const Text("Selecciona el artesano"),
                    items: artisans.map((artisan) {
                      return DropdownMenuItem<String>(
                        value: artisan.id,
                        child: Text(artisan.nombre),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedArtisan = artisans.firstWhere(
                          (a) => a.id == value,
                        );
                        _fotoUrl = null;
                      });
                    },
                    validator: (value) =>
                        value == null ? "Selecciona un artesano" : null,
                  );
                },
              ),
              const SizedBox(height: 24),

              _buildSectionTitle("Foto del Producto"),
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.brown[50],
                        borderRadius: BorderRadius.circular(12),
                        image: _fotoUrl != null
                            ? DecorationImage(
                                image: NetworkImage(_fotoUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _fotoUrl == null && !_isUploading
                          ? const Icon(
                              Icons.image,
                              size: 60,
                              color: Colors.brown,
                            )
                          : null,
                    ),
                    if (_isUploading)
                      const Positioned.fill(
                        child: Center(
                          child: CircularProgressIndicator(color: Colors.brown),
                        ),
                      ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: FloatingActionButton.small(
                        onPressed: _isUploading ? null : _pickAndUploadImage,
                        child: const Icon(Icons.camera_alt),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              _buildSectionTitle("Detalles del Producto"),
              _buildTextField(
                _nombreController,
                "Nombre del Producto",
                Icons.shopping_bag,
              ),
              _buildTextField(
                _descripcionController,
                "Descripción",
                Icons.description,
                maxLines: 3,
              ),
              _buildTextField(
                _precioController,
                "Precio",
                Icons.attach_money,
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                _categoriaController,
                "Categoría",
                Icons.category,
              ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              _buildSectionTitle("Confirmación"),
              _buildTextField(
                _pinController,
                "PIN de Seguridad",
                Icons.lock,
                isPassword: true,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 40),
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProduct,
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
                          "GUARDAR PRODUCTO",
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
          if (value == null || value.trim().isEmpty) {
            return "Este campo es obligatorio";
          }
          return null;
        },
      ),
    );
  }
}
