import 'package:flutter/material.dart';
import '../models/course.dart';
import '../services/firestore_service.dart';
import 'course_detail_screen.dart';
import 'admin/add_edit_course_screen.dart';
import '../widgets/adaptive_app_bar.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AdaptiveAppBar(
        title: Text('Cursos de Alfarería y Más'),
      ),
      body: StreamBuilder<List<Course>>(
        stream: FirestoreService.getCourses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final courses = snapshot.data ?? [];

          final activeCourses = courses.where((c) => !c.isFinished).toList();
          final finishedCourses = courses.where((c) => c.isFinished).toList();

          if (courses.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.school, size: 80, color: Colors.brown),
                  SizedBox(height: 16),
                  Text(
                    'Próximamente nuevos cursos...',
                    style: TextStyle(fontSize: 18, color: Colors.brown),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (activeCourses.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Cursos Vigentes',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                ),
                ...activeCourses.map((course) => _CourseCard(course: course)),
              ],
              if (finishedCourses.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 16),
                  child: Text(
                    'Cursos Finalizados',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                ...finishedCourses.map((course) => Opacity(
                  opacity: 0.6,
                  child: _CourseCard(course: course),
                )),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final Course course;

  const _CourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CourseDetailScreen(course: course),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
              child: Hero(
                tag: 'course-${course.id}',
                child: Image.network(
                  course.imageUrl,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 180,
                    color: Colors.brown[100],
                    child: const Icon(Icons.image_not_supported, size: 50),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5D4037),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        course.instructor,
                        style: const TextStyle(color: Color(0xFF616161)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        course.schedule,
                        style: const TextStyle(color: Color(0xFF616161)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    course.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[800]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
