// lib/screens/about_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'admin/upload_image_screen.dart';
import '../widgets/app_drawer.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Sobre Nosotros')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Logo o imagen representativa
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.brown[100],
                shape: BoxShape.circle,
                border: Border.all(color: Colors.brown, width: 2),
              ),
              child: const Icon(
                Icons.handyman,
                size: 80,
                color: Color(0xFF5D4037),
              ),
            ),
            const SizedBox(height: 24),
            // Título
            const Text(
              'Manos del Pueblo',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5D4037),
              ),
            ),
            const SizedBox(height: 8),
            // Lema o descripción corta
            const Text(
              'Conectando artesanos con el mundo',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 40),
            // Tarjeta de información
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildInfoRow(
                      Icons.history,
                      'Nuestra Historia',
                      'Desde 2023, nos dedicamos a promover y preservar el trabajo de los artesanos locales, ofreciendo una plataforma donde pueden mostrar y vender sus creaciones únicas.',
                    ),
                    const Divider(height: 30),
                    _buildInfoRow(
                      Icons.visibility,
                      'Nuestra Visión',
                      'Ser el puente que conecta a los artesanos con un público que valora el trabajo hecho a mano, la autenticidad y la cultura local.',
                    ),
                    const Divider(height: 30),
                    _buildInfoRow(
                      Icons.people,
                      'Nuestro Equipo',
                      'Un grupo apasionado por el arte y la artesanía, comprometido con el desarrollo económico de las comunidades artesanales.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Botones de contacto
            const Text(
              'Contáctanos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5D4037),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialButton(
                  icon: FontAwesomeIcons.facebook,
                  color: const Color(0xFF3b5998),
                  onTap: () =>
                      _launchURL('https://facebook.com/manosdelpueblo'),
                ),
                const SizedBox(width: 20),
                _buildSocialButton(
                  icon: FontAwesomeIcons.instagram,
                  color: const Color(0xFFE1306C),
                  onTap: () =>
                      _launchURL('https://instagram.com/manosdelpueblo'),
                ),
                const SizedBox(width: 20),
                _buildSocialButton(
                  icon: Icons.email,
                  color: Colors.grey[700]!,
                  onTap: () => _launchURL('mailto:contacto@manosdelpueblo.com'),
                ),
                const SizedBox(width: 20),
                _buildSocialButton(
                  icon: Icons.phone,
                  color: Colors.green,
                  onTap: () => _launchURL('tel:+5492302609175'),
                ),
              ],
            ),
            const SizedBox(height: 30),
            // Sección Administrativa
            const Divider(),
            const SizedBox(height: 20),
            const Text(
              'Administración',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5D4037),
              ),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.person_add, color: Colors.brown),
              title: const Text('Añadir Nuevo Artesano'),
              subtitle: const Text('Crear perfil desde el celular'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pushNamed(context, '/add-artisan');
              },
            ),
            ListTile(
              leading: const Icon(Icons.cloud_upload, color: Colors.brown),
              title: const Text('Subir Imágenes'),
              subtitle: const Text('Artesanos y Productos'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UploadImageScreen(),
                  ),
                );
              },
            ),
            // Botón de sincronización oculto por seguridad/destructividad
            const SizedBox(height: 30),
            // Créditos
            const Text(
              '© 2024 Manos del Pueblo',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF5D4037), size: 28),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5D4037),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'No se pudo abrir $url';
    }
  }
}
