import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class WishlistProvider extends ChangeNotifier {
  static const String _boxName = 'wishlist_box';
  late Box<int> _wishlistBox;

  List<int> get wishlistIds => _wishlistBox.values.toList();

  Future<void> init() async {
    _wishlistBox = await Hive.openBox<int>(_boxName);
    notifyListeners();
  }

  bool isWishlisted(int productId) => wishlistIds.contains(productId);

  Future<void> toggleWishlist(int productId) async {
    if (isWishlisted(productId)) {
      final key = _wishlistBox.keys.firstWhere(
        (k) => _wishlistBox.get(k) == productId,
        orElse: () => null,
      );
      if (key != null) await _wishlistBox.delete(key);
    } else {
      await _wishlistBox.add(productId);
    }
    notifyListeners();
  }
}
