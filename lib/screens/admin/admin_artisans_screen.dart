import 'package:flutter/material.dart';
import '../../models/artisan.dart';
import '../../services/firestore_service.dart';
import '../../services/image_upload_service.dart';
import '../../services/pin_service.dart';
import '../../services/admin_session_service.dart';
import '../../widgets/pin_dialog.dart';
import 'add_artisan_screen.dart';
import 'edit_artisan_screen.dart';
import 'manage_categories_screen.dart';

class AdminArtisansScreen extends StatefulWidget {
  const AdminArtisansScreen({super.key});

  @override
  State<AdminArtisansScreen> createState() => _AdminArtisansScreenState();
}

class _AdminArtisansScreenState extends State<AdminArtisansScreen>
    with SingleTickerProviderStateMixin {
  final _pinController = TextEditingController();
  final _sessionService = AdminSessionService();
  String? _adminCode;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAdminPin();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _loadAdminPin() async {
    _adminCode = await PinService.getPin('admin_access');
  }

  void _verifyPin() {
    if (_adminCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cargando configuración...'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_pinController.text.trim() == _adminCode) {
      setState(() {
        _sessionService.login();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN incorrecto'),
          backgroundColor: Colors.red,
        ),
      );
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

  Future<void> _confirmDelete(Artisan artisan) async {
    final deletePin = await PinService.getPin('artisan_delete');
    
    if (!mounted) return;
    
    showPinDialog(
      context: context,
      title: 'Confirmar Eliminación',
      message: 'Se eliminará el artesano "${artisan.nombre}" y sus productos. Esta acción no se puede deshacer.',
      correctPin: deletePin,
      onConfirm: () async {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );

        await FirestoreService.deleteArtisanCascade(artisan.id);
        await ImageUploadService.deleteArtisanFolder(artisan.id);

        if (mounted) {
          Navigator.pop(context); // Cerrar loading
        }
      },
    );
  }

  Widget _buildListTab() {
    return StreamBuilder<List<Artisan>>(
      stream: FirestoreService.getArtisans(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error cargando artesanos'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final artisans = snapshot.data!;
        if (artisans.isEmpty) {
          return const Center(child: Text('No hay artesanos.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: artisans.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final artisan = artisans[index];
            return ListTile(
              tileColor: Colors.brown.withValues(alpha: 0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              leading: CircleAvatar(
                backgroundColor: Colors.brown[50],
                backgroundImage: artisan.fotoPerfil.startsWith('http')
                    ? NetworkImage(artisan.fotoPerfil)
                    : null,
                child: artisan.fotoPerfil.startsWith('http')
                    ? null
                    : const Icon(Icons.person, color: Colors.brown),
              ),
              title: Text(artisan.nombre),
              subtitle: Text('${artisan.localidad} • ID: ${artisan.id}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditArtisanScreen(artisan: artisan),
                        ),
                      );
                    },
                    tooltip: 'Editar',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDelete(artisan),
                    tooltip: 'Eliminar',
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActionTab({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onOpen,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 48, color: Colors.brown),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(description, textAlign: TextAlign.center),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: onOpen,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Abrir'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Extender la sesión cada vez que se construye la pantalla
    if (_sessionService.isAuthenticated) {
      _sessionService.extendSession();
    }

    if (!_sessionService.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Administrar Artesanos'),
        ),
        body: _buildPinGate(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrar Artesanos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () {
              _sessionService.logout();
              setState(() {});
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.list), text: 'Lista'),
            Tab(icon: Icon(Icons.add), text: 'Añadir'),
            Tab(icon: Icon(Icons.category), text: 'Categorías'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildListTab(),
          _buildActionTab(
            title: 'Añadir artesano',
            description: 'Crear un perfil nuevo desde el celular.',
            icon: Icons.person_add,
            onOpen: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddArtisanScreen(),
                ),
              );
            },
          ),
          _buildActionTab(
            title: 'Gestionar Categorías',
            description: 'Agregar, editar o eliminar categorías de productos.',
            icon: Icons.category,
            onOpen: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageCategoriesScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
