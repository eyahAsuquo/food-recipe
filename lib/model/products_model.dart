class ProductsModel {
  final int total;
  final int skip;
  final int limit;
  final List<Product> product;

  ProductsModel({
    required this.total,
    required this.skip,
    required this.limit,
    required this.product,
  });

  factory ProductsModel.fromJson(Map<String, dynamic> json) {
    return ProductsModel(
      total: json["total"],
      skip: json["skip"],
      limit: json["limit"],
      product: (json["products"] as List)
          .map((e) => Product.fromJson(e))
          .toList(),
    );
  }
}

class Product {
  final int id;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final int weight;
  final List<String> tags;
  final String title;
  final String description;
  final String category;
  final Dimensions dimensions;
  final String warrantyInfo;
  final String shippingInfo;
  final String availabilityStatus;
  final List<Reviews> reviews;
  final String returnPolicy;
  final List<String> images;
  final String thumbnail;

  Product({
    required this.id,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.availabilityStatus,
    required this.category,
    required this.description,
    required this.dimensions,
    required this.images,
    required this.returnPolicy,
    required this.reviews,
    required this.shippingInfo,
    required this.stock,
    required this.tags,
    required this.thumbnail,
    required this.title,
    required this.warrantyInfo,
    required this.weight,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json["id"] as int,
      price: (json["price"] as num).toDouble(),
      discountPercentage: (json["discountPercentage"] as num).toDouble(),
      rating: (json["rating"] as num).toDouble(),
      availabilityStatus: json["availabilityStatus"] ?? " ",
      category: json["category"] ?? " ",
      description: json["description"] ?? " ",
      dimensions: Dimensions.fromJson(
        json["dimensions"] as Map<String, dynamic>,
      ),
      images: List<String>.from(json["images"] ?? []),
      returnPolicy: json["returnPolicy"] ?? " ",
      // reviews:
      //     (json["review"] as List?)?.map((e) => Reviews.fromJson(e)).toList() ??
      //     [],
      reviews:
          (json['reviews'] as List<dynamic>?)
              ?.map((x) => Reviews.fromJson(x))
              .toList() ??
          [],
      shippingInfo: json["shippingInformation"] ?? " ",
      stock: json["stock"] as int,
      tags: List<String>.from(json["tags"] ?? []),
      thumbnail: json["thumbnail"] as String,
      title: json["title"] as String,
      warrantyInfo: json["warrantyInformation"] ?? " ",
      weight: json["weight"] as int,
    );
  }
}

class Dimensions {
  final double width;
  final double height;
  final double depth;

  Dimensions({required this.width, required this.height, required this.depth});

  factory Dimensions.fromJson(Map<String, dynamic> json) => Dimensions(
    width: (json["width"] as num).toDouble(),
    height: (json["height"] as num).toDouble(),
    depth: (json["depth"] as num).toDouble(),
  );
}

class Reviews {
  final int rating;
  final String comment;
  final String date;
  final String name;

  Reviews({
    required this.rating,
    required this.comment,
    required this.date,
    required this.name,
  });

  factory Reviews.fromJson(Map<String, dynamic> json) => Reviews(
    rating: json["rating"],
    comment: json["comment"],
    date: json["date"],
    name: json["reviewerName"],
  );
}
