import 'package:flutter/foundation.dart';
import 'package:food_recipe/model/products_model.dart';
import 'package:food_recipe/services/product_service.dart';

enum ProductStatus { idle, loading, success, error }

class ProductProvider extends ChangeNotifier {
  ProductStatus _status = ProductStatus.idle;
  List<Product> _products = [];
  List<Product> _filtered = [];
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _errorMessage = '';

  ProductStatus get status => _status;
  List<Product> get products => _filtered;
  List<Product> get allProducts => _products;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  String get errorMessage => _errorMessage;

  List<String> get categories {
    final cats = _products.map((p) => p.category).toSet().toList();
    cats.sort();
    return ['All', ...cats];
  }

  Future<void> fetchProducts() async {
    _status = ProductStatus.loading;
    notifyListeners();
    try {
      final result = await ProductService().fetchProduct();
      _products = result.product;
      _applyFilters();
      _status = ProductStatus.success;
    } catch (e) {
      _errorMessage = e.toString();
      _status = ProductStatus.error;
    }
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filtered = _products.where((p) {
      final matchesSearch =
          p.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.category.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _selectedCategory == 'All' || p.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }
}
