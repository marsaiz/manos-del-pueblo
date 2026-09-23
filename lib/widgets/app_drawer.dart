import 'package:flutter/material.dart';
import '../models/artisan.dart';
import '../services/firestore_service.dart';
import '../screens/artisan_profile_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Artisan>>(
      stream: FirestoreService.getArtisans(),
      builder: (context, snapshot) {
        final artisans = snapshot.data ?? [];
        return Drawer(
          child: SafeArea(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(color: Color(0xFF5D4037)),
                  accountName: const Text(
                    "Manos del Pueblo",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  accountEmail: const Text("Catálogo de Artesanos Locales"),
                  currentAccountPicture: Semantics(
                    label: 'Logo de Manos del Pueblo',
                    image: true,
                    child: const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.storefront,
                        color: Color(0xFF5D4037),
                        size: 35,
                      ),
                    ),
                  ),
                ),
                Semantics(
                  label: 'Ir a la pantalla de inicio',
                  child: ListTile(
                    leading: const Icon(Icons.home, color: Colors.brown),
                    title: const Text('Inicio'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/',
                        (route) => false,
                      );
                    },
                  ),
                ),

                Semantics(
                  label: 'Ver cursos y talleres disponibles',
                  child: ListTile(
                    leading: const Icon(Icons.school, color: Colors.brown),
                    title: const Text('Cursos'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/courses');
                    },
                  ),
                ),
                Semantics(
                  label: 'Ver ferias de artesanos',
                  child: ListTile(
                    leading: const Icon(Icons.storefront, color: Colors.brown),
                    title: const Text('Ferias'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/fairs');
                    },
                  ),
                ),
                Semantics(
                  label: 'Información sobre Manos del Pueblo',
                  child: ListTile(
                    leading: const Icon(Icons.info_outline, color: Colors.brown),
                    title: const Text("Sobre Nosotros"),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/about');
                    },
                  ),
                ),
                if (artisans.isNotEmpty) ...[
                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "Nuestros Artesanos",
                      style: TextStyle(
                        color: Color(0xFF616161), // grey[700] - cumple WCAG AA
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...(() {
                    // Agrupar artesanos por localidad
                    final Map<String, List<Artisan>> artisansByLocality = {};
                    for (var artisan in artisans) {
                      final loc = artisan.localidad.trim().isNotEmpty
                          ? artisan.localidad.trim()
                          : 'Otras localidades';
                      artisansByLocality.putIfAbsent(loc, () => []).add(artisan);
                    }
                    final sortedLocalities = artisansByLocality.keys.toList()..sort();

                    return sortedLocalities.map((locality) {
                      final localArtisans = artisansByLocality[locality]!;
                      return ExpansionTile(
                        leading: const Icon(Icons.location_on, color: Colors.brown),
                        title: Text(
                          locality,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        children: localArtisans.map((artisan) => ListTile(
                          contentPadding: const EdgeInsets.only(left: 40, right: 16),
                          leading: CircleAvatar(
                            backgroundImage: (artisan.fotoPerfil.startsWith('http'))
                                ? NetworkImage(artisan.fotoPerfil)
                                : AssetImage(artisan.fotoPerfil) as ImageProvider,
                          ),
                          title: Text(artisan.nombre),
                          subtitle: Text(artisan.ubicacion),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ArtisanProfileScreen(artisan: artisan),
                              ),
                            );
                          },
                        )).toList(),
                      );
                    });
                  })(),
                  // Espacio adicional al final para evitar que los botones de navegación tapen el último artesano
                  const SizedBox(height: 40),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
