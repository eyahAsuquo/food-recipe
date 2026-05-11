import 'package:hive/hive.dart';

part 'cart_item_model.g.dart';

@HiveType(typeId: 0)
class CartItem extends HiveObject {
  @HiveField(0)
  final int productId;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double price;

  @HiveField(3)
  final String thumbnail;

  @HiveField(4)
  int quantity;

  @HiveField(5)
  final String category;

  CartItem({
    required this.productId,
    required this.title,
    required this.price,
    required this.thumbnail,
    required this.quantity,
    required this.category,
  });

  double get totalPrice => price * quantity;
}
