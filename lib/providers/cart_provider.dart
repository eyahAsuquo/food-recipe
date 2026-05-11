import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:food_recipe/model/cart_item_model.dart';
import 'package:food_recipe/model/products_model.dart';

class CartProvider extends ChangeNotifier {
  static const String _boxName = 'cart_box';
  late Box<CartItem> _cartBox;

  List<CartItem> get cartItems => _cartBox.values.toList();

  int get itemCount => cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount =>
      cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

  Future<void> init() async {
    _cartBox = await Hive.openBox<CartItem>(_boxName);
    notifyListeners();
  }

  bool isInCart(int productId) {
    return cartItems.any((item) => item.productId == productId);
  }

  CartItem? getCartItem(int productId) {
    try {
      return cartItems.firstWhere((item) => item.productId == productId);
    } catch (_) {
      return null;
    }
  }

  Future<void> addToCart(Product product) async {
    final existing = getCartItem(product.id);
    if (existing != null) {
      existing.quantity += 1;
      await existing.save();
    } else {
      final cartItem = CartItem(
        productId: product.id,
        title: product.title,
        price: product.price,
        thumbnail: product.thumbnail,
        quantity: 1,
        category: product.category,
      );
      await _cartBox.add(cartItem);
    }
    notifyListeners();
  }

  Future<void> removeFromCart(int productId) async {
    final existing = getCartItem(productId);
    if (existing != null) {
      await existing.delete();
      notifyListeners();
    }
  }

  Future<void> incrementQuantity(int productId) async {
    final existing = getCartItem(productId);
    if (existing != null) {
      existing.quantity += 1;
      await existing.save();
      notifyListeners();
    }
  }

  Future<void> decrementQuantity(int productId) async {
    final existing = getCartItem(productId);
    if (existing != null) {
      if (existing.quantity <= 1) {
        await existing.delete();
      } else {
        existing.quantity -= 1;
        await existing.save();
      }
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    await _cartBox.clear();
    notifyListeners();
  }
}
