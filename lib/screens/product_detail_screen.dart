import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../utils/app_theme.dart';
import '../widgets/widgets.dart';
import 'cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _currentImage = 0;
  String? _selectedSize;
  String? _selectedColor;
  int _quantity = 1;

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

  void _addToCart() {
    if (_selectedSize == null || _selectedColor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select size and color')),
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
      SnackBar(
        content: const Text('Added to cart!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'View Cart',
          textColor: Colors.white,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CartScreen()),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Image Gallery ─────────────────────────────────
          SliverAppBar(
            expandedHeight: 380,
            pinned: true,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)
                  ],
                ),
                child: const Icon(Icons.arrow_back_ios_rounded,
                    size: 16, color: AppColors.primary),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              CartBadge(
                count: cart.itemCount,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const CartScreen())),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  PageView.builder(
                    itemCount: p.images.length,
                    onPageChanged: (i) =>
                        setState(() => _currentImage = i),
                    itemBuilder: (_, i) => p.images[i].startsWith('http')
                        ? CachedNetworkImage(
                            imageUrl: p.images[i],
                            fit: BoxFit.cover,
                            placeholder: (_, __) =>
                                Container(color: AppColors.lightGrey),
                            errorWidget: (_, __, ___) => Container(
                              color: AppColors.lightGrey,
                              child: const Icon(Icons.image_not_supported_outlined,
                                  color: AppColors.grey, size: 40),
                            ),
                          )
                        : Image.asset(
                            p.images[i],
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColors.lightGrey,
                              child: const Icon(Icons.image_not_supported_outlined,
                                  color: AppColors.grey, size: 40),
                            ),
                          ),
                  ),
                  if (p.images.length > 1)
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          p.images.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentImage == i ? 20 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentImage == i
                                  ? AppColors.primary
                                  : Colors.white.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Product Info ──────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category + Name
                  Text(p.category.toUpperCase(),
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5)),
                  const SizedBox(height: 6),
                  Text(p.name, style: AppTextStyles.heading2),
                  const SizedBox(height: 12),

                  // Price + Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text('\$${p.price.toStringAsFixed(2)}',
                              style: AppTextStyles.price),
                          if (p.originalPrice != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              '\$${p.originalPrice!.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: AppColors.grey,
                                fontSize: 14,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
                      ),
                      Row(
                        children: [
                          RatingBarIndicator(
                            rating: p.rating,
                            itemBuilder: (_, __) => const Icon(
                                Icons.star_rounded,
                                color: AppColors.accent),
                            itemCount: 5,
                            itemSize: 18,
                          ),
                          const SizedBox(width: 6),
                          Text('(${p.reviewCount})',
                              style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Size Selection
                  const Text('Size', style: AppTextStyles.heading3),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: p.sizes
                        .map((s) => GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedSize = s),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 46,
                                height: 46,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: _selectedSize == s
                                      ? AppColors.primary
                                      : AppColors.white,
                                  border: Border.all(
                                    color: _selectedSize == s
                                        ? AppColors.primary
                                        : AppColors.lightGrey,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  s,
                                  style: TextStyle(
                                    color: _selectedSize == s
                                        ? Colors.white
                                        : AppColors.darkGrey,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),

                  const SizedBox(height: 20),

                  // Color Selection
                  const Text('Color', style: AppTextStyles.heading3),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: p.colors
                        .map((c) => GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedColor = c),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: _selectedColor == c
                                      ? AppColors.primary
                                      : AppColors.white,
                                  border: Border.all(
                                    color: _selectedColor == c
                                        ? AppColors.primary
                                        : AppColors.lightGrey,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  c,
                                  style: TextStyle(
                                    color: _selectedColor == c
                                        ? Colors.white
                                        : AppColors.darkGrey,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),

                  const SizedBox(height: 20),

                  // Quantity
                  Row(
                    children: [
                      const Text('Quantity', style: AppTextStyles.heading3),
                      const Spacer(),
                      _QuantityControl(
                        quantity: _quantity,
                        onDecrement: () {
                          if (_quantity > 1) {
                            setState(() => _quantity--);
                          }
                        },
                        onIncrement: () => setState(() => _quantity++),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Description
                  const Text('Description', style: AppTextStyles.heading3),
                  const SizedBox(height: 8),
                  Text(p.description, style: AppTextStyles.body),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.lightGrey),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.favorite_border_rounded,
                  color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton(
                text: 'Add to Cart',
                onPressed: _addToCart,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityControl extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _QuantityControl({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _btn(Icons.remove, onDecrement),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '$quantity',
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        _btn(Icons.add, onIncrement),
      ],
    );
  }

  Widget _btn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.lightGrey,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
      );
}
