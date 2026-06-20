// lib/screens/about_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../widgets/adaptive_app_bar.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = '';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();
    _loadVersionInfo();
  }

  Future<void> _loadVersionInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = packageInfo.version;
      _buildNumber = packageInfo.buildNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AdaptiveAppBar(title: const Text('Sobre Nosotros')),
      body: SafeArea(
        child: SingleChildScrollView(
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
                      'assets/logo.png',
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
                color: Color(0xFF616161), // grey[700] - cumple WCAG AA
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
                  iconWidget: const FaIcon(
                    FontAwesomeIcons.facebook,
                    color: Color(0xFF3b5998),
                    size: 24,
                  ),
                  color: const Color(0xFF3b5998),
                  onTap: () =>
                      _launchURL('https://facebook.com/manosdelpueblo'),
                ),
                const SizedBox(width: 20),
                _buildSocialButton(
                  iconWidget: const FaIcon(
                    FontAwesomeIcons.instagram,
                    color: Color(0xFFE1306C),
                    size: 24,
                  ),
                  color: const Color(0xFFE1306C),
                  onTap: () =>
                      _launchURL('https://instagram.com/manosdelpueblo'),
                ),
                const SizedBox(width: 20),
                _buildSocialButton(
                  iconWidget: Icon(
                    Icons.email,
                    color: Colors.grey[700]!,
                    size: 24,
                  ),
                  color: Colors.grey[700]!,
                  onTap: () =>
                      _launchURL('mailto:contacto@manos-del-pueblo.ar'),
                ),
                const SizedBox(width: 20),
                _buildSocialButton(
                  iconWidget: const Icon(
                    Icons.phone,
                    color: Colors.green,
                    size: 24,
                  ),
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
              ],
            ),
            const SizedBox(height: 10),

            ListTile(
              leading: const Icon(Icons.people_outline, color: Colors.brown),
              title: const Text('Gestionar Artesanos'),
              subtitle: const Text(
                'Ver lista, añadir y gestionar categorías',
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pushNamed(context, '/admin-artisans');
              },
            ),
            // Botón de sincronización oculto por seguridad/destructividad
            const SizedBox(height: 30),
            // Política de Privacidad
            TextButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/privacy-policy');
              },
              icon: const Icon(Icons.privacy_tip_outlined, size: 18),
              label: const Text('Política de Privacidad'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.brown,
              ),
            ),
            const SizedBox(height: 5),
            // Solicitud de Eliminación de Datos (para artesanos)
            TextButton.icon(
              onPressed: () {
                _launchURL(
                  'mailto:contacto@manos-del-pueblo.ar?subject=Solicitud de eliminación de datos de artesano&body=Nombre del artesano:%0D%0ALocalidad:%0D%0AMotivo de la solicitud:%0D%0A%0D%0APor favor, proporciona la información necesaria para verificar tu identidad como artesano registrado.',
                );
              },
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Solicitar Eliminación de Datos'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red[700],
              ),
            ),
            const SizedBox(height: 10),
            // Versión de la app
            if (_version.isNotEmpty)
              Text(
                'Versión $_version (Build $_buildNumber)',
                style: const TextStyle(
                  color: Color(0xFF616161), // grey[700] - cumple WCAG AA
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            const SizedBox(height: 5),
            // Créditos
            const Text(
              '© 2024 Manos del Pueblo',
              style: TextStyle(
                color: Color(0xFF616161), // grey[700] - cumple WCAG AA
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 40), // Espacio adicional para botones de navegación
          ],
        ),
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
    required Widget iconWidget,
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
        child: Center(child: iconWidget),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      // Usar mode: LaunchMode.externalApplication para abrir en apps externas
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo abrir: $url'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al abrir el enlace: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
