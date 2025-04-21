import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final Box<Map> cartBox = Hive.box<Map>('shoppingCart');

  void _updateQuantity(String key, int change) {
    final item = Map<String, dynamic>.from(cartBox.get(key)!);
    final newQuantity = item['quantity'] + change;
    if (newQuantity > 0) {
      item['quantity'] = newQuantity;
      cartBox.put(key, item);
    } else {
      cartBox.delete(key);
    }
  }

  void _removeItem(String key) {
    cartBox.delete(key);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        backgroundColor: Colors.brown[400],
        foregroundColor: Colors.white,
      ),
      body: ValueListenableBuilder(
        valueListenable: cartBox.listenable(),
        builder: (context, Box<Map> box, _) {
          if (box.isEmpty) {
            return const Center(
              child: Text('Your cart is empty!'),
            );
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final key = box.keyAt(index) as String;
              final item = Map<String, dynamic>.from(box.get(key)!);
              final String name = item['name'] ?? 'Unknown Item';
              final String size = item['size'] ?? '-';
              final int quantity = item['quantity'] ?? 0;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  // leading: Image.asset(imagePath, width: 50, height: 50), // Optional image
                  title: Text('$name ($size)'),
                  subtitle: Text('Quantity: $quantity'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () => _updateQuantity(key, -1),
                        tooltip: 'Decrease Quantity',
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => _updateQuantity(key, 1),
                        tooltip: 'Increase Quantity',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeItem(key),
                        tooltip: 'Remove Item',
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
