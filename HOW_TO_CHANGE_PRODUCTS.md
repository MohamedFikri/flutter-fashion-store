# How to change product details and photos

## Change product details
Open:
`lib/services/product_service.dart`

Edit these fields for each product:
- `name`
- `description`
- `price`
- `originalPrice`
- `category`
- `sizes`
- `colors`
- `stock`

## Change product photos
Put your new images inside:
`assets/images/products/`

Then update the `images` list in `lib/services/product_service.dart`.

Example:
```dart
images: [
  'assets/images/products/my_product_1.png',
  'assets/images/products/my_product_2.png',
  'assets/images/products/my_product_3.png',
],
```

## Important
After changing images, run:
```bash
flutter pub get
```
Then run the app again.

## What was updated
- Product details were replaced with assignment-friendly sample data.
- Product photos were changed from online URLs to local asset images.
- Product pages, cart pages, and product list now support local asset images.
