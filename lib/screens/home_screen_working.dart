import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/models.dart';

class HomeScreenWorking extends StatefulWidget {
  const HomeScreenWorking({super.key});

  @override
  State<HomeScreenWorking> createState() => _HomeScreenWorkingState();
}

class _HomeScreenWorkingState extends State<HomeScreenWorking> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ModaFusion'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<List<ProductModel>>(
        future: FirebaseService.getFeaturedProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products found'));
          }
          final products = snapshot.data!;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(products[index].name),
                subtitle: Text('\$${products[index].price}'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Navigate to product detail
                },
              );
            },
          );
        },
      ),
    );
  }
}
