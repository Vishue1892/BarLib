import 'package:mongo_dart/mongo_dart.dart';

class ProductoModel {
  final ObjectId id;
  final String nombre;
  final double precio;
  final String categoria;
  final String imagen;
  final int cantidad;
  final String unidad;

  ProductoModel({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.categoria,
    required this.imagen,
    required this.cantidad,
    required this.unidad,
  });

  // Conversión de JSON a objeto ProductoModel
  factory ProductoModel.fromJson(Map<String, dynamic> json) {
    return ProductoModel(
      id: json['_id'] as ObjectId,
      nombre: json['nombre'] as String,
      precio: json['precio'] as double,
      categoria: json['categoria'] as String,
      imagen: json['imagen'] as String,
      cantidad: json['cantidad'] as int,
      unidad: json['unidad'] as String,
    );
  }

  // Conversión de objeto ProductoModel a JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'nombre': nombre,
      'precio': precio,
      'categoria': categoria,
      'imagen': imagen,
      'cantidad': cantidad,
      'unidad': unidad,
    };
  }
}
