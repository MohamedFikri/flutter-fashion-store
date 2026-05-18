import 'package:cloud_firestore/cloud_firestore.dart';

// ─── Product Model ───────────────────────────────────────────
class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final String category;
  final List<String> images;
  final List<String> sizes;
  final List<String> colors;
  final double rating;
  final int reviewCount;
  final bool isFeatured;
  final int stock;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.category,
    required this.images,
    required this.sizes,
    required this.colors,
    this.rating = 4.0,
    this.reviewCount = 0,
    this.isFeatured = false,
    this.stock = 10,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map, String docId) {
    // Handle various image field name variations (images, imageUrl, photos, productImage, image_url, etc)
    List<String> imageList = [];
    if (map['images'] != null) {
      if (map['images'] is List) {
        imageList = List<String>.from(map['images']);
      } else {
        imageList = [map['images'].toString()];
      }
    } else if (map['imageUrl'] != null) {
      imageList = [map['imageUrl'].toString()];
    } else if (map['photos'] != null) {
      if (map['photos'] is List) {
        imageList = List<String>.from(map['photos']);
      } else {
        imageList = [map['photos'].toString()];
      }
    } else if (map['image'] != null) {
      imageList = [map['image'].toString()];
    } else if (map['image_url'] != null) {
      imageList = [map['image_url'].toString()];
    } else if (map['productImage'] != null) {
      imageList = [map['productImage'].toString()];
    } else if (map['photo'] != null) {
      imageList = [map['photo'].toString()];
    }

    return ProductModel(
      id: docId,
      name: map['name'] ?? map['productName'] ?? 'No Name',
      description: map['description'] ?? 'No Description',
      price: (map['price'] ?? 0).toDouble(),
      originalPrice: (map['originalPrice'] ?? map['oldPrice'])?.toDouble(),
      category: map['category'] ?? 'General',
      images: imageList.isNotEmpty ? imageList : ['assets/images/logo.png'],
      sizes: List<String>.from(map['sizes'] ?? []),
      colors: List<String>.from(map['colors'] ?? []),
      rating: (map['rating'] ?? 4.0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      isFeatured: map['isFeatured'] ?? false,
      stock: map['stock'] ?? 10,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'description': description,
        'price': price,
        'originalPrice': originalPrice,
        'category': category,
        'images': images,
        'sizes': sizes,
        'colors': colors,
        'rating': rating,
        'reviewCount': reviewCount,
        'isFeatured': isFeatured,
        'stock': stock,
      };

  double get discountPercent {
    if (originalPrice == null || originalPrice! <= price) return 0;
    return ((originalPrice! - price) / originalPrice! * 100).roundToDouble();
  }
}

// ─── Cart Item Model ──────────────────────────────────────────
class CartItemModel {
  final String id;
  final ProductModel product;
  int quantity;
  final String selectedSize;
  final String selectedColor;

  CartItemModel({
    required this.id,
    required this.product,
    required this.quantity,
    required this.selectedSize,
    required this.selectedColor,
  });

  double get totalPrice => product.price * quantity;

  Map<String, dynamic> toMap() => {
        'id': id,
        'productId': product.id,
        'productName': product.name,
        'productImage': product.images.isNotEmpty ? product.images[0] : '',
        'price': product.price,
        'quantity': quantity,
        'selectedSize': selectedSize,
        'selectedColor': selectedColor,
      };
}

// ─── Order Model ──────────────────────────────────────────────
class OrderModel {
  final String id;
  final String userId;
  final List<OrderItemModel> items;
  final double subtotal;
  final double shippingFee;
  final double total;
  final String status;
  final DeliveryDetails deliveryDetails;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.shippingFee,
    required this.total,
    required this.status,
    required this.deliveryDetails,
    required this.createdAt,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String docId) {
    // Check if delivery details are at root or in a nested object
    final deliveryDetailsMap = map['deliveryDetails'] as Map<String, dynamic>? ?? {
      'fullName': map['fullName'] ?? map['customerName'] ?? '',
      'phone': map['phone'] ?? '',
      'address': map['address'] ?? '',
      'city': map['city'] ?? '',
      'postalCode': map['postalCode'] ?? '',
      'country': map['country'] ?? '',
    };

    return OrderModel(
      id: docId,
      userId: map['userId'] ?? '',
      items: (map['items'] as List<dynamic>? ?? [])
          .map((e) => OrderItemModel.fromMap(e as Map<String, dynamic>))
          .toList(),
      subtotal: (map['subtotal'] ?? map['totalAmount'] ?? 0).toDouble(),
      shippingFee: (map['shippingFee'] ?? 0).toDouble(),
      total: (map['total'] ?? map['totalAmount'] ?? 0).toDouble(),
      status: map['status'] ?? map['orderStatus'] ?? 'Pending',
      deliveryDetails: DeliveryDetails.fromMap(deliveryDetailsMap),
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is Timestamp 
              ? (map['createdAt'] as Timestamp).toDate() 
              : DateTime.parse(map['createdAt'].toString()))
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'items': items.map((e) => e.toMap()).toList(),
        'subtotal': subtotal,
        'shippingFee': shippingFee,
        'total': total,
        'status': status,
        'deliveryDetails': deliveryDetails.toMap(),
        'createdAt': createdAt,
      };
}

