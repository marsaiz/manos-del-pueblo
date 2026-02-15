import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Plugin para abrir URLs
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Para el icono de Instagram
import '../models/artisan.dart';
import '../models/product.dart';
import '../services/firestore_service.dart';
import '../services/image_upload_service.dart'; // Para borrar carpeta de Storage
import 'home_screen.dart';
import '../widgets/app_drawer.dart';

class ArtisanProfileScreen extends StatelessWidget {
  final Artisan artisan;

  const ArtisanProfileScreen({super.key, required this.artisan});

  // --- 1. Lógica para abrir WhatsApp ---
  Future<void> _launchWhatsApp() async {
    // Limpiamos el número dejando solo dígitos
    final number = artisan.whatsapp.replaceAll(RegExp(r'[^\d]'), '');
    final message =
        "Hola ${artisan.nombre}, te contacto desde Manos del Pueblo.";
    // Codificamos la URL
    final Uri url = Uri.parse(
      "https://wa.me/$number?text=${Uri.encodeComponent(message)}",
    );

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('No se pudo abrir WhatsApp');
    }
  }

  // --- 2. Lógica para abrir Instagram ---
  Future<void> _launchInstagram() async {
    // Limpieza básica del usuario (quitar espacios y @ si la pusieron)
    String username = artisan.instagram.trim();
    if (username.startsWith('@')) {
      username = username.substring(1);
    }

    if (username.isEmpty) return;

    final Uri url = Uri.parse("https://www.instagram.com/$username/");

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('No se pudo abrir Instagram');
    }
  }

  // --- 2.5 Lógica para abrir Facebook ---
  Future<void> _launchFacebook() async {
    String fb = artisan.facebook.trim();
    if (fb.isEmpty) return;

    Uri url;
    if (fb.startsWith('http')) {
      url = Uri.parse(fb);
    } else {
      url = Uri.parse("https://www.facebook.com/$fb");
    }

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('No se pudo abrir Facebook');
    }
  }

  // --- 3. Lógica para Llamar ---
  Future<void> _launchCall() async {
    final Uri url = Uri.parse("tel:${artisan.telefono}");
    if (!await launchUrl(url)) {
      throw Exception('No se pudo llamar');
    }
  }

  // --- 4. Lógica para Eliminar Artesano ---
  Future<void> _deleteArtisan(BuildContext context) async {
    final TextEditingController pinController = TextEditingController();

    // Diálogo de confirmación con PIN
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar Artesano?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Esta acción borrará permanentemente al artesano, todos sus productos e imágenes.',
              style: TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: pinController,
              decoration: const InputDecoration(
                labelText: 'Ingresa el PIN de seguridad',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () {
              if (pinController.text.trim() == '4628') {
                Navigator.pop(context, true);
              } else {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('PIN incorrecto')));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'ELIMINAR TODO',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!context.mounted) return;
      try {
        // Mostrar indicador de carga
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );

        // A. Eliminar de Firestore (Artisano + Productos)
        await FirestoreService.deleteArtisanCascade(artisan.id);

        // B. Eliminar carpeta de Storage
        await ImageUploadService.deleteArtisanFolder(artisan.id);

        if (context.mounted) {
          // Cerrar cargador
          Navigator.pop(context);
          // Ir al home
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Artesano y datos eliminados con éxito'),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.pop(context); // Cerrar cargador
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('❌ Error al eliminar: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Product>>(
      stream: FirestoreService.getProducts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Filtramos solo los productos de este artesano
        final myProducts = snapshot.data!
            .where((p) => p.artisanId == artisan.id)
            .toList();

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // --- A. ENCABEZADO (FOTO + NOMBRE) ---
              SliverAppBar(
                expandedHeight: 250.0,
                pinned: true,
                backgroundColor: const Color(0xFF5D4037),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    artisan.nombre,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                    ),
                  ),
                  background: Container(
                    color: const Color(0xFF5D4037).withValues(alpha: 0.1),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        (artisan.fotoPerfil.startsWith('http'))
                            ? Image.network(
                                artisan.fotoPerfil,
                                fit: BoxFit.contain,
                              )
                            : Image.asset(
                                artisan.fotoPerfil,
                                fit: BoxFit.contain,
                              ),
                        // Degradado para legibilidad (opcional con contain, pero mantenido para estilo)
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Colors.black26, Colors.transparent],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // --- B. INFORMACIÓN DEL ARTESANO ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ubicación
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.brown,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  artisan.ubicacion,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "${artisan.direccion}\n${artisan.localidad}, ${artisan.provincia} (${artisan.codigoPostal})",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // --- BOTONES DE ACCIÓN ---
                      Row(
                        children: [
                          // 1. Botón WhatsApp
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _launchWhatsApp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[600],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Icon(Icons.chat),
                            ),
                          ),

                          const SizedBox(width: 10),

                          if (artisan.instagram.isNotEmpty) ...[
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _launchInstagram,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(
                                    0xFFE1306C,
                                  ), // Color marca Instagram
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const FaIcon(
                                  FontAwesomeIcons.instagram,
                                  size: 24,
                                ), // ✅ ESTO ES LO CORRECTO
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],

                          // 2.5 Botón Facebook (Solo si existe)
                          if (artisan.facebook.isNotEmpty) ...[
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _launchFacebook,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1877F2),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Icon(Icons.facebook),
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],

                          // 3. Botón Llamar
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _launchCall,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.brown,
                                side: const BorderSide(color: Colors.brown),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Icon(Icons.phone),
                            ),
                          ),
                        ],
                      ),

                      // Etiquetas de texto debajo de los botones
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "WhatsApp",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (artisan.instagram.isNotEmpty) ...[
                            const Expanded(
                              child: Text(
                                "Instagram",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                          if (artisan.facebook.isNotEmpty) ...[
                            const Expanded(
                              child: Text(
                                "Facebook",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                          const Expanded(
                            child: Text(
                              "Llamar",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      // Historia
                      const Text(
                        "Mi Historia",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        artisan.historia,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 30),
                      const Text(
                        "Mis Productos",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),

              // --- C. GRILLA DE PRODUCTOS ---
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final product = myProducts[index];
                    return ProductCard(product: product, artisans: [artisan]);
                  }, childCount: myProducts.length),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.70,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                ),
              ),

              // Espacio final para scrolling cómodo
              const SliverToBoxAdapter(
                child: SizedBox(height: 40),
              ),
            ],
          ),
        );
      },
    );
  }
}
