// lib/screens/about_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/pin_dialog.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  static const String _adminCode = '4628';
  bool _adminUnlocked = false;

  Future<void> _promptAdminCode() async {
    showDialog(
      context: context,
      builder: (context) => PinDialog(
        title: 'Código de administración',
        message: 'Ingresa el código para desbloquear el modo administrador',
        correctPin: _adminCode,
        onSuccess: () {
          setState(() {
            _adminUnlocked = true;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sobre Nosotros')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Logo o imagen representativa
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5DC),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.brown, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.brown.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: ClipOval(
                  child: Center(
                    child: Image.asset(
                      'assets/logo_manos.png',
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                      isAntiAlias: true,
                    ),
                  ),
                ),
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
                  onTap: () =>
                      _launchURL('mailto:marcelosaizestudio@gmail.com'),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Administración',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5D4037),
                  ),
                ),
                if (!_adminUnlocked)
                  IconButton(
                    icon: const Icon(Icons.lock_outline, color: Colors.brown),
                    onPressed: _promptAdminCode,
                    tooltip: 'Activar Modo Administrador',
                  )
                else
                  const Icon(Icons.lock_open, color: Colors.green),
              ],
            ),
            const SizedBox(height: 10),

            if (!_adminUnlocked)
              ListTile(
                leading: const Icon(
                  Icons.admin_panel_settings,
                  color: Colors.grey,
                ),
                title: const Text('Acceso Restringido'),
                subtitle: const Text(
                  'Toca el candado para desbloquear opciones',
                ),
                onTap: _promptAdminCode,
              )
            else ...[
              ListTile(
                leading: const Icon(Icons.people_outline, color: Colors.brown),
                title: const Text('Gestionar Artesanos'),
                subtitle: const Text(
                  'Ver lista, añadir, eliminar o subir imágenes',
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pushNamed(context, '/admin-artisans');
                },
              ),
            ],
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
