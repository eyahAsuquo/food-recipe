import 'dart:convert';

import 'package:food_recipe/model/products_model.dart';
import 'package:http/http.dart' as http;

class ProductService {
  final String _baseUrl = "https://dummyjson.com/products";

  Future<ProductsModel> fetchProduct() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));
      if (response.statusCode == 200) {
        final jsonList = jsonDecode(response.body);

        // print(jsonList);
        return ProductsModel.fromJson(jsonList);
      }
    } catch (e) {
      throw Exception("Error fetching Product\n${e.toString()}");
    }
    throw Exception("Error: Failed to get API Response");
  }
}
