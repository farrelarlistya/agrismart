/// Price formatting utility functions.
String formatPrice(double price) {
  if (price >= 1000000) {
    return 'Rp ${(price / 1000000).toStringAsFixed(1)} jt';
  }
  if (price >= 1000) {
    final int thousands = (price / 1000).floor();
    return 'Rp $thousands.${(price % 1000).toStringAsFixed(0).padLeft(3, '0')}';
  }
  return 'Rp ${price.toStringAsFixed(0)}';
}
