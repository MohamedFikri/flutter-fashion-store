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
        'https://images.unsplash.com/photo-1610030469983-98e550d6193c?auto=format&fit=crop&w=1200&q=90',
        'https://images.unsplash.com/photo-1583391733981-849840fd62e1?auto=format&fit=crop&w=1200&q=90',
        'https://images.unsplash.com/photo-1529139574466-a303027c1d8b?auto=format&fit=crop&w=1200&q=90',
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
        'https://images.unsplash.com/photo-1603252109303-2751441dd157?auto=format&fit=crop&w=1200&q=90',
        'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?auto=format&fit=crop&w=1200&q=90',
        'https://images.unsplash.com/photo-1621072156002-e2fccdc0b176?auto=format&fit=crop&w=1200&q=90',
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
        'https://images.unsplash.com/photo-1519238263530-99bdd11df2ea?auto=format&fit=crop&w=1200&q=90',
        'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=1200&q=90',
        'https://images.unsplash.com/photo-1512436991641-6745cdb1723f?auto=format&fit=crop&w=1200&q=90',
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
        'https://images.unsplash.com/photo-1584917865442-de89df76afd3?auto=format&fit=crop&w=1200&q=90',
        'https://images.unsplash.com/photo-1594223274512-ad4803739b7c?auto=format&fit=crop&w=1200&q=90',
        'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?auto=format&fit=crop&w=1200&q=90',
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
        'https://images.unsplash.com/photo-1542272604-787c3835535d?auto=format&fit=crop&w=1200&q=90',
        'https://images.unsplash.com/photo-1604176354204-9268737828e4?auto=format&fit=crop&w=1200&q=90',
        'https://images.unsplash.com/photo-1473966968600-fa801b869a1a?auto=format&fit=crop&w=1200&q=90',
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
        'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=1200&q=90',
        'https://images.unsplash.com/photo-1543508282-6319a3e2621f?auto=format&fit=crop&w=1200&q=90',
        'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?auto=format&fit=crop&w=1200&q=90',
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
        'https://images.unsplash.com/photo-1483985988355-763728e1935b?auto=format&fit=crop&w=1200&q=90',
        'https://images.unsplash.com/photo-1496747611176-843222e1e57c?auto=format&fit=crop&w=1200&q=90',
        'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=1200&q=90',
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
        'https://images.unsplash.com/photo-1503919545889-aef636e10ad4?auto=format&fit=crop&w=1200&q=90',
        'https://images.unsplash.com/photo-1519345182560-3f2917c472ef?auto=format&fit=crop&w=1200&q=90',
        'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=1200&q=90',
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
