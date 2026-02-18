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
              'En Manos del Pueblo, respetamos tu privacidad. Esta Política de Privacidad explica qué información recopilamos, cómo la usamos y tus derechos cuando utilizas nuestra aplicación móvil.',
              style: TextStyle(fontSize: 16, height: 1.6),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Importante',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Manos del Pueblo NO requiere registro de usuario, NO recopila datos personales identificables (nombre, email, teléfono), y NO almacena información personal en nuestros servidores.',
                    style: TextStyle(fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              '1. Información que Recopilamos',
              [
                _buildSubsection(
                  '1.1 Información que NO Recopilamos',
                  'Nuestra aplicación NO recopila ni almacena:',
                  [
                    'Nombre, apellido o información de identidad personal',
                    'Dirección de correo electrónico',
                    'Número de teléfono',
                    'Dirección física o ubicación precisa',
                    'Información de pago o tarjetas de crédito',
                    'Contraseñas o credenciales de acceso (no hay sistema de login)',
                  ],
                ),
                _buildSubsection(
                  '1.2 Información Recopilada Automáticamente',
                  'Cuando utilizas la aplicación, recopilamos automáticamente información anónima de uso a través de Firebase Analytics:',
                  [
                    'Tipo de dispositivo y modelo (ej: Samsung Galaxy, iPhone 12)',
                    'Sistema operativo y versión (ej: Android 13, iOS 16)',
                    'Versión de la aplicación instalada',
                    'Idioma del dispositivo',
                    'Identificador anónimo del dispositivo (para analytics, no vinculado a tu identidad)',
                    'Páginas y productos visualizados dentro de la app',
                    'Tiempo de uso y frecuencia de uso',
                    'Interacciones con la aplicación (toques, deslizamientos)',
                    'Eventos de la aplicación (ej: apertura de perfil de artesano, visualización de producto)',
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Esta información es completamente anónima y no puede ser utilizada para identificarte personalmente.',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            _buildSection(
              '2. Cómo Utilizamos la Información',
              [
                const Text(
                  'Utilizamos la información anónima recopilada exclusivamente para:',
                  style: TextStyle(fontSize: 16, height: 1.6),
                ),
                const SizedBox(height: 8),
                _buildBulletList([
                  'Mantener y mejorar la funcionalidad de la aplicación',
                  'Analizar patrones de uso para optimizar la experiencia del usuario',
                  'Identificar y corregir errores técnicos',
                  'Entender qué contenido es más popular (productos, artesanos)',
                  'Mejorar el rendimiento y la velocidad de la aplicación',
                  'Generar estadísticas agregadas y anónimas sobre el uso de la app',
                ]),
                const SizedBox(height: 12),
                const Text(
                  'NO utilizamos esta información para:',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildBulletList([
                  'Identificarte personalmente',
                  'Enviarte publicidad o marketing',
                  'Vender o compartir tus datos con terceros',
                  'Rastrear tu ubicación física',
                  'Crear perfiles de usuario',
                ]),
              ],
            ),
            _buildSection(
              '3. Contacto con Artesanos',
              [
                const Text(
                  'Nuestra aplicación muestra información de contacto de artesanos (teléfono, WhatsApp, redes sociales). Cuando decides contactar a un artesano:',
                  style: TextStyle(fontSize: 16, height: 1.6),
                ),
                const SizedBox(height: 8),
                _buildBulletList([
                  'El contacto se realiza FUERA de nuestra aplicación (a través de WhatsApp, llamada telefónica, etc.)',
                  'Nosotros NO vemos, almacenamos ni tenemos acceso a las conversaciones o información que compartes con los artesanos',
                  'Cualquier información personal que compartas con un artesano es directamente entre tú y el artesano',
                  'No somos responsables del uso que los artesanos hagan de tu información personal',
                ]),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Recomendamos tener precaución al compartir información personal con terceros y verificar la identidad de los artesanos antes de realizar transacciones.',
                          style: TextStyle(fontSize: 14, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            _buildSection(
              '4. Compartir Información',
              [
                const Text(
                  'NO vendemos, alquilamos ni compartimos tu información personal con terceros porque NO recopilamos información personal identificable.',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'La información anónima de analytics es procesada por:',
                  style: TextStyle(fontSize: 16, height: 1.6),
                ),
                const SizedBox(height: 8),
                _buildBulletList([
                  'Firebase Analytics (Google): Procesa datos anónimos de uso de la aplicación',
                  'Google Play Services: Servicios del sistema Android (solo en dispositivos Android)',
                ]),
                const SizedBox(height: 12),
                const Text(
                  'Estos servicios procesan datos de forma agregada y anónima, sin vincularlos a tu identidad personal.',
                  style: TextStyle(fontSize: 16, height: 1.6),
                ),
              ],
            ),
            _buildSection(
              '5. Servicios de Terceros',
              [
                const Text(
                  'Nuestra aplicación utiliza los siguientes servicios de terceros que pueden recopilar información anónima:',
                  style: TextStyle(fontSize: 16, height: 1.6),
                ),
                const SizedBox(height: 8),
                _buildBulletList([
                  'Firebase Analytics (Google): Para análisis de uso anónimo y mejora de la aplicación',
                  'Firebase Cloud Firestore: Para almacenar información de productos y artesanos (NO datos de usuarios)',
                  'Firebase Storage: Para almacenar imágenes de productos y artesanos',
                  'Google Play Services: Servicios del sistema Android (solo en dispositivos Android)',
                ]),
                const SizedBox(height: 12),
                const Text(
                  'Políticas de privacidad de terceros:',
                  style: TextStyle(fontSize: 16, height: 1.6, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                _buildBulletList([
                  'Firebase: https://firebase.google.com/support/privacy',
                  'Google Privacy Policy: https://policies.google.com/privacy',
                ]),
              ],
            ),
            _buildSection(
              '6. Seguridad de los Datos',
              [
                const Text(
                  'Aunque no recopilamos información personal identificable, implementamos medidas de seguridad para proteger la información anónima que procesamos:',
                  style: TextStyle(fontSize: 16, height: 1.6),
                ),
                const SizedBox(height: 8),
                _buildBulletList([
                  'Cifrado de datos en tránsito (HTTPS/SSL)',
                  'Almacenamiento seguro en servidores de Firebase (Google Cloud)',
                  'Acceso restringido a la base de datos de productos y artesanos',
                  'Monitoreo regular de vulnerabilidades de seguridad',
                  'Actualizaciones periódicas de la aplicación',
                ]),
                const SizedBox(height: 12),
                const Text(
                  'Sin embargo, ningún método de transmisión por Internet o almacenamiento electrónico es 100% seguro.',
                  style: TextStyle(fontSize: 16, height: 1.6),
                ),
              ],
            ),
            _buildSection(
              '7. Retención de Datos',
              [
                const Text(
                  'Los datos anónimos de analytics se conservan según las políticas de Firebase Analytics (generalmente 14 meses). No conservamos información personal porque no la recopilamos.',
                  style: TextStyle(fontSize: 16, height: 1.6),
                ),
              ],
            ),
            _buildSection(
              '8. Tus Derechos',
              [
                const Text(
                  'Dado que NO recopilamos información personal identificable:',
                  style: TextStyle(fontSize: 16, height: 1.6),
                ),
                const SizedBox(height: 8),
                _buildBulletList([
                  'No almacenamos datos personales que puedan ser accedidos, rectificados o eliminados',
                  'No creamos perfiles de usuario',
                  'No rastreamos tu identidad personal',
                ]),
                const SizedBox(height: 12),
                const Text(
                  'Si deseas limitar la recopilación de datos anónimos de analytics:',
                  style: TextStyle(fontSize: 16, height: 1.6, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                _buildBulletList([
                  'Puedes desinstalar la aplicación en cualquier momento',
                  'Puedes desactivar el seguimiento de analytics en la configuración de tu dispositivo (Android: Configuración > Google > Anuncios > Desactivar personalización de anuncios)',
                ]),
              ],
            ),
            _buildSection(
              '9. Privacidad de los Niños',
              [
                const Text(
                  'Nuestra aplicación es apta para todas las edades. No recopilamos intencionalmente información personal de niños menores de 13 años ni de ningún otro usuario. La información anónima de analytics que recopilamos no puede ser utilizada para identificar a menores.',
                  style: TextStyle(fontSize: 16, height: 1.6),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Si eres padre o tutor y crees que tu hijo ha proporcionado información personal a través de contacto directo con artesanos (fuera de nuestra app), por favor contacta directamente al artesano correspondiente.',
                  style: TextStyle(fontSize: 16, height: 1.6),
                ),
              ],
            ),
            _buildSection(
              '10. Cambios a esta Política',
              [
                const Text(
                  'Podemos actualizar nuestra Política de Privacidad periódicamente. Te notificaremos sobre cualquier cambio significativo mediante:',
                  style: TextStyle(fontSize: 16, height: 1.6),
                ),
                const SizedBox(height: 8),
                _buildBulletList([
                  'Actualización de la fecha de "Última actualización" en esta página',
                  'Notificación dentro de la aplicación (para cambios importantes)',
                  'Publicación en nuestro sitio web',
                ]),
                const SizedBox(height: 12),
                const Text(
                  'Te recomendamos revisar esta Política de Privacidad periódicamente para estar informado sobre cómo protegemos tu información.',
                  style: TextStyle(fontSize: 16, height: 1.6),
                ),
              ],
            ),
            _buildSection(
              '11. Permisos de la Aplicación',
              [
                const Text(
                  'Nuestra aplicación puede solicitar los siguientes permisos del sistema:',
                  style: TextStyle(fontSize: 16, height: 1.6),
                ),
                const SizedBox(height: 8),
                _buildBulletList([
                  'Internet: Para cargar información de productos y artesanos desde Firebase',
                  'Almacenamiento: Para cachear imágenes y mejorar el rendimiento (opcional)',
                ]),
                const SizedBox(height: 12),
                const Text(
                  'NO solicitamos permisos para:',
                  style: TextStyle(fontSize: 16, height: 1.6, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildBulletList([
                  'Ubicación (GPS)',
                  'Cámara',
                  'Micrófono',
                  'Contactos',
                  'Calendario',
                  'Llamadas telefónicas',
                ]),
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
                  'Email: contacto@manos-del-pueblo.ar',
                  'Sitio web: https://www.manos-del-pueblo.ar',
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
            const SizedBox(height: 120),
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
