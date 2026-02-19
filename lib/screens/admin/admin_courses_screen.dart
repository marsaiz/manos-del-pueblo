import 'package:flutter/material.dart';
import '../../models/course.dart';
import '../../services/firestore_service.dart';
import '../../services/pin_service.dart';
import '../../widgets/pin_dialog.dart';
import 'add_edit_course_screen.dart';

class AdminCoursesScreen extends StatelessWidget {
  const AdminCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrar Cursos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddEditCourseScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Course>>(
        stream: FirestoreService.getCourses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final courses = snapshot.data ?? [];

          if (courses.isEmpty) {
            return const Center(child: Text('No hay cursos registrados.'));
          }

          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return ListTile(
                leading: course.imageUrl.isNotEmpty
                    ? Image.network(
                        course.imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.school, size: 50),
                title: Text(course.title),
                subtitle: Text(course.instructor),
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
                                AddEditCourseScreen(course: course),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(context, course),
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

  void _confirmDelete(BuildContext context, Course course) async {
    final productPin = await PinService.getPin('product_management');
    
    if (!context.mounted) return;
    
    showPinDialog(
      context: context,
      title: 'Eliminar Curso',
      message: '¿Estás seguro de que deseas eliminar el curso "${course.title}"?',
      correctPin: productPin,
      onConfirm: () async {
        await FirestoreService.deleteCourse(course.id);
      },
    );
  }
}
