import 'package:flutter/material.dart';
import 'product_manager.dart';
import 'product_model.dart';
import 'product_util.dart';

class ProductSearchScreen extends StatefulWidget {
  const ProductSearchScreen({super.key});

  @override
  State<ProductSearchScreen> createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productManager = ProductManager();
  Future<List<ProductModel>>? _result;
  late TextEditingController _keywordController;

  Future<List<ProductModel>> searchProduct(String keyword) async {
    return await _productManager.searchProducts(keyword);
  }

  @override
  void initState() {
    super.initState();
    _keywordController = TextEditingController();
  }

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 1,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(Icons.keyboard_arrow_left, size: 40),
              ),
            ),
            Expanded(
              flex: 10,
              child: Form(
                key: _formKey,
                child: TextFormField(
                  controller: _keywordController,
                  autofocus: true,
                  keyboardType: TextInputType.text,
                  autocorrect: false,
                  onFieldSubmitted: (keyword) {
                    setState(() {
                      _result = searchProduct(keyword);
                    });
                  },
                  decoration: InputDecoration.collapsed(
                    hintText: 'Search',
                    fillColor: Colors.white70,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                      gapPadding: 12,
                    ),
                  ),
                ),
              ),
            ),
            Flexible(
              flex: 2,
              child: GestureDetector(
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      _result = searchProduct(_keywordController.text);
                    });
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.only(right: 12.0),
                  child: Icon(Icons.search),
                ),
              ),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
        leadingWidth: 0,
        titleSpacing: 0,
      ),
      body: FutureBuilder<List<ProductModel>>(
        future: _result,
        builder: (context, snapshot) {
          // Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: CircularProgressIndicator(color: Colors.grey.shade500),
                ),
                const SizedBox(height: 12),
                Text(
                  "Searching...",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, color: Colors.grey.shade500),
                ),
              ],
            );
          }

          // Handling Error State
          if (snapshot.hasError) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 100,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(height: 12),
                Text(
                  "Could not search products.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, color: Colors.grey.shade500),
                ),
              ],
            );
          }

          // Extract Search Result
          final searchResult = snapshot.data ?? [];
          if (_result != null && searchResult.isEmpty) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: 100,
                  color: Colors.grey.shade500,
                ),
                Text(
                  "No Results",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, color: Colors.grey.shade500),
                ),
              ],
            );
          }

          if (_result == null) {
            return const Center(
              child: Text("Enter a keyword to search"),
            );
          }

          // Display Result
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Search Results",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text("${searchResult.length} items"),
                  ],
                ),
              ),
              Expanded(child: productInGrid(searchResult)),
            ],
          );
        },
      ),
    );
  }
}
