import 'package:intl/intl.dart';

/// Formatting utilities for amounts, wallet addresses, and dates.
class Formatters {
  Formatters._();

  /// Formats a USDC amount with 2 decimal places.
  ///
  /// Example: `1250.5` → `"1,250.50"`
  static String usdcAmount(double amount) {
    final formatter = NumberFormat('#,##0.00');
    return formatter.format(amount);
  }
  /// Formats a SOL amount with up to 4 decimal places.
  ///
  /// Example: `2.4531` → `"2.4531"`
  static String solAmount(double amount) {
    final formatter = NumberFormat('#,##0.####');
    return formatter.format(amount);
  }

  /// Truncates a Solana wallet address for display.
  ///
  /// Example: `"AbC4defg...XzRr9R"` (first 4 + ... + last 4)
  static String truncateAddress(String address, {int prefixLen = 4, int suffixLen = 4}) {
    if (address.length <= prefixLen + suffixLen + 3) return address;
    return '${address.substring(0, prefixLen)}...${address.substring(address.length - suffixLen)}';
  }

  /// Formats a relative timestamp like "2 min ago", "Yesterday 3:41 PM".
  static String relativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return '$m min${m == 1 ? '' : 's'} ago';
    }
    if (diff.inHours < 24) {
      final h = diff.inHours;
      return '$h hour${h == 1 ? '' : 's'} ago';
    }

    final timeFormat = DateFormat('h:mm a');

    if (diff.inDays == 1) {
      return 'Yesterday ${timeFormat.format(dateTime)}';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    }

    return DateFormat('MMM d, yyyy').format(dateTime);
  }

  /// Formats a full date-time for transaction details.
  ///
  /// Example: `"Sep 19, 2026 at 10:30 AM"`
  static String fullDateTime(DateTime dateTime) {
    return DateFormat("MMM d, yyyy 'at' h:mm a").format(dateTime);
  }

  /// Formats an INR amount.
  ///
  /// Example: `10437.5` → `"₹10,437.50"`
  static String inrAmount(double amount) {
    final formatter = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
    return formatter.format(amount);
  }

  /// Formats network fee in SOL.
  ///
  /// Example: `0.000005` → `"~0.000005 SOL"`
  static String networkFee(double feeSol) {
    return '~${feeSol.toStringAsFixed(6)} SOL';
  }
}
