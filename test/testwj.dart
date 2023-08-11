// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(ProviderScope(
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Myscreen(),
    );
  }
}

class Myscreen extends ConsumerWidget {
  final nameController = TextEditingController();
  final priceController = TextEditingController();

  Myscreen({Key? key}) : super(key: key);

  void showBottom(BuildContext context, List<Product> products) async {
    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            top: 20,
            right: 20,
            left: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(color: Colors.grey[100]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'name',
                  hintStyle: TextStyle(color: Colors.black),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                keyboardType: TextInputType.number,
                controller: priceController,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  hintText: 'price',
                  hintStyle: TextStyle(color: Colors.black),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  products.add(Product(
                    name: nameController.text,
                    price: double.parse(priceController.text),
                  ));
                },
                child: Text('add'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'StateProvider',
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ListTile(
                  title: Text(product.name),
                  subtitle: Text(product.price.toString()),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              showBottom(context, _products);
            },
            child: Text('add'),
          ),
        ],
      ),
    );
  }
}

// 모델 생성
class Product {
  final String name;
  final double price;
  Product({
    required this.name,
    required this.price,
  });
}

final _products = [
  Product(name: 'iphone', price: 999),
  Product(name: 'cookies', price: 2),
  Product(name: 'ps5', price: 500),
];

final productProvider = StateProvider<List<Product>>((ref) {
  return _products;
});
