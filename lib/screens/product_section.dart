import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:barmo/models/producto_model.dart';
import 'package:barmo/controllers/mongo_service.dart';

class CategorySection extends StatelessWidget {
  final Function(String) onCategorySelected;

  const CategorySection({required this.onCategorySelected, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildCategoryItem('All', Icons.all_inclusive, Colors.blue),
          _buildCategoryItem('Drink', Icons.local_drink, Colors.pink),
          _buildCategoryItem('Cervezas', Icons.local_bar, Colors.amber),
          _buildCategoryItem('Snack', Icons.fastfood, Colors.orange),
          _buildCategoryItem('Alitas', Icons.fastfood, Colors.pink),
          _buildCategoryItem('Botellas', Icons.local_drink, Colors.blue),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String label, IconData icon, Color color) {
    return GestureDetector(
      onTap: () => onCategorySelected(label),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color.fromARGB(255, 8, 8, 8),
            child: Icon(icon, color: color, size: 30),
          ),
          SizedBox(height: 5),
          Text(label,
              style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0))),
        ],
      ),
    );
  }
}

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
      print("Error al cargar los productos: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_productos.isEmpty) {
      return Center(child: Text('No hay productos en esta categoría.'));
    }

    return Expanded(
      child: ListView.builder(
        itemCount: _productos.length,
        itemBuilder: (context, index) {
          final producto = _productos[index];
          return ProductCard(
            title: producto.nombre,
            price: producto.precio.toString(),
            imagePath: producto.imagen,
          );
        },
      ),
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
      margin: EdgeInsets.symmetric(vertical: 10.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.0),
              topRight: Radius.circular(15.0),
            ),
            child: CachedNetworkImage(
              imageUrl: imagePath, // URL de la imagen en MongoDB
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
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
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
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
