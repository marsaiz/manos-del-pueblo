import 'package:flutter/material.dart';
import '../../models/fair.dart';
import '../../services/firestore_service.dart';
import '../../services/pin_service.dart';
import '../../widgets/pin_dialog.dart';
import 'add_edit_fair_screen.dart';

import '../../services/admin_session_service.dart';

class AdminFairsScreen extends StatefulWidget {
  const AdminFairsScreen({super.key});

  @override
  State<AdminFairsScreen> createState() => _AdminFairsScreenState();
}

class _AdminFairsScreenState extends State<AdminFairsScreen> {
  final _pinController = TextEditingController();
  final _sessionService = AdminSessionService();
  String? _adminCode;

  @override
  void initState() {
    super.initState();
    _loadAdminPin();
  }

  @override
  void dispose() {
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
      _pinController.clear();
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
                child: const Text('Acceder'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_sessionService.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Administrar Ferias')),
        body: _buildPinGate(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrar Ferias'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddEditFairScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Fair>>(
        stream: FirestoreService.getFairs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final fairs = snapshot.data ?? [];

          if (fairs.isEmpty) {
            return const Center(child: Text('No hay ferias registradas.'));
          }

          return ListView.builder(
            itemCount: fairs.length,
            itemBuilder: (context, index) {
              final fair = fairs[index];
              return ListTile(
                leading: fair.imageUrl.isNotEmpty
                    ? Image.network(
                        fair.imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.storefront, size: 50),
                title: Text(fair.title),
                subtitle: Text(fair.organizer),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AddEditFairScreen(fair: fair),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(context, fair),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, Fair fair) async {
    final correctPin = await PinService.getPin('admin_access');
    
    if (!context.mounted) return;
    
    showPinDialog(
      context: context,
      title: 'Eliminar Feria',
      message: '¿Estás seguro de que deseas eliminar la feria "${fair.title}"?',
      correctPin: correctPin,
      onConfirm: () async {
        await FirestoreService.deleteFair(fair.id);
      },
    );
  }
}
