import 'package:flutter/material.dart';
import '../../models/category.dart';
import '../../services/firestore_service.dart';
import '../../services/pin_service.dart';
import '../../widgets/pin_dialog.dart';

class ManageCategoriesScreen extends StatelessWidget {
  const ManageCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrar Categorías'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddCategoryDialog(context),
            tooltip: 'Agregar categoría',
          ),
        ],
      ),
      body: StreamBuilder<List<Category>>(
        stream: FirestoreService.getCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final categories = snapshot.data ?? [];

          if (categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No hay categorías registradas.'),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await FirestoreService.initializeDefaultCategories();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Categorías inicializadas'),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Inicializar Categorías por Defecto'),
                  ),
                ],
              ),
            );
          }

          return ReorderableListView.builder(
            itemCount: categories.length,
            onReorder: (oldIndex, newIndex) {
              _reorderCategories(context, categories, oldIndex, newIndex);
            },
            itemBuilder: (context, index) {
              final category = categories[index];
              return ListTile(
                key: ValueKey(category.id),
                leading: const Icon(Icons.drag_handle),
                title: Text(category.nombre),
                subtitle: Text('Orden: ${category.orden}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showEditCategoryDialog(context, category),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(context, category),
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

  void _reorderCategories(
    BuildContext context,
    List<Category> categories,
    int oldIndex,
    int newIndex,
  ) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final category = categories.removeAt(oldIndex);
    categories.insert(newIndex, category);

    // Actualizar el orden de todas las categorías
    for (int i = 0; i < categories.length; i++) {
      final updatedCategory = Category(
        id: categories[i].id,
        nombre: categories[i].nombre,
        orden: i + 1,
      );
      await FirestoreService.updateCategory(updatedCategory);
    }
  }

  void _showAddCategoryDialog(BuildContext context) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Categoría'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Nombre de la categoría',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;

              final categories = await FirestoreService.getCategories().first;
              final newOrder = categories.length + 1;
              final newId = 'cat_${DateTime.now().millisecondsSinceEpoch}';

              final category = Category(
                id: newId,
                nombre: nameController.text.trim(),
                orden: newOrder,
              );

              await FirestoreService.addCategory(category);

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Categoría agregada')),
                );
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _showEditCategoryDialog(BuildContext context, Category category) {
    final nameController = TextEditingController(text: category.nombre);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Categoría'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Nombre de la categoría',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;

              final updatedCategory = Category(
                id: category.id,
                nombre: nameController.text.trim(),
                orden: category.orden,
              );

              await FirestoreService.updateCategory(updatedCategory);

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Categoría actualizada')),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Category category) async {
    final adminPin = await PinService.getPin('admin_access');

    if (!context.mounted) return;

    showPinDialog(
      context: context,
      title: 'Eliminar Categoría',
      message: '¿Estás seguro de que deseas eliminar "${category.nombre}"?',
      correctPin: adminPin,
      onConfirm: () async {
        await FirestoreService.deleteCategory(category.id);
      },
    );
  }
}
