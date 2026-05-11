import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:food_recipe/model/products_model.dart';
import 'package:food_recipe/providers/product_provider.dart';
import 'package:food_recipe/providers/cart_provider.dart';
import 'package:food_recipe/providers/wishlist_provider.dart';
import 'package:food_recipe/screens/cart.dart';
import 'package:food_recipe/screens/product_details.dart';
import 'package:food_recipe/screens/wishlist.dart';
import 'package:food_recipe/screens/category.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController searchCtrl = TextEditingController();
  final OutlineInputBorder border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(15),
    borderSide: BorderSide(width: 1, color: const Color(0x75424242)),
  );

  final Map<String, List<String>> categoryGroups = {
    'Electronics': ['smartphones', 'laptops', 'tablets', 'mobile-accessories'],
    'Men': ['mens-shirts', 'mens-shoes', 'mens-watches'],
    'Women': [
      'womens-bags',
      'womens-dresses',
      'womens-jewellery',
      'womens-shoes',
      'womens-watches',
    ],
    'Beauty': ['beauty', 'fragrances', 'skincare'],
    'Home': ['furniture', 'home-decoration', 'kitchen-accessories'],
    'Sports': ['sports-accessories', 'motorcycle', 'vehicle'],
    'Groceries': ['groceries'],
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final cart = context.watch<CartProvider>();
    final wishlist = context.watch<WishlistProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFF6C63FF)),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'ShopEase',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF6C63FF),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF6C63FF)),
            onPressed: () {
              // TODO: Implement search delegate or expand search
            },
          ),
          IconButton(
            icon: Badge(
              label: Text('${wishlist.wishlistIds.length}'),
              child: const Icon(Icons.favorite_border),
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WishlistPage()),
            ),
          ),
          IconButton(
            icon: Badge(
              label: Text('${cart.itemCount}'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartPage()),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF6C63FF)),
              child: Text(
                'Categories',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...productProvider.categories.map(
              (category) => ListTile(
                title: Text(category),
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CategoryScreen(category: category),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: productProvider.status == ProductStatus.loading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : productProvider.status == ProductStatus.error
          ? Center(
              child: Column(
                children: [
                  Text("Error ${productProvider.errorMessage}"),
                  TextButton(
                    onPressed: () => productProvider.fetchProducts(),
                    child: const Text("Reload"),
                  ),
                ],
              ),
            )
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Find best products\nfor you",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: searchCtrl,
                          onChanged: productProvider.search,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Color(0x75424242),
                            ),
                            labelText: "Search products",
                            labelStyle: const TextStyle(
                              color: Color(0x75424242),
                            ),
                            focusedBorder: border,
                            enabledBorder: border,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Category chips
                        SizedBox(
                          height: 40,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: productProvider.categories.length,
                            itemBuilder: (context, index) {
                              final category =
                                  productProvider.categories[index];
                              final isSelected =
                                  category == productProvider.selectedCategory;
                              return GestureDetector(
                                onTap: () =>
                                    productProvider.selectCategory(category),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF6C63FF)
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    category,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Trending section
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Trending',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: productProvider.allProducts.length,
                      itemBuilder: (context, index) {
                        final product = productProvider.allProducts[index];
                        return _ProductCard(
                          product: product,
                          cart: cart,
                          wishlist: wishlist,
                        );
                      },
                    ),
                  ),
                ),
                // Category sections
                ...categoryGroups.entries.map((entry) {
                  final groupName = entry.key;
                  final groupCategories = entry.value;
                  final groupProducts = productProvider.allProducts
                      .where(
                        (p) =>
                            groupCategories.contains(p.category.toLowerCase()),
                      )
                      .toList();
                  if (groupProducts.isEmpty) {
                    return const SliverToBoxAdapter(child: SizedBox());
                  }
                  return SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Text(
                            groupName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: groupProducts.length,
                            itemBuilder: (context, index) {
                              final product = groupProducts[index];
                              return _ProductCard(
                                product: product,
                                cart: cart,
                                wishlist: wishlist,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final CartProvider cart;
  final WishlistProvider wishlist;

  const _ProductCard({
    required this.product,
    required this.cart,
    required this.wishlist,
  });

  @override
  Widget build(BuildContext context) {
    final inCart = cart.isInCart(product.id);
    final inWishlist = wishlist.isWishlisted(product.id);
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductDetailsPage(product: product)),
      ),
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: product.thumbnail,
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () => wishlist.toggleWishlist(product.id),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        inWishlist ? Icons.favorite : Icons.favorite_border,
                        size: 14,
                        color: inWishlist ? Colors.red : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6C63FF),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        cart.addToCart(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.title} added to cart'),
                            backgroundColor: const Color(0xFF6C63FF),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: inCart
                            ? Colors.green
                            : const Color(0xFF6C63FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: Text(
                        inCart ? '✓' : '+',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
