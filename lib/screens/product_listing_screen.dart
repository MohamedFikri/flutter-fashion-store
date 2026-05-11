import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/product_service.dart';
import '../models/models.dart';
import '../utils/app_theme.dart';
import '../widgets/widgets.dart';
import 'product_detail_screen.dart';

class ProductListingScreen extends StatefulWidget {
  final String category;
  final String searchQuery;

  const ProductListingScreen({
    super.key,
    required this.category,
    required this.searchQuery,
  });

  @override
  State<ProductListingScreen> createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  final ProductService _service = ProductService();
  bool _isGridView = true;
  String _sortBy = 'Default';

  final _sortOptions = [
    'Default',
    'Price: Low to High',
    'Price: High to Low',
    'Rating'
  ];

  List<ProductModel> _sort(List<ProductModel> list) {
    switch (_sortBy) {
      case 'Price: Low to High':
        return [...list]..sort((a, b) => a.price.compareTo(b.price));
      case 'Price: High to Low':
        return [...list]..sort((a, b) => b.price.compareTo(a.price));
      case 'Rating':
        return [...list]..sort((a, b) => b.rating.compareTo(a.rating));
      default:
        return list;
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.searchQuery.isNotEmpty
        ? 'Results: "${widget.searchQuery}"'
        : widget.category.isEmpty
            ? 'All Products'
            : widget.category;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(_isGridView
                ? Icons.view_list_rounded
                : Icons.grid_view_rounded),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
        ],
      ),
      body: Column(
        children: [
          // Sort Bar
          Container(
            height: 48,
            color: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.sort, size: 18, color: AppColors.grey),
                const SizedBox(width: 8),
                const Text('Sort by:', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 8),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _sortBy,
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                        fontSize: 13),
                    items: _sortOptions
                        .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                        .toList(),
                    onChanged: (v) => setState(() => _sortBy = v!),
                  ),
                ),
              ],
            ),
          ),

          // Products
          Expanded(
            child: widget.searchQuery.isNotEmpty
                ? _buildSearchResults()
                : _buildStreamResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildStreamResults() {
    final stream = widget.category.isEmpty
        ? _service.getProducts()
        : _service.getProductsByCategory(widget.category);

    return StreamBuilder<List<ProductModel>>(
      stream: stream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final products = _sort(snap.data ?? []);
        return _buildList(products);
      },
    );
  }

  Widget _buildSearchResults() {
    return FutureBuilder<List<ProductModel>>(
      future: _service.searchProducts(widget.searchQuery),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final products = _sort(snap.data ?? []);
        return _buildList(products);
      },
    );
  }

  Widget _buildList(List<ProductModel> products) {
    if (products.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: AppColors.grey),
            SizedBox(height: 16),
            Text('No products found', style: AppTextStyles.heading3),
            SizedBox(height: 8),
            Text('Try a different search or category',
                style: AppTextStyles.bodySmall),
          ],
        ),
      );
    }

    if (_isGridView) {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.72,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        itemCount: products.length,
        itemBuilder: (_, i) => ProductCard(
          product: products[i],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ProductDetailScreen(product: products[i])),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _ListProductCard(
        product: products[i],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ProductDetailScreen(product: products[i])),
        ),
      ),
    );
  }
}

class _ListProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const _ListProductCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            // Product Image Section
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(16)),
              child: SizedBox(
                width: 120,
                height: 140,
                child: product.images.isNotEmpty
                    ? (product.images.first.startsWith('http')
                        ? CachedNetworkImage(
                            imageUrl: product.images.first,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            fadeInDuration: const Duration(milliseconds: 250),
                            memCacheWidth: 1200,
                            maxWidthDiskCache: 1200,
                            placeholder: (context, url) => Container(
                              color: AppColors.lightGrey,
                              child: const Center(
                                child: Icon(
                                  Icons.shopping_bag_outlined,
                                  color: AppColors.grey,
                                  size: 24,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.lightGrey,
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  color: AppColors.grey,
                                  size: 24,
                                ),
                              ),
                            ),
                          )
                        : Image.asset(
                            product.images.first,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            filterQuality: FilterQuality.high,
                          ))
                    : Container(
                        color: AppColors.lightGrey,
                        child: const Center(
                          child: Icon(
                            Icons.shopping_bag_outlined,
                            color: AppColors.grey,
                            size: 24,
                          ),
                        ),
                      ),
              ),
            ),
            // Product Details Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Product Name
                    Text(product.name,
                        style: AppTextStyles.heading3.copyWith(
                            fontSize: 15, fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),

                    // Category Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE94560).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(product.category,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: const Color(0xFFE94560),
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          )),
                    ),
                    const SizedBox(height: 8),

                    // Price and Rating Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Price
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (product.originalPrice != null &&
                                  product.originalPrice! > product.price)
                                Text(
                                    '\$${product.originalPrice!.toStringAsFixed(2)}',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.grey,
                                      decoration: TextDecoration.lineThrough,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                              Text('\$${product.price.toStringAsFixed(2)}',
                                  style: AppTextStyles.price.copyWith(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        // Rating
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded,
                                color: Color(0xFFE94560), size: 16),
                            const SizedBox(width: 4),
                            Text(' ${product.rating}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                )),
                          ],
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Stock Indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: product.stock > 0
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        product.stock > 0 ? 'In Stock' : 'Out of Stock',
                        style: TextStyle(
                          color: product.stock > 0 ? Colors.green : Colors.red,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
