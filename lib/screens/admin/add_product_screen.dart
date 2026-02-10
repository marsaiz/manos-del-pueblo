// lib/screens/admin/add_product_screen.dart
import 'package:flutter/material.dart';
import '../../models/artisan.dart';
import '../../models/product.dart';
import '../../services/firestore_service.dart';
import '../../services/image_upload_service.dart';
import '../../widgets/app_drawer.dart';

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
  final _customCategoriaController = TextEditingController();
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
    'Jardinería',
    'Instrumentos Musicales',
    'Otros',
  ];

  Artisan? _selectedArtisan;
  String? _selectedCategoria;

  // Lista fija de 3 posiciones para las URLs de las fotos
  final List<String?> _fotoUrls = [null, null, null];
  final List<bool> _isUploadingList = [false, false, false];

  bool _isSaving = false;

  Future<void> _pickAndUploadImage(int index) async {
    if (_selectedArtisan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona un artesano primero'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isUploadingList[index] = true);
    try {
      final tempId = "${DateTime.now().millisecondsSinceEpoch}_$index";
      final url = await ImageUploadService.uploadProductImage(
        _selectedArtisan!.id,
        tempId,
      );

      if (url != null) {
        setState(() => _fotoUrls[index] = url);
        debugPrint("Imagen $index subida con éxito: $url");
      }
    } catch (e) {
      debugPrint("Error subiendo imagen $index: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al subir imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingList[index] = false);
    }
  }

  void _removeImage(int index) {
    setState(() {
      _fotoUrls[index] = null;
    });
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

    final String finalCategoria = _selectedCategoria == 'Otro...'
        ? _customCategoriaController.text.trim()
        : _selectedCategoria ?? '';

    final String newId = "p${DateTime.now().millisecondsSinceEpoch}";

    // Filtramos las URLs nulas para guardar solo las válidas
    final List<String> validUrls = _fotoUrls.whereType<String>().toList();

    final newProduct = Product(
      id: newId,
      artisanId: _selectedArtisan!.id,
      nombre: _nombreController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      precio: _precioController.text.trim(),
      imagePaths: validUrls, // Ahora pasamos la lista
      categoria: finalCategoria,
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
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    _customCategoriaController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
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
                        // Reiniciar fotos al cambiar de artesano para evitar mezclar carpetas
                        for (int i = 0; i < 3; i++) {
                          _fotoUrls[i] = null;
                        }
                      });
                    },
                    validator: (value) =>
                        value == null ? "Selecciona un artesano" : null,
                  );
                },
              ),
              const SizedBox(height: 24),

              _buildSectionTitle("Fotos del Producto (Hasta 3)"),
              Row(
                children: List.generate(
                  3,
                  (index) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: index == 0 ? 0 : 4,
                        right: index == 2 ? 0 : 4,
                      ),
                      child: _buildImageSlot(index),
                    ),
                  ),
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
                keyboardType: TextInputType.text,
              ),

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
                items: [..._categorias, 'Otro...'].map((categoria) {
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

              if (_selectedCategoria == 'Otro...') ...[
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

  Widget _buildImageSlot(int index) {
    final url = _fotoUrls[index];
    final isUploading = _isUploadingList[index];

    return AspectRatio(
      aspectRatio: 1,
      child: GestureDetector(
        onTap: isUploading ? null : () => _pickAndUploadImage(index),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.brown[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.brown[200]!),
            image: url != null
                ? DecorationImage(image: NetworkImage(url), fit: BoxFit.cover)
                : null,
          ),
          child: Stack(
            children: [
              if (url == null && !isUploading)
                const Center(
                  child: Icon(Icons.add_a_photo, color: Colors.brown, size: 30),
                ),
              if (isUploading)
                const Center(
                  child: CircularProgressIndicator(color: Colors.brown),
                ),
              if (url != null && !isUploading)
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => _removeImage(index),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
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
