import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'product_model.dart';

class ProductManager {
  final CollectionReference _productCollection = FirebaseFirestore.instance
      .collection('products');

  Future<void> addProduct(String name, double price, int stock, String? imagePath) async {
    try {
      await _productCollection.add({
        'name': name,
        'price': price,
        'stock': stock,
        'image_path': imagePath,
        'created_at': FieldValue.serverTimestamp(),
      });
      debugPrint('Product added successfully!');
    } catch (e) {
      debugPrint('Failed to add product: $e');
    }
  }

  Stream<List<ProductModel>> getProductsStream() {
    return _productCollection
        .orderBy('created_at', descending: true) // Sort by newest
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ProductModel.fromFirestore(doc))
              .toList();
        });
  }

  Future<List<ProductModel>> getProducts() async {
    try {
      final snapshot = await _productCollection.get();
      final products = snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
      return products;
    } on Exception {
      return [];
    }
  }

  Future<void> updateProduct(
    String productId,
    Map<String, dynamic> updatedData,
  ) async {
    try {
      updatedData['updated_at'] = FieldValue.serverTimestamp();
      await _productCollection.doc(productId).update(updatedData);
      debugPrint('Product updated successfully!');
    } catch (e) {
      debugPrint('Failed to update product: $e');
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _productCollection.doc(productId).delete();
      debugPrint('Product deleted successfully!');
    } catch (e) {
      debugPrint('Failed to delete product: $e');
    }
  }

  Future<List<ProductModel>> searchProducts(String keyword) async {
    if (keyword.isEmpty) {
      return [];
    }
    final items = await getProducts();
    return items
        .where((item) => item.name.toLowerCase().contains(keyword.toLowerCase()))
        .toList();
  }
}
