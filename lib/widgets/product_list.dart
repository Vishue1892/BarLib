import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:barmo/models/producto_model.dart';
import 'package:barmo/controllers/mongo_service.dart';

class ProductList extends StatefulWidget {
  final String selectedCategory;

  const ProductList({required this.selectedCategory, super.key});

  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  List<ProductoModel> _productos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProductos();
  }

  Future<void> _fetchProductos() async {
    try {
      await MongoService().connect();
      List<ProductoModel> productos = await MongoService().getProductos();
      setState(() {
        _productos = widget.selectedCategory == 'All'
            ? productos
            : productos
                .where(
                    (producto) => producto.categoria == widget.selectedCategory)
                .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_productos.isEmpty) {
      return const Center(child: Text('No hay productos en esta categoría.'));
    }

    return ListView.builder(
      itemCount: _productos.length,
      itemBuilder: (context, index) {
        final producto = _productos[index];
        return ProductCard(
          title: producto.nombre,
          price: producto.precio.toString(),
          imagePath: producto.imagen,
        );
      },
    );
  }
}

class ProductCard extends StatelessWidget {
  final String title;
  final String price;
  final String imagePath;

  const ProductCard({
    required this.title,
    required this.price,
    required this.imagePath,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15.0),
              topRight: Radius.circular(15.0),
            ),
            child: CachedNetworkImage(
              imageUrl: imagePath, // URL de la imagen en MongoDB
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
              fit: BoxFit.cover,
              height: 150,
              width: double.infinity,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text(
                  '\$$price',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade900),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
