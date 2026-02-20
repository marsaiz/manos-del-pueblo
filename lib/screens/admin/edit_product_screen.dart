// lib/screens/admin/edit_product_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/artisan.dart';
import '../../models/product.dart';
import '../../models/category.dart';
import '../../services/firestore_service.dart';
import '../../services/image_upload_service.dart';
import '../../services/pin_service.dart';
import '../../widgets/pin_dialog.dart';

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

  List<String> _categorias = [];
  bool _loadingCategories = true;
  StreamSubscription<List<Category>>? _categoriesSubscription;

  Artisan? _selectedArtesano;
  String? _selectedCategoria;

  // Lista fija de 3 posiciones para las URLs de las fotos
  final List<String?> _fotoUrls = [null, null, null];
  final List<bool> _isUploadingList = [false, false, false];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _nombreController = TextEditingController(text: widget.product.nombre);
    _descripcionController = TextEditingController(
      text: widget.product.descripcion,
    );
    _precioController = TextEditingController(text: widget.product.precio);

    // Inicializar fotos existentes
    for (int i = 0; i < widget.product.imagePaths.length && i < 3; i++) {
      _fotoUrls[i] = widget.product.imagePaths[i];
    }
  }

  void _loadCategories() {
    _categoriesSubscription?.cancel(); // Cancelar suscripción anterior si existe
    _categoriesSubscription = FirestoreService.getCategories().listen((categories) {
      if (mounted) {
        setState(() {
          // Limpiar y reconstruir la lista de categorías
          _categorias = categories.map((c) => c.nombre).toList();
          
          // Agregar "Otro..." solo si no existe
          if (!_categorias.contains('Otro...')) {
            _categorias.add('Otro...');
          }
          
          _loadingCategories = false;

          // Inicializar categoría seleccionada después de cargar las categorías
          if (_categorias.contains(widget.product.categoria)) {
            _selectedCategoria = widget.product.categoria;
            _customCategoriaController = TextEditingController();
          } else {
            _selectedCategoria = 'Otro...';
            _customCategoriaController = TextEditingController(
              text: widget.product.categoria,
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _categoriesSubscription?.cancel();
    _nombreController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    _customCategoriaController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage(int index) async {
    if (_selectedArtesano == null) {
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
        _selectedArtesano!.id,
        tempId,
      );

      if (url != null) {
        setState(() => _fotoUrls[index] = url);
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
      if (mounted) setState(() => _isUploadingList[index] = false);
    }
  }

  void _removeImage(int index) {
    setState(() {
      _fotoUrls[index] = null;
    });
  }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate() || _selectedArtesano == null) {
      if (_selectedArtesano == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecciona un artesano')),
        );
      }
      return;
    }

    final productPin = await PinService.getPin('product_management');
    
    if (!mounted) return;

    // Mostrar diálogo de PIN antes de actualizar
    showPinDialog(
      context: context,
      title: 'Confirmar Actualización',
      message: '¿Deseas actualizar este producto?',
      correctPin: productPin,
      onConfirm: () async {
        await _performUpdate();
      },
    );
  }

  Future<void> _performUpdate() async {
    setState(() => _isSaving = true);

    final String finalCategoria =
        _selectedCategoria == 'Otro...' || _selectedCategoria == 'Otros'
        ? _customCategoriaController.text.trim()
        : _selectedCategoria ?? '';

    // Filtramos las URLs nulas para guardar solo las válidas
    final List<String> validUrls = _fotoUrls.whereType<String>().toList();

    final updatedProduct = Product(
      id: widget.product.id,
      artisanId: _selectedArtesano!.id,
      nombre: _nombreController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      precio: _precioController.text.trim(),
      imagePaths: validUrls,
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

  Future<void> _deleteProduct() async {
    final productPin = await PinService.getPin('product_management');
    
    if (!mounted) return;
    
    showPinDialog(
      context: context,
      title: 'Confirmar Eliminación',
      message: '¿Estás seguro de que deseas eliminar el producto "${widget.product.nombre}"?\n\nEsta acción no se puede deshacer.',
      correctPin: productPin,
      onConfirm: () async {
        await FirestoreService.deleteProduct(widget.product.id);
        if (mounted) {
          Navigator.pop(context);
        }
      },
    );
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
                  if (_selectedArtesano == null && artisans.isNotEmpty) {
                    try {
                      _selectedArtesano = artisans.firstWhere(
                        (a) => a.id == widget.product.artisanId,
                      );
                    } catch (_) {
                      // Si no existe, dejamos que el usuario elija
                    }
                  }

                  return DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _selectedArtesano?.id,
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
                        child: Text(
                          artisan.nombre,
                          overflow: TextOverflow.ellipsis, // Corta el texto con "..."
                          maxLines: 1,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedArtesano = artisans.firstWhere(
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
              _buildTextField(_precioController, "Precio", Icons.attach_money),

              _buildSectionTitle("Categoría"),
              DropdownButtonFormField<String>(
                isExpanded: true,
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
                    child: Text(
                      categoria,
                      overflow: TextOverflow.ellipsis, // Corta el texto con "..."
                      maxLines: 1,
                    ),
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
              const SizedBox(height: 16),
              SizedBox(
                height: 55,
                child: OutlinedButton.icon(
                  onPressed: _isSaving ? null : _deleteProduct,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text(
                    "ELIMINAR PRODUCTO",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
                ? DecorationImage(
                    image: url.startsWith('http')
                        ? NetworkImage(url)
                        : AssetImage(url) as ImageProvider,
                    fit: BoxFit.cover,
                  )
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
