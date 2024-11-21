import 'package:flutter/material.dart';

class CategorySelector extends StatelessWidget {
  final Function(String) onCategorySelected;

  const CategorySelector({required this.onCategorySelected, super.key});

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
          const SizedBox(height: 5),
          Text(label,
              style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
        ],
      ),
    );
  }
}
