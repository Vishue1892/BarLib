import 'package:flutter/material.dart';
import 'package:barmo/screens/qr_scanner.dart';
import 'package:barmo/screens/pedido.dart';
import 'package:barmo/controllers/mongo_service.dart';
import 'package:barmo/widgets/category_selector.dart'; // Archivo importado
import 'package:barmo/widgets/product_list.dart'; // Archivo importado
import 'package:barmo/models/producto_model.dart'; // Importa tu modelo de producto

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedCategory = 'All';
  String? scannedTable;
  String? scannedFloor;
  List<ProductoModel> _productos = [];
  List<ProductoModel> _productosFiltrados = [];
  String _query = "";

  @override
  void initState() {
    super.initState();
    print("Inicializando HomeScreen");
    _tabController = TabController(length: 5, vsync: this, initialIndex: 0);

    // Carga inicial de productos
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    try {
      final productos = await MongoService().getProductos(forceRefresh: false);
      setState(() {
        _productos = productos;
        _productosFiltrados = productos; // Inicialmente muestra todos
      });
    } catch (e) {
      print("Error al cargar productos: $e");
    }
  }

  void _filtrarProductos(String query) {
    setState(() {
      _query = query.toLowerCase();
      _productosFiltrados = _productos.where((producto) {
        return producto.nombre.toLowerCase().contains(_query) ||
            producto.categoria.toLowerCase().contains(_query);
      }).toList();
    });
  }

  void updateScannedInfo(String table, String floor) {
    setState(() {
      scannedTable = table;
      scannedFloor = floor;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red.shade900,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage('assets/images/perfil.jpg'),
              radius: 20,
            ),
            SizedBox(width: 10),
            Text(
              'Lorelei Leon',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: ImageIcon(
              AssetImage('assets/icons/icons8-mesa-de-restaurante-64.png'),
              size: 40,
              color: Colors.black,
            ),
            onPressed: () {
              if (scannedTable != null && scannedFloor != null) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Información de la Mesa"),
                    content: Text("Mesa: $scannedTable\nPiso: $scannedFloor"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Cerrar"),
                      ),
                    ],
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("No se ha escaneado ninguna mesa."),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Aquí se coloca el FutureBuilder para cargar los productos
          Column(
            children: [
              // Campo de búsqueda
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar',
                    prefixIcon: Icon(Icons.search),
                    filled: true,
                    fillColor: const Color.fromARGB(255, 255, 255, 255),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (query) {
                    _filtrarProductos(query); // Usamos la función aquí
                  },
                ),
              ),
              // Widget para seleccionar la categoría
              CategorySelector(
                onCategorySelected: (category) {
                  setState(() {
                    selectedCategory = category;
                  });
                },
              ),
              // Lista de productos filtrados
              Expanded(
                child: _productosFiltrados.isEmpty
                    ? Center(child: Text('No se encontraron productos.'))
                    : ProductList(
                        selectedCategory:
                            selectedCategory, // Asegúrate de pasar los productos filtrados
                      ),
              ),
            ],
          ),
          Center(
              child: Text('Pantalla de Ofertas y Promociones(Registrandose)')),
          Center(child: Text('Pantalla de QR')),
          PedidoScreen(),
          Center(child: Text('Pantalla de Registrarse')),
        ],
      ),
      bottomNavigationBar: Stack(
        children: [
          BottomAppBar(
            child: TabBar(
              controller: _tabController,
              tabs: [
                Tab(icon: Icon(Icons.home), text: 'Inicio'),
                Tab(icon: Icon(Icons.local_offer), text: 'Ofertas'),
                SizedBox(width: 10),
                Tab(icon: Icon(Icons.shopping_cart), text: 'Pedido'),
                Tab(icon: Icon(Icons.person_2), text: 'Registro'),
              ],
              indicatorColor: const Color.fromARGB(255, 242, 56, 56),
              labelColor: const Color.fromARGB(255, 243, 46, 46),
              unselectedLabelColor: const Color.fromARGB(255, 60, 60, 60),
            ),
          ),
          Positioned(
            bottom: 20,
            left: MediaQuery.of(context).size.width / 2 - 30,
            child: FloatingActionButton(
              backgroundColor: const Color.fromARGB(255, 255, 121, 26),
              onPressed: () async {
                // Llamada al escáner QR
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QrScanner(
                      onCodeScanned: (table, floor) {
                        updateScannedInfo(
                            table, floor); // Actualiza la info escaneada
                      },
                    ),
                  ),
                );
                if (result != null) {
                  setState(() {
                    scannedTable = result['table'];
                    scannedFloor = result['floor'];
                  });
                }
              },
              child: Icon(Icons.qr_code_scanner,
                  size: 40, color: const Color.fromARGB(255, 130, 46, 34)),
            ),
          ),
        ],
      ),
    );
  }
}
