/// Base exception hierarchy for Settl.
///
/// All service-level errors should throw one of these typed exceptions
/// so that the UI can handle them via Riverpod's `AsyncValue.error`.
sealed class AppException implements Exception {
  const AppException(this.message, {this.cause});

  /// Human-readable error message.
  final String message;

  /// The underlying error, if any.
  final Object? cause;

  @override
  String toString() => '$runtimeType: $message';
}

/// Thrown when a network request fails (timeout, DNS, connectivity).
class NetworkException extends AppException {
  const NetworkException(super.message, {super.cause});
}

/// Thrown when the Solana RPC returns an error response.
class RpcException extends AppException {
  const RpcException(super.message, {this.code, super.cause});

  /// Solana RPC error code, if available.
  final int? code;
}

/// Thrown when a blockchain transaction fails.
class TransactionException extends AppException {
  const TransactionException(super.message, {super.cause});
}

/// Thrown when the user has insufficient balance.
class InsufficientBalanceException extends AppException {
  const InsufficientBalanceException(super.message, {super.cause});
}

/// Thrown when local storage (Hive, SQLite, SecureStorage) fails.
class StorageException extends AppException {
  const StorageException(super.message, {super.cause});
}

/// Thrown when a QR code cannot be parsed or is invalid.
class QrParseException extends AppException {
  const QrParseException(super.message, {super.cause});
}

/// Thrown when wallet setup or key operations fail.
class WalletException extends AppException {
  const WalletException(super.message, {super.cause});
}
