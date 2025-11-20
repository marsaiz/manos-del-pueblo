import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Plugin para abrir URLs
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Para el icono de Instagram
import '../models/artisan.dart';
import '../data/database.dart'; // Para buscar sus productos

class ArtisanProfileScreen extends StatelessWidget {
  final Artisan artisan;

  const ArtisanProfileScreen({super.key, required this.artisan});

  // --- 1. Lógica para abrir WhatsApp ---
  Future<void> _launchWhatsApp() async {
    // Limpiamos el número dejando solo dígitos
    final number = artisan.whatsapp.replaceAll(RegExp(r'[^\d]'), '');
    final message = "Hola ${artisan.nombre}, te contacto desde Manos del Pueblo.";
    // Codificamos la URL
    final Uri url = Uri.parse("https://wa.me/$number?text=${Uri.encodeComponent(message)}");

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

  // --- 3. Lógica para Llamar ---
  Future<void> _launchCall() async {
    final Uri url = Uri.parse("tel:${artisan.telefono}");
    if (!await launchUrl(url)) {
      throw Exception('No se pudo llamar');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos los productos (Asumiendo que esta función existe en tu database.dart)
    final myProducts = getProductsByArtisan(artisan.id);

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
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(artisan.fotoPerfil, fit: BoxFit.cover),
                  // Degradado para legibilidad
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black54, Colors.transparent],
                      ),
                    ),
                  ),
                ],
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
                    children: [
                      const Icon(Icons.location_on, color: Colors.brown),
                      const SizedBox(width: 8),
                      Text(
                        artisan.ubicacion,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Icon(Icons.chat),
                        ),
                      ),
                      
                      const SizedBox(width: 10),

                      // 2. Botón Instagram (Solo si existe)
                      if (artisan.instagram.isNotEmpty) ...[
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _launchInstagram,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE1306C), // Color marca Instagram
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const FaIcon(FontAwesomeIcons.instagram, size: 24), // ✅ ESTO ES LO CORRECTO
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
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                      const Expanded(child: Text("WhatsApp", textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.grey))),
                      const SizedBox(width: 10),
                      if (artisan.instagram.isNotEmpty) ...[
                        const Expanded(child: Text("Instagram", textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.grey))),
                        const SizedBox(width: 10),
                      ],
                      const Expanded(child: Text("Llamar", textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.grey))),
                    ],
                  ),

                  const SizedBox(height: 25),
                  
                  // Historia
                  const Text("Mi Historia", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    artisan.historia,
                    style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
                  ),

                  const SizedBox(height: 30),
                  const Text("Mis Productos", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),

          // --- C. GRILLA DE PRODUCTOS ---
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final product = myProducts[index];
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    elevation: 3,
                    child: Column(
                      children: [
                        Expanded(
                          child: Image.asset(product.imagePath, fit: BoxFit.cover),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            product.nombre,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                childCount: myProducts.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
            ),
          ),
          
          // Espacio final para scrolling cómodo
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}