class OrderItemModel {
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;
  final String selectedSize;
  final String selectedColor;

  OrderItemModel({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    required this.selectedSize,
    required this.selectedColor,
  });

  factory OrderItemModel.fromMap(Map<String, dynamic> map) => OrderItemModel(
        productId: map['productId'] ?? map['id'] ?? '',
        productName: map['productName'] ?? map['name'] ?? 'Unknown Product',
        productImage: map['productImage'] ?? map['imageUrl'] ?? map['image'] ?? map['photo'] ?? map['imageUrl'] ?? (map['images'] != null ? (map['images'] is List ? map['images'][0] : map['images']) : 'assets/images/logo.png'),
        price: (map['price'] ?? 0).toDouble(),
        quantity: map['quantity'] ?? 1,
        selectedSize: map['selectedSize'] ?? '',
        selectedColor: map['selectedColor'] ?? '',
      );

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'productName': productName,
        'productImage': productImage,
        'price': price,
        'quantity': quantity,
        'selectedSize': selectedSize,
        'selectedColor': selectedColor,
      };
}

class DeliveryDetails {
  final String fullName;
  final String phone;
  final String address;
  final String city;
  final String postalCode;
  final String country;

  DeliveryDetails({
    required this.fullName,
    required this.phone,
    required this.address,
    required this.city,
    required this.postalCode,
    required this.country,
  });

  factory DeliveryDetails.fromMap(Map<String, dynamic> map) => DeliveryDetails(
        fullName: map['fullName'] ?? '',
        phone: map['phone'] ?? '',
        address: map['address'] ?? '',
        city: map['city'] ?? '',
        postalCode: map['postalCode'] ?? '',
        country: map['country'] ?? '',
      );

  Map<String, dynamic> toMap() => {
        'fullName': fullName,
        'phone': phone,
        'address': address,
        'city': city,
        'postalCode': postalCode,
        'country': country,
      };
}

// ─── User Model ───────────────────────────────────────────────
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String? profileImage;
  final String? address;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImage,
    this.address,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) => UserModel(
        uid: uid,
        name: map['name'] ?? map['fullName'] ?? 'No Name',
        email: map['email'] ?? '',
        phone: map['phone'] ?? '',
        profileImage: map['profileImage'] ?? map['imageUrl'],
        address: map['address'],
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'phone': phone,
        'profileImage': profileImage,
        'address': address,
      };
}

// ─── Team Member Model ────────────────────────────────────────
class TeamMember {
  final String id;
  final String name;
  final String role;
  final String department;
  final String bio;
  final String imageUrl;
  final String email;
  final String phone;
  final List<String> socialLinks;
  final int experience;
  final List<String> skills;
  final bool isFeatured;
  final DateTime joinDate;

  TeamMember({
    required this.id,
    required this.name,
    required this.role,
    required this.department,
    required this.bio,
    required this.imageUrl,
    required this.email,
    required this.phone,
    required this.socialLinks,
    required this.experience,
    required this.skills,
    this.isFeatured = false,
    required this.joinDate,
  });

  factory TeamMember.fromMap(Map<String, dynamic> map, String id) => TeamMember(
        id: id,
        name: map['name'] ?? '',
        role: map['role'] ?? '',
        department: map['department'] ?? '',
        bio: map['bio'] ?? '',
        imageUrl: map['imageUrl'] ?? '',
        email: map['email'] ?? '',
        phone: map['phone'] ?? '',
        socialLinks: List<String>.from(map['socialLinks'] ?? []),
        experience: map['experience'] ?? 0,
        skills: List<String>.from(map['skills'] ?? []),
        isFeatured: map['isFeatured'] ?? false,
        joinDate: DateTime.parse(map['joinDate'] ?? DateTime.now().toIso8601String()),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'role': role,
        'department': department,
        'bio': bio,
        'imageUrl': imageUrl,
        'email': email,
        'phone': phone,
        'socialLinks': socialLinks,
        'experience': experience,
        'skills': skills,
        'isFeatured': isFeatured,
        'joinDate': joinDate.toIso8601String(),
      };
}
