import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Plugin para abrir WhatsApp
import '../models/artisan.dart';
import '../data/database.dart'; // Para buscar sus productos

class ArtisanProfileScreen extends StatelessWidget {
  final Artisan artisan;

  const ArtisanProfileScreen({super.key, required this.artisan});

  // Función para abrir WhatsApp
  Future<void> _launchWhatsApp() async {
    // Limpiamos el número por si tiene espacios o guiones
    final number = artisan.whatsapp.replaceAll(RegExp(r'[^\d]'), ''); 
    final message = "Hola ${artisan.nombre}, te contacto desde Manos del Pueblo.";
    final Uri url = Uri.parse("https://wa.me/$number?text=${Uri.encodeComponent(message)}");

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('No se pudo abrir WhatsApp');
    }
  }

  // Función para llamar por teléfono
  Future<void> _launchCall() async {
    final Uri url = Uri.parse("tel:${artisan.telefono}");
    if (!await launchUrl(url)) {
      throw Exception('No se pudo llamar');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Buscamos solo los productos de ESTE artesano
    final myProducts = getProductsByArtisan(artisan.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // --- ENCABEZADO CON FOTO ---
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true, // Se queda pegado arriba al bajar
            backgroundColor: const Color(0xFF5D4037),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(artisan.nombre, 
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 10, color: Colors.black)])),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(artisan.fotoPerfil, fit: BoxFit.cover),
                  // Un degradado negro para que se lea el texto
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

          // --- INFORMACIÓN Y CONTACTO ---
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
                      Text(artisan.ubicacion, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Botones de Acción
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _launchWhatsApp,
                          icon: const Icon(Icons.chat), // Icono genérico o de Whatsapp si tienes assets
                          label: const Text("WhatsApp"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _launchCall,
                          icon: const Icon(Icons.phone),
                          label: const Text("Llamar"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.brown,
                            side: const BorderSide(color: Colors.brown),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),
                  const Text("Mi Historia", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(artisan.historia, style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87)),
                  
                  const SizedBox(height: 30),
                  const Text("Mis Productos", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),

          // --- GRILLA DE SUS PRODUCTOS ---
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                   // Aquí deberíamos reutilizar tu ProductCard, 
                   // pero para no complicar imports hago una simple aquí.
                   // Si quieres usar ProductCard, impórtala de home_screen si la sacaste a un archivo aparte.
                   final product = myProducts[index];
                   return Card(
                     clipBehavior: Clip.antiAlias,
                     child: Column(
                       children: [
                         Expanded(child: Image.asset(product.imagePath, fit: BoxFit.cover)),
                         Padding(
                           padding: const EdgeInsets.all(8.0),
                           child: Text(product.nombre, maxLines: 1, overflow: TextOverflow.ellipsis),
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
          // Espacio extra abajo
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}