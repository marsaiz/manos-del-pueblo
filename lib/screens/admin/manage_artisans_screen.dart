// lib/screens/admin/manage_artisans_screen.dart
import 'package:flutter/material.dart';
import '../../models/artisan.dart';
import '../../services/firestore_service.dart';
import '../../services/image_upload_service.dart';
import 'package:flutter/services.dart';

enum ImageType { artisanProfile, product }

class ManageArtisansScreen extends StatefulWidget {
  const ManageArtisansScreen({super.key});

  @override
  State<ManageArtisansScreen> createState() => _ManageArtisansScreenState();
}

class _ManageArtisansScreenState extends State<ManageArtisansScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrar Artesanos'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.list), text: 'Lista'),
            Tab(icon: Icon(Icons.person_add), text: 'Añadir'),
            Tab(icon: Icon(Icons.cloud_upload), text: 'Imágenes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _ListArtisansTab(),
          _AddArtisanTab(),
          _UploadImagesTab(),
        ],
      ),
    );
  }
}

// ============================================
// TAB 1: LISTA DE ARTESANOS
// ============================================
class _ListArtisansTab extends StatelessWidget {
  const _ListArtisansTab();

  Future<void> _deleteArtisan(BuildContext context, Artisan artisan) async {
    final TextEditingController pinController = TextEditingController();

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar Artesano?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Vas a eliminar a "${artisan.nombre}" y todos sus productos e imágenes.',
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: pinController,
              decoration: const InputDecoration(
                labelText: 'PIN de seguridad',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () {
              if (pinController.text == '4628') {
                Navigator.pop(context, true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PIN incorrecto')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ELIMINAR', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!context.mounted) return;
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );

        await FirestoreService.deleteArtisanCascade(artisan.id);
        await ImageUploadService.deleteArtisanFolder(artisan.id);

        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Artesano eliminado con éxito')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ Error al eliminar: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Artisan>>(
      stream: FirestoreService.getArtisans(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final artisans = snapshot.data!;

        if (artisans.isEmpty) {
          return const Center(child: Text('No hay artesanos registrados'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: artisans.length,
          itemBuilder: (context, index) {
            final artisan = artisans[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: artisan.fotoPerfil.startsWith('http')
                      ? NetworkImage(artisan.fotoPerfil)
                      : AssetImage(artisan.fotoPerfil) as ImageProvider,
                ),
                title: Text(
                  artisan.nombre,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('${artisan.localidad} • ID: ${artisan.id}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteArtisan(context, artisan),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ============================================
// TAB 2: AÑADIR ARTESANO
// ============================================
class _AddArtisanTab extends StatelessWidget {
  const _AddArtisanTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_add, size: 80, color: Colors.brown),
            const SizedBox(height: 20),
            const Text(
              'Añadir Nuevo Artesano',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Usa esta opción para crear un perfil completo',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/add-artisan');
              },
              icon: const Icon(Icons.add),
              label: const Text('IR A FORMULARIO'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                backgroundColor: Colors.brown,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// TAB 3: SUBIR IMÁGENES
// ============================================
class _UploadImagesTab extends StatefulWidget {
  const _UploadImagesTab();

  @override
  State<_UploadImagesTab> createState() => _UploadImagesTabState();
}

class _UploadImagesTabState extends State<_UploadImagesTab> {
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: !_isPinVerified ? _buildPinVerification() : _buildUploadInterface(),
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

  Widget _buildUploadInterface() {
    return StreamBuilder<List<Artisan>>(
      stream: FirestoreService.getArtisans(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final artisans = snapshot.data!;

        return SingleChildScrollView(
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selecciona el Artesano:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Tipo de imagen:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildTypeSelector('Perfil', ImageType.artisanProfile),
                          const SizedBox(width: 20),
                          _buildTypeSelector('Producto', ImageType.product),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isUploading ? null : _uploadImage,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  backgroundColor: Colors.brown,
                  foregroundColor: Colors.white,
                ),
                child: _isUploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Seleccionar y Subir Imagen'),
              ),
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
                    Clipboard.setData(ClipboardData(text: _imageUrl!)).then((_) {
                      _showSnack('URL copiada al portapapeles');
                    });
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text('Copiar URL'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ],
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
