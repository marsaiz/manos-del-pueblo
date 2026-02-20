import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/product.dart';
import '../models/artisan.dart';
import 'artisan_profile_screen.dart';
import 'admin/edit_product_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final Artisan artisan;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.artisan,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Función para compartir
  void _shareProduct() async {
    final String mensaje =
        "¡Mira esta artesanía de ${widget.artisan.nombre}!\n\n"
        "*${widget.product.nombre}* - ${double.tryParse(widget.product.precio) != null ? '\${widget.product.precio}' : widget.product.precio}\n\n"
        "Ver más aquí: https://manos-del-pueblo.ar";

    await Share.share(mensaje);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product.nombre,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          // Botón de editar
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar producto',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EditProductScreen(product: widget.product),
                ),
              );
            },
          ),
          // Botón de compartir
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Compartir con amigos',
            onPressed: _shareProduct,
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- CARRUSEL DE IMÁGENES CON ZOOM ---
            Stack(
              children: [
                SizedBox(
                  height: 400,
                  width: double.infinity,
                  child: widget.product.imagePaths.isNotEmpty
                      ? PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                            });
                          },
                          itemCount: widget.product.imagePaths.length,
                          itemBuilder: (context, index) {
                            final path = widget.product.imagePaths[index];
                            return InteractiveViewer(
                              minScale: 1.0,
                              maxScale: 3.0,
                              child: Hero(
                                tag: index == 0
                                    ? 'product_image_${widget.product.id}'
                                    : 'product_image_${widget.product.id}_$index',
                                child: (path.startsWith('http'))
                                    ? Image.network(path, fit: BoxFit.contain)
                                    : Image.asset(path, fit: BoxFit.contain),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey[100],
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 100,
                            color: Colors.grey,
                          ),
                        ),
                ),
                // Indicadores de página
                if (widget.product.imagePaths.length > 1)
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.product.imagePaths.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 12 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? Colors.brown
                                : Colors.brown.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                // Botones de navegación (opcional, para visual)
                if (widget.product.imagePaths.length > 1)
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (_currentPage > 0)
                            IconButton(
                              onPressed: () => _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              ),
                              icon: const Icon(
                                Icons.arrow_back_ios,
                                color: Colors.brown,
                              ),
                            )
                          else
                            const SizedBox(width: 48),
                          if (_currentPage <
                              widget.product.imagePaths.length - 1)
                            IconButton(
                              onPressed: () => _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              ),
                              icon: const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.brown,
                              ),
                            )
                          else
                            const SizedBox(width: 48),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    double.tryParse(widget.product.precio) != null
                        ? '\${widget.product.precio}'
                        : widget.product.precio,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      const Text(
                        "Creado por: ",
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      ActionChip(
                        avatar: CircleAvatar(
                          backgroundImage:
                              (widget.artisan.fotoPerfil.startsWith('http'))
                              ? NetworkImage(widget.artisan.fotoPerfil)
                              : AssetImage(widget.artisan.fotoPerfil)
                                    as ImageProvider,
                        ),
                        label: Text(
                          widget.artisan.nombre,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        backgroundColor: Colors.brown[50],
                        side: BorderSide.none,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ArtisanProfileScreen(artisan: widget.artisan),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Historia del producto",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.descripcion,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ArtisanProfileScreen(artisan: widget.artisan),
                          ),
                        );
                      },
                      icon: const Icon(Icons.storefront),
                      label: const Text("Visitar Tienda del Artesano"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.brown,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  // Espacio adicional para evitar que los botones de navegación de Android tapen el contenido
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
