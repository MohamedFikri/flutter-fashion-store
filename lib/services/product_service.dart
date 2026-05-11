import 'dart:async';
import '../models/models.dart';

class ProductService {
  // Local mock data for assignment demo
  static final List<ProductModel> _mockProducts = [
    ProductModel(
      id: '1',
      name: "Women's Kurti Set",
      description: 'Elegant three-piece kurti set suitable for campus events, family functions, and casual wear.',
      price: 6490.00,
      originalPrice: 7990.00,
      category: 'Women',
      images: [
        'assets/images/products/womens_kurti_set_1.jpg',
        'assets/images/products/womens_kurti_set_2.jpg',
        'assets/images/products/womens_kurti_set_3.jpg',
      ],
      sizes: ['S', 'M', 'L', 'XL'],
      colors: ['Maroon', 'Navy', 'Cream'],
      rating: 4.7,
      reviewCount: 84,
      isFeatured: true,
      stock: 12,
    ),
    ProductModel(
      id: '2',
      name: "Men's Casual Shirt",
      description: 'Soft cotton casual shirt with a smart fit for daily use, presentations, and outings.',
      price: 4290.00,
      originalPrice: 5290.00,
      category: 'Men',
      images: [
        'assets/images/products/mens_casual_shirt_1.jpg',
        'assets/images/products/mens_casual_shirt_2.jpg',
        'assets/images/products/mens_casual_shirt_3.jpg',
      ],
      sizes: ['M', 'L', 'XL', 'XXL'],
      colors: ['White', 'Sky Blue', 'Black'],
      rating: 4.5,
      reviewCount: 67,
      isFeatured: true,
      stock: 20,
    ),
    ProductModel(
      id: '3',
      name: 'Kids Party Frock',
      description: 'Comfortable and colorful frock designed for birthday parties and special occasions.',
      price: 3890.00,
      originalPrice: 4690.00,
      category: 'Kids',
      images: [
        'assets/images/products/kids_party_frock_1.jpg',
        'assets/images/products/kids_party_frock_2.jpg',
        'assets/images/products/kids_party_frock_3.jpg',
      ],
      sizes: ['2Y', '4Y', '6Y', '8Y'],
      colors: ['Pink', 'Peach', 'Lavender'],
      rating: 4.8,
      reviewCount: 43,
      isFeatured: true,
      stock: 15,
    ),
    ProductModel(
      id: '4',
      name: "Women's Handbag",
      description: 'Stylish everyday handbag with enough space for essentials, notes, and accessories.',
      price: 5590.00,
      originalPrice: 6990.00,
      category: 'Women',
      images: [
        'assets/images/products/womens_handbag_1.jpg',
        'assets/images/products/womens_handbag_2.jpg',
        'assets/images/products/womens_handbag_3.jpg',
      ],
      sizes: ['One Size'],
      colors: ['Black', 'Brown', 'Tan'],
      rating: 4.6,
      reviewCount: 59,
      isFeatured: true,
      stock: 10,
    ),
    ProductModel(
      id: '5',
      name: "Men's Denim Jeans",
      description: 'Classic slim-fit denim jeans with durable stitching for regular wear.',
      price: 4990.00,
      category: 'Men',
      images: [
        'assets/images/products/mens_denim_jeans_1.jpg',
        'assets/images/products/mens_denim_jeans_2.jpg',
        'assets/images/products/mens_denim_jeans_3.jpg',
      ],
      sizes: ['30', '32', '34', '36', '38'],
      colors: ['Blue', 'Dark Blue', 'Black'],
      rating: 4.4,
      reviewCount: 71,
      isFeatured: true,
      stock: 18,
    ),
    ProductModel(
      id: '6',
      name: 'Sports Running Shoes',
      description: 'Lightweight sports shoes for walking, running, and day-to-day comfort.',
      price: 7490.00,
      originalPrice: 8990.00,
      category: 'Men',
      images: [
        'assets/images/products/sports_shoes_1.jpg',
        'assets/images/products/sports_shoes_2.jpg',
        'assets/images/products/sports_shoes_3.jpg',
      ],
      sizes: ['40', '41', '42', '43', '44'],
      colors: ['White', 'Black', 'Gray'],
      rating: 4.7,
      reviewCount: 96,
      isFeatured: false,
      stock: 14,
    ),
    ProductModel(
      id: '7',
      name: 'Black Abaya',
      description: 'Simple and modest abaya design with a clean look for formal and everyday use.',
      price: 6990.00,
      originalPrice: 8290.00,
      category: 'Women',
      images: [
        'assets/images/products/abaya_black_1.jpg',
        'assets/images/products/abaya_black_2.jpg',
        'assets/images/products/abaya_black_3.jpg',
      ],
      sizes: ['M', 'L', 'XL'],
      colors: ['Black', 'Charcoal'],
      rating: 4.8,
      reviewCount: 52,
      isFeatured: false,
      stock: 9,
    ),
    ProductModel(
      id: '8',
      name: 'Boys Hoodie',
      description: 'Warm hoodie for kids with a relaxed fit and soft fabric for outdoor activities.',
      price: 3590.00,
      category: 'Kids',
      images: [
        'assets/images/products/boys_hoodie_1.jpg',
        'assets/images/products/boys_hoodie_2.jpg',
        'assets/images/products/boys_hoodie_3.jpg',
      ],
      sizes: ['4Y', '6Y', '8Y', '10Y'],
      colors: ['Red', 'Blue', 'Mustard'],
      rating: 4.3,
      reviewCount: 38,
      isFeatured: false,
      stock: 16,
    ),
  ];

  Stream<List<ProductModel>> getProducts() {
    return Stream.value(_mockProducts).asyncMap(
      (products) async {
        await Future.delayed(const Duration(milliseconds: 500));
        return products;
      },
    );
  }

  Stream<List<ProductModel>> getFeaturedProducts() {
    return Stream.value(_mockProducts.where((p) => p.isFeatured).toList()).asyncMap(
      (products) async {
        await Future.delayed(const Duration(milliseconds: 500));
        return products;
      },
    );
  }

  Stream<List<ProductModel>> getProductsByCategory(String category) {
    if (category == 'All') {
      return getProducts();
    }
    return Stream.value(_mockProducts.where((p) => p.category == category).toList()).asyncMap(
      (products) async {
        await Future.delayed(const Duration(milliseconds: 500));
        return products;
      },
    );
  }

  Future<ProductModel?> getProductById(String id) async {
    try {
      return _mockProducts.firstWhere((product) => product.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (query.isEmpty) return _mockProducts;

    return _mockProducts.where((product) {
      final q = query.toLowerCase();
      return product.name.toLowerCase().contains(q) ||
          product.description.toLowerCase().contains(q) ||
          product.category.toLowerCase().contains(q);
    }).toList();
  }
}
