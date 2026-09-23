import 'package:flutter/material.dart';
import '../../models/fair.dart';
import '../../services/firestore_service.dart';
import '../../services/pin_service.dart';
import '../../widgets/pin_dialog.dart';
import 'add_edit_fair_screen.dart';

class AdminFairsScreen extends StatelessWidget {
  const AdminFairsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
