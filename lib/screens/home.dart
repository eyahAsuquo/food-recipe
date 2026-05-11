import 'package:flutter/material.dart';
import 'package:food_recipe/model/products_model.dart';
import 'package:food_recipe/services/product_service.dart';

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

  late Future<ProductsModel> _futureProduct;

  @override
  void initState() {
    super.initState();

    _futureProduct = ProductService().fetchProduct();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: size.height * 0.06,
            horizontal: 30,
          ),
          child: FutureBuilder<ProductsModel>(
            future: _futureProduct,
            builder: (context, snapShot) {
              if (snapShot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator.adaptive());
              }
              if (snapShot.hasError) {
                return Center(
                  child: Column(
                    children: [
                      Text("Error ${snapShot.error.toString()}"),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _futureProduct = ProductService().fetchProduct();
                          });
                        },
                        child: Text("Reload"),
                      ),
                    ],
                  ),
                );
              }
              if (!snapShot.hasData) {
                return Center(child: Text("No data"));
              }
              final product = snapShot.data!.product;
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Find best recipes\nfor cooking",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: searchCtrl,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search, color: Color(0x75424242)),
                      labelText: "Search recipes",
                      labelStyle: TextStyle(color: Color(0x75424242)),
                      focusedBorder: border,
                      enabledBorder: border,
                    ),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: product.length,
                      itemBuilder: (context, index) {
                        final item = product[index];
                        return ListTile(
                          leading: Image.network(
                            item.thumbnail,
                            width: 50,
                            fit: BoxFit.cover,
                          ),
                          title: Text(item.title),
                          subtitle: Text(item.availabilityStatus),
                          trailing: Text("\$${item.price}"),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
