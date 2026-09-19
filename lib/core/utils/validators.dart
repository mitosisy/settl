/// Input validation utilities for ChainPay.
class Validators {
  Validators._();

  /// Validates a Solana wallet address.
  ///
  /// Solana addresses are Base58-encoded and 32–44 characters long.
  static bool isValidSolanaAddress(String address) {
    if (address.isEmpty) return false;
    if (address.length < 32 || address.length > 44) return false;

    // Base58 alphabet: no 0, O, I, l
    final base58Regex = RegExp(r'^[1-9A-HJ-NP-Za-km-z]+$');
    return base58Regex.hasMatch(address);
  }

  /// Validates a USDC amount.
  ///
  /// Must be positive and have at most 2 decimal places.
  static bool isValidAmount(String amountStr) {
    final amount = double.tryParse(amountStr);
    if (amount == null || amount <= 0) return false;

    // Check decimal places (max 2 for USDC display)
    final parts = amountStr.split('.');
    if (parts.length == 2 && parts[1].length > 6) return false;

    return true;
  }

  /// Validates a single BIP39 mnemonic word (basic check).
  static bool isValidMnemonicWord(String word) {
    return word.isNotEmpty && RegExp(r'^[a-z]+$').hasMatch(word);
  }

  /// Validates a complete 12-word mnemonic phrase.
  static bool isValidMnemonic(String phrase) {
    final words = phrase.trim().split(RegExp(r'\s+'));
    if (words.length != 12) return false;
    return words.every(isValidMnemonicWord);
  }

  /// Validates a Solana Pay URI.
  ///
  /// Basic check: must start with `solana:` and contain a valid address.
  static bool isValidSolanaPayUri(String uri) {
    if (!uri.startsWith('solana:')) return false;
    final addressPart = uri.substring(7).split('?').first;
    return isValidSolanaAddress(addressPart);
  }
}
