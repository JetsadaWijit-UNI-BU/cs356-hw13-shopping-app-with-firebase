import 'package:act13_1640705339/products/product_form_screen.dart';
import 'package:act13_1640705339/products/product_manager.dart';
import 'package:act13_1640705339/products/product_model.dart';
import 'package:act13_1640705339/products/product_search_screen.dart';
import 'package:act13_1640705339/products/product_util.dart';
import 'package:flutter/material.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final ProductManager _productManager = ProductManager();
  // For display items (list or grid view)
  ProductView _productView = ProductView.list;
  List<ProductModel> _products = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Products'),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProductSearchScreen()),
                );
              },
              icon: const Icon(Icons.search),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _productView = _productView == ProductView.list
                      ? ProductView.grid
                      : ProductView.list;
                });
              },
              icon: Icon(
                _productView == ProductView.list ? Icons.grid_view : Icons.list,
              ),
            ),
          ],
        ),
        body: StreamBuilder<List<ProductModel>>(
          stream: _productManager.getProductsStream(),
          builder: (context, snapshot) {
            // 1. Handle Loading State
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            // 2. Handle Errors
            if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong!'));
            }
            // 3. Handle Empty Data
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No products found.'));
            }
            // 4. Build the List
            _products = snapshot.data ?? [];
            if (_productView == ProductView.grid) {
              // TODO : import product_util.dart
              return productInGrid(_products);
            } else {
              // TODO : import product_util.dart
              return productInList(_products);
            }
          },
        ),
      floatingActionButton: _productView == .grid
          ? SizedBox()
          : FloatingActionButton(
        onPressed: () {
          // TODO : redirect to ProductFormScreen for creating a new product.
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProductFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
