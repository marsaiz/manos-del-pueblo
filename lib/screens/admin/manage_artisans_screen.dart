// lib/screens/admin/manage_artisans_screen.dart
import 'package:flutter/material.dart';
import '../../models/artisan.dart';
import '../../services/firestore_service.dart';
import '../../services/image_upload_service.dart';
import '../../services/pin_service.dart';
import '../../widgets/pin_dialog.dart';

class ManageArtisansScreen extends StatefulWidget {
  const ManageArtisansScreen({super.key});

  @override
  State<ManageArtisansScreen> createState() => _ManageArtisansScreenState();
}

class _ManageArtisansScreenState extends State<ManageArtisansScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isPinVerified = false;
  final TextEditingController _pinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _verifyPin() async {
    final correctPin = await PinService.getPin('admin_access');
    
    if (_pinController.text == correctPin) {
      setState(() => _isPinVerified = true);
      _showSnack('✅ PIN correcto');
    } else {
      _showSnack('❌ PIN incorrecto');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isPinVerified) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Administrar Artesanos'),
        ),
        body: Center(
          child: Card(
            margin: const EdgeInsets.all(24.0),
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
        ),
      );
    }

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
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _ListArtisansTab(),
          _AddArtisanTab(),
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
    final deletePin = await PinService.getPin('artisan_delete');
    
    if (!context.mounted) return;
    
    showPinDialog(
      context: context,
      title: '¿Eliminar Artesano?',
      message: 'Vas a eliminar a "${artisan.nombre}" y todos sus productos e imágenes.',
      correctPin: deletePin,
      onConfirm: () async {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );

        await FirestoreService.deleteArtisanCascade(artisan.id);
        await ImageUploadService.deleteArtisanFolder(artisan.id);

        if (context.mounted) {
          Navigator.pop(context); // Cerrar loading
        }
      },
    );
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
