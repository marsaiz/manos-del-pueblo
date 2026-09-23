import 'package:flutter/material.dart';
import '../models/fair.dart';
import '../services/firestore_service.dart';
import 'fair_detail_screen.dart';
import 'admin/add_edit_fair_screen.dart';
import '../widgets/adaptive_app_bar.dart';

class FairsScreen extends StatelessWidget {
  const FairsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AdaptiveAppBar(
        title: const Text('Ferias de Artesanos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            tooltip: 'Administrar Ferias',
            onPressed: () {
              Navigator.pushNamed(context, '/admin-fairs');
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

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final fairs = snapshot.data ?? [];

          final activeFairs = fairs.where((f) => !f.isFinished).toList();
          final finishedFairs = fairs.where((f) => f.isFinished).toList();

          if (fairs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.storefront, size: 80, color: Colors.brown),
                  SizedBox(height: 16),
                  Text(
                    'Próximamente nuevas ferias...',
                    style: TextStyle(fontSize: 18, color: Colors.brown),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (activeFairs.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Ferias Vigentes',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                ),
                ...activeFairs.map((fair) => _FairCard(fair: fair)),
              ],
              if (finishedFairs.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 16),
                  child: Text(
                    'Ferias Finalizadas',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                ...finishedFairs.map((fair) => Opacity(
                  opacity: 0.6,
                  child: _FairCard(fair: fair),
                )),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _FairCard extends StatelessWidget {
  final Fair fair;

  const _FairCard({required this.fair});

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
              builder: (context) => FairDetailScreen(fair: fair),
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
                tag: 'fair-${fair.id}',
                child: Image.network(
                  fair.imageUrl,
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
                    fair.title,
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
                        fair.organizer,
                        style: const TextStyle(color: Color(0xFF616161)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (fair.startDate.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.event,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Inicio: ${fair.startDate}',
                          style: const TextStyle(color: Color(0xFF616161)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        fair.schedule,
                        style: const TextStyle(color: Color(0xFF616161)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    fair.description,
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
