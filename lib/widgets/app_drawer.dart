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
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: Color(0xFF5D4037)),
                accountName: Text(
                  "Manos del Pueblo",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                accountEmail: Text("Catálogo de Artesanos Locales"),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.storefront,
                    color: Color(0xFF5D4037),
                    size: 35,
                  ),
                ),
              ),
              ListTile(
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
              ListTile(
                leading: const Icon(Icons.person_add, color: Colors.brown),
                title: const Text('Añadir Artesano'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/add-artisan');
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.add_shopping_cart,
                  color: Colors.brown,
                ),
                title: const Text('Añadir Producto'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/add-product');
                },
              ),
              ListTile(
                leading: const Icon(Icons.school, color: Colors.brown),
                title: const Text('Cursos'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/courses');
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.brown),
                title: const Text("Sobre Nosotros"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/about');
                },
              ),
              if (artisans.isNotEmpty) ...[
                const Divider(),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Nuestros Artesanos",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...artisans.map(
                  (artisan) => ListTile(
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
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
