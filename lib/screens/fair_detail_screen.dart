import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/fair.dart';

class FairDetailScreen extends StatelessWidget {
  final Fair fair;

  const FairDetailScreen({super.key, required this.fair});

  Future<void> _launchWhatsApp() async {
    final message =
        'Hola, me interesa la feria "${fair.title}". ¿Podrías darme más información?';
    final url =
        'https://wa.me/${fair.contactWhatsApp}?text=${Uri.encodeComponent(message)}';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                fair.title,
                style: const TextStyle(
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                ),
              ),
              background: Hero(
                tag: 'fair-${fair.id}',
                child: Image.network(
                  fair.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.brown[100],
                    child: const Icon(Icons.image_not_supported, size: 100),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        if (fair.isFinished) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.red[100],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.red),
                            ),
                            child: const Text(
                              'FERIA FINALIZADA',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        _InfoRow(
                          icon: Icons.person,
                          label: 'Organizador',
                          value: fair.organizer,
                        ),
                        const Divider(),
                        if (fair.startDate.isNotEmpty) ...[
                          _InfoRow(
                            icon: Icons.event,
                            label: 'Fecha de Inicio',
                            value: fair.startDate,
                          ),
                          const Divider(),
                        ],
                        if (fair.endDate.isNotEmpty) ...[
                          _InfoRow(
                            icon: Icons.event_busy,
                            label: 'Fecha de Fin',
                            value: fair.endDate,
                          ),
                          const Divider(),
                        ],
                        _InfoRow(
                          icon: Icons.access_time,
                          label: 'Horarios',
                          value: fair.schedule,
                        ),
                        const Divider(),
                        _InfoRow(
                          icon: Icons.location_on,
                          label: 'Ubicación',
                          value: fair.location,
                        ),
                        const Divider(),
                        _InfoRow(
                          icon: Icons.payments,
                          label: 'Entrada',
                          value:
                              fair.entryFee.toLowerCase() == '0' ||
                                  fair.entryFee.toLowerCase() == 'gratis' ||
                                  fair.entryFee.toLowerCase() == 'gratuito'
                              ? 'Gratuita'
                              : fair.entryFee.contains('\$')
                              ? fair.entryFee
                              : '\$${fair.entryFee}',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Descripción de la Feria',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5D4037),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  fair.description,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: _launchWhatsApp,
                  icon: const Icon(Icons.chat),
                  label: const Text('Consultar por WhatsApp'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.brown, size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Color(0xFF616161), fontSize: 12),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
