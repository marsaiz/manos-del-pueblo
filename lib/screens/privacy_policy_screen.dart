import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Política de Privacidad'),
        backgroundColor: Colors.amber[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Política de Privacidad',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2c3e50),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Última actualización: 16 de febrero de 2026',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'En Manos del Pueblo, nos comprometemos a proteger tu privacidad. Esta Política de Privacidad explica cómo recopilamos, usamos y protegemos tu información cuando utilizas nuestra aplicación móvil.',
              style: TextStyle(fontSize: 16, height: 1.6),
            ),
            const SizedBox(height: 24),
            _buildSection(
              '1. Información que Recopilamos',
              [
                _buildSubsection(
                  '1.1 Información que Proporcionas',
                  'Cuando utilizas Manos del Pueblo, podemos recopilar la siguiente información que nos proporcionas voluntariamente:',
                  [
                    'Información de contacto: Nombre, dirección de correo electrónico, número de teléfono (si decides contactar directamente con los artesanos)',
                    'Información de navegación: Productos que visualizas, artesanos que sigues, búsquedas realizadas',
                  ],
                ),
                _buildSubsection(
                  '1.2 Información Recopilada Automáticamente',
                  'Cuando utilizas la aplicación, recopilamos automáticamente cierta información:',
                  [
                    'Información del dispositivo: Tipo de dispositivo, sistema operativo, versión de la aplicación',
                    'Datos de uso: Páginas visitadas, tiempo de uso, interacciones con la aplicación',
                    'Datos analíticos: Utilizamos Firebase Analytics para entender cómo se usa la aplicación y mejorar la experiencia del usuario',
                  ],
                ),
              ],
            ),
            _buildSection(
              '2. Cómo Utilizamos tu Información',
              [
                const Text(
                  'Utilizamos la información recopilada para:',
                  style: TextStyle(fontSize: 16, height: 1.6),
                ),
                const SizedBox(height: 8),
                _buildBulletList([
                  'Proporcionar y mantener la funcionalidad de la aplicación',
                  'Mejorar y personalizar tu experiencia de usuario',
                  'Facilitar la comunicación entre usuarios y artesanos',
                  'Analizar el uso de la aplicación para mejorar nuestros servicios',
                  'Enviar notificaciones importantes sobre la aplicación (si has dado tu consentimiento)',
                  'Detectar, prevenir y abordar problemas técnicos',
                ]),
              ],
            ),
            _buildSection(
              '3. Compartir Información',
              [
                const Text(
                  'No vendemos ni alquilamos tu información personal a terceros.',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Podemos compartir tu información en las siguientes circunstancias:',
                  style: TextStyle(fontSize: 16, height: 1.6),
                ),
                const SizedBox(height: 8),
                _buildBulletList([
                  'Con artesanos: Cuando decides contactar a un artesano, compartimos la información de contacto que proporcionas',
                  'Proveedores de servicios: Compartimos información con proveedores que nos ayudan a operar la aplicación (ej: Firebase, servicios de hosting)',
                  'Cumplimiento legal: Si es requerido por ley o para proteger nuestros derechos legales',
                ]),
              ],
            ),
            _buildSection(
              '4. Servicios de Terceros',
              [
                const Text(
                  'Nuestra aplicación utiliza los siguientes servicios de terceros:',
                  style: TextStyle(fontSize: 16, height: 1.6),
                ),
                const SizedBox(height: 8),
                _buildBulletList([
                  'Firebase (Google): Para analytics, almacenamiento de datos y notificaciones push',
                  'Google Play Services: Para funcionalidades del sistema Android',
                ]),
              ],
            ),
            _buildSection(
              '5. Seguridad de los Datos',
              [
                const Text(
                  'Implementamos medidas de seguridad técnicas y organizativas para proteger tu información personal:',
                  style: TextStyle(fontSize: 16, height: 1.6),
                ),
                const SizedBox(height: 8),
                _buildBulletList([
                  'Cifrado de datos en tránsito (HTTPS/SSL)',
                  'Almacenamiento seguro en servidores de Firebase',
                  'Acceso restringido a información personal',
                  'Monitoreo regular de vulnerabilidades de seguridad',
                ]),
                const SizedBox(height: 12),
                const Text(
                  'Sin embargo, ningún método de transmisión por Internet o almacenamiento electrónico es 100% seguro.',
                  style: TextStyle(fontSize: 16, height: 1.6),
                ),
              ],
            ),
            _buildSection(
              '6. Retención de Datos',
              [
                const Text(
                  'Conservamos tu información personal solo durante el tiempo necesario para cumplir con los propósitos descritos en esta política, a menos que la ley requiera o permita un período de retención más largo.',
                  style: TextStyle(fontSize: 16, height: 1.6),
                ),
              ],
            ),
            _buildSection(
              '7. Tus Derechos',
              [
                const Text(
                  'Tienes derecho a:',
                  style: TextStyle(fontSize: 16, height: 1.6),
                ),
                const SizedBox(height: 8),
                _buildBulletList([
                  'Acceder: Solicitar una copia de la información personal que tenemos sobre ti',
                  'Rectificar: Solicitar la corrección de información inexacta',
                  'Eliminar: Solicitar la eliminación de tu información personal',
                  'Oponerte: Oponerte al procesamiento de tu información personal',
                  'Portabilidad: Solicitar la transferencia de tus datos a otro servicio',
                ]),
                const SizedBox(height: 12),
                const Text(
                  'Para ejercer estos derechos, contáctanos usando la información proporcionada al final de esta política.',
                  style: TextStyle(fontSize: 16, height: 1.6),
                ),
              ],
            ),
            _buildSection(
              '8. Privacidad de los Niños',
              [
                const Text(
                  'Nuestra aplicación no está dirigida a menores de 13 años. No recopilamos intencionalmente información personal de niños menores de 13 años. Si descubrimos que hemos recopilado información de un niño menor de 13 años, eliminaremos esa información inmediatamente.',
                  style: TextStyle(fontSize: 16, height: 1.6),
                ),
              ],
            ),
            _buildSection(
              '9. Cambios a esta Política',
              [
                const Text(
                  'Podemos actualizar nuestra Política de Privacidad periódicamente. Te notificaremos sobre cualquier cambio publicando la nueva Política de Privacidad en esta página y actualizando la fecha de "Última actualización".',
                  style: TextStyle(fontSize: 16, height: 1.6),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Te recomendamos revisar esta Política de Privacidad periódicamente para estar informado sobre cómo protegemos tu información.',
                  style: TextStyle(fontSize: 16, height: 1.6),
                ),
              ],
            ),
            _buildSection(
              '10. Contacto',
              [
                const Text(
                  'Si tienes preguntas, inquietudes o solicitudes relacionadas con esta Política de Privacidad, puedes contactarnos:',
                  style: TextStyle(fontSize: 16, height: 1.6),
                ),
                const SizedBox(height: 8),
                _buildBulletList([
                  'Email: privacidad@manosdelpueblo.ar',
                  'Sitio web: https://manosdelpueblo.ar',
                ]),
                const SizedBox(height: 12),
                const Text(
                  'Responderemos a tu solicitud dentro de un plazo razonable.',
                  style: TextStyle(fontSize: 16, height: 1.6),
                ),
              ],
            ),
            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 20),
            Center(
              child: Text(
                '© 2026 Manos del Pueblo. Todos los derechos reservados.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF34495e),
          ),
        ),
        const SizedBox(height: 12),
        ...children,
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSubsection(String title, String description, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF34495e),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: const TextStyle(fontSize: 16, height: 1.6),
        ),
        const SizedBox(height: 8),
        _buildBulletList(items),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildBulletList(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• ', style: TextStyle(fontSize: 16)),
              Expanded(
                child: Text(
                  item,
                  style: const TextStyle(fontSize: 16, height: 1.6),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
