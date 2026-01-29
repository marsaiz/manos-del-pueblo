// lib/screens/admin/edit_product_screen.dart
import 'package:flutter/material.dart';
import '../../models/artisan.dart';
import '../../models/product.dart';
import '../../services/firestore_service.dart';
import '../../services/image_upload_service.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;
  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  late TextEditingController _precioController;
  late TextEditingController _customCategoriaController;
  final _pinController = TextEditingController();

  final List<String> _categorias = [
    'Indumentaria',
    'Herramientas',
    'Juguetes',
    'Hogar',
    'Deco',
    'Cocina',
    'Alimentos',
    'Bebidas',
    'Utensilios',
    'Joyería',
    'Útiles Escolares',
    'Otros',
  ];

  Artisan? _selectedArtisan;
  String? _selectedCategoria;
  String? _fotoUrl;
  bool _isUploading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.product.nombre);
    _descripcionController = TextEditingController(
      text: widget.product.descripcion,
    );
    _precioController = TextEditingController(text: widget.product.precio);
    _fotoUrl = widget.product.imagePath;

    if (_categorias.contains(widget.product.categoria)) {
      _selectedCategoria = widget.product.categoria;
      _customCategoriaController = TextEditingController();
    } else {
      _selectedCategoria = 'Otro...';
      _customCategoriaController = TextEditingController(
        text: widget.product.categoria,
      );
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    _customCategoriaController.dispose();
    _pinController.dispose();
    super.dispose();
  }

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
      final tempId = DateTime.now().millisecondsSinceEpoch.toString();
      final url = await ImageUploadService.uploadProductImage(
        _selectedArtisan!.id,
        tempId,
      );

      if (url != null) {
        setState(() => _fotoUrl = url);
      }
    } catch (e) {
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

  Future<void> _updateProduct() async {
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

    final String finalCategoria =
        _selectedCategoria == 'Otro...' || _selectedCategoria == 'Otros'
        ? _customCategoriaController.text.trim()
        : _selectedCategoria ?? '';

    final updatedProduct = Product(
      id: widget.product.id,
      artisanId: _selectedArtisan!.id,
      nombre: _nombreController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      precio: _precioController.text.trim(),
      imagePath: _fotoUrl ?? widget.product.imagePath,
      categoria: finalCategoria,
    );

    try {
      await FirestoreService.updateProduct(updatedProduct);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Producto actualizado con éxito')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ Error al actualizar: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Producto'), elevation: 0),
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

                  // Intentamos encontrar el artesano actual si aún no está seleccionado
                  if (_selectedArtisan == null && artisans.isNotEmpty) {
                    try {
                      _selectedArtisan = artisans.firstWhere(
                        (a) => a.id == widget.product.artisanId,
                      );
                    } catch (_) {
                      // Si no existe, dejamos que el usuario elija
                    }
                  }

                  return DropdownButtonFormField<String>(
                    initialValue: _selectedArtisan?.id,
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
                        image: _fotoUrl != null && _fotoUrl!.isNotEmpty
                            ? DecorationImage(
                                image: _fotoUrl!.startsWith('http')
                                    ? NetworkImage(_fotoUrl!)
                                    : AssetImage(_fotoUrl!) as ImageProvider,
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child:
                          (_fotoUrl == null || _fotoUrl!.isEmpty) &&
                              !_isUploading
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
              _buildTextField(_precioController, "Precio", Icons.attach_money),

              _buildSectionTitle("Categoría"),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategoria,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.category, color: Colors.brown),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                hint: const Text("Selecciona una categoría"),
                items: [..._categorias].map((categoria) {
                  return DropdownMenuItem<String>(
                    value: categoria,
                    child: Text(categoria),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoria = value;
                  });
                },
                validator: (value) =>
                    value == null ? "Selecciona una categoría" : null,
              ),

              if (_selectedCategoria == 'Otro...' ||
                  _selectedCategoria == 'Otros') ...[
                const SizedBox(height: 16),
                _buildTextField(
                  _customCategoriaController,
                  "Especificar Categoría",
                  Icons.edit_note,
                ),
              ],

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
                  onPressed: _isSaving ? null : _updateProduct,
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
                          "ACTUALIZAR PRODUCTO",
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
      padding: const EdgeInsets.only(bottom: 16, top: 16),
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
