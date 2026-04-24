import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../utils/app_theme.dart';
import 'cart_screen.dart';

class ProductPage extends StatefulWidget {
  final ProductModel product;

  const ProductPage({super.key, required this.product});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  String? _selectedSize;
  String? _selectedColor;
  int _quantity = 1;
  final bool _isExpanded = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.product.sizes.isNotEmpty) {
      _selectedSize = widget.product.sizes[0];
    }
    if (widget.product.colors.isNotEmpty) {
      _selectedColor = widget.product.colors[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          widget.product.name,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildImageGallery(),
            _buildIndicator(),
            _buildProductInfo(),
            _buildSizeColorSelection(),
            _buildAddToCartSection(),
            _buildProductDetails(),
          ],
        ),
      ),
    );
  }

  // 🔥 IMAGE GALLERY
  Widget _buildImageGallery() {
    return SizedBox(
      height: 350,
      child: PageView.builder(
        itemCount: widget.product.images.length,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        itemBuilder: (context, index) {
          final image = widget.product.images[index];

          return Stack(
            children: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: image.startsWith('http')
                      ? CachedNetworkImage(
                          imageUrl: image,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          fadeInDuration: const Duration(milliseconds: 250),
                          memCacheWidth: 1400,
                          maxWidthDiskCache: 1400,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey.shade200,
                            child: const Center(child: Icon(Icons.image_not_supported_outlined)),
                          ),
                        )
                      : Image.asset(
                          image,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          filterQuality: FilterQuality.high,
                        ),
                ),
              ),

              // 🔥 Gradient overlay
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // 🔥 DOT INDICATOR
  Widget _buildIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.product.images.length,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          width: _currentIndex == index ? 12 : 8,
          height: _currentIndex == index ? 12 : 8,
          decoration: BoxDecoration(
            color: _currentIndex == index
                ? AppColors.primary
                : Colors.grey,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }

  // 🔥 PRODUCT INFO
  Widget _buildProductInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.product.name,
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(widget.product.description),
          const SizedBox(height: 10),
          Text("\$${widget.product.price}",
              style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary)),

          const SizedBox(height: 10),

          RatingBarIndicator(
            rating: widget.product.rating,
            itemBuilder: (context, _) =>
                const Icon(Icons.star, color: Colors.amber),
            itemCount: 5,
            itemSize: 20,
          ),
        ],
      ),
    );
  }

  // 🔥 SIZE + COLOR
  Widget _buildSizeColorSelection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // SIZE
          if (widget.product.sizes.isNotEmpty) ...[
            const Text("Size", style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              children: widget.product.sizes.map((size) {
                final selected = _selectedSize == size;
                return GestureDetector(
                  onTap: () => setState(() => _selectedSize = size),
                  child: Container(
                    margin: const EdgeInsets.all(5),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary
                          : Colors.white,
                      border: Border.all(color: AppColors.primary),
                    ),
                    child: Text(size,
                        style: TextStyle(
                            color: selected
                                ? Colors.white
                                : Colors.black)),
                  ),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 10),

          // COLOR
          if (widget.product.colors.isNotEmpty) ...[
            const Text("Color", style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              children: widget.product.colors.map((color) {
                final selected = _selectedColor == color;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    margin: const EdgeInsets.all(5),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary
                          : Colors.white,
                      border: Border.all(color: AppColors.primary),
                    ),
                    child: Text(color,
                        style: TextStyle(
                            color: selected
                                ? Colors.white
                                : Colors.black)),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  // 🔥 ADD TO CART
  Widget _buildAddToCartSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const Text("Qty"),
              const Spacer(),
              IconButton(
                  onPressed: () {
                    if (_quantity > 1) setState(() => _quantity--);
                  },
                  icon: const Icon(Icons.remove)),
              Text("$_quantity"),
              IconButton(
                  onPressed: () => setState(() => _quantity++),
                  icon: const Icon(Icons.add)),
            ],
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _addToCart,
              child: const Text("Add to Cart"),
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 DETAILS
  Widget _buildProductDetails() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ExpansionTile(
        title: const Text("Product Details"),
        children: [
          ListTile(title: Text("Category: ${widget.product.category}")),
          ListTile(title: Text("Stock: ${widget.product.stock}")),
          ListTile(title: Text("Rating: ${widget.product.rating}")),
        ],
      ),
    );
  }

  // 🔥 ADD TO CART FUNCTION
  void _addToCart() {
    if (_selectedSize == null || _selectedColor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select size & color")),
      );
      return;
    }

    context.read<CartProvider>().addItem(
          widget.product,
          quantity: _quantity,
          size: _selectedSize!,
          color: _selectedColor!,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Added to cart")),
    );
  }
}