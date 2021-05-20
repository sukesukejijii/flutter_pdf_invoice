import 'package:intl/intl.dart';

class Utils {
  static String formatPrice(int price) {
    final jaCurrency = NumberFormat.simpleCurrency(
      locale: 'ja',
      name: '¥ ',
      decimalDigits: 0,
    );
    return jaCurrency.format(price);
  }

  static String formatDate(DateTime date) {
    return DateFormat.yMd('ja').format(date);
  }
}
