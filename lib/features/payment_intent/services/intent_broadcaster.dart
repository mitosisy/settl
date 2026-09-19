import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

import 'package:chain_pay/core/constants/app_constants.dart';
import 'package:chain_pay/features/payment_intent/models/payment_intent_model.dart';
import 'package:chain_pay/services/solana_service.dart';

/// Manages the offline payment queue and broadcasts signed intents
/// when connectivity is restored.
///
/// Listens to [Connectivity] stream and flushes queued intents
/// on network reconnection.
class IntentBroadcaster {
  IntentBroadcaster({
    required this.solanaService,
    Connectivity? connectivity,
  }) : _connectivity = connectivity ?? Connectivity();

  final SolanaService solanaService;
  final Connectivity _connectivity;

  Database? _db;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  /// Callback triggered when an intent is successfully broadcast.
  void Function(PaymentIntentModel intent)? onIntentBroadcast;

  /// Callback triggered when an intent fails to broadcast.
  void Function(PaymentIntentModel intent, String error)? onIntentFailed;

  // ─── Database ──────────────────────────────────────────────────

  /// Initializes the SQLite database for the offline queue.
  Future<void> init() async {
    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      p.join(dbPath, AppConstants.offlineQueueDbName),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE payment_intents (
            id TEXT PRIMARY KEY,
            recipient_address TEXT NOT NULL,
            amount_usdc REAL NOT NULL,
            memo TEXT,
            signed_tx_bytes TEXT NOT NULL,
            created_at TEXT NOT NULL,
            status TEXT NOT NULL,
            recipient_name TEXT
          )
        ''');
      },
    );
  }

  /// Starts listening for connectivity changes.
  void startListening() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (results) {
        final hasConnection = results.any(
          (r) => r != ConnectivityResult.none,
        );
        if (hasConnection) {
          _flushQueue();
        }
      },
    );
  }

  // ─── Queue operations ──────────────────────────────────────────

  /// Stores a signed intent in the SQLite queue.
  Future<void> enqueueIntent(PaymentIntentModel intent) async {
    final db = _db;
    if (db == null) throw StateError('IntentBroadcaster not initialized');

    await db.insert('payment_intents', {
      'id': intent.id,
      'recipient_address': intent.recipientAddress,
      'amount_usdc': intent.amountUsdc,
      'memo': intent.memo,
      'signed_tx_bytes': base64Encode(intent.signedTransactionBytes),
      'created_at': intent.createdAt.toIso8601String(),
      'status': intent.status.name,
      'recipient_name': intent.recipientName,
    });
  }

  /// Returns all queued (pending broadcast) intents.
  Future<List<PaymentIntentModel>> getQueuedIntents() async {
    final db = _db;
    if (db == null) return [];

    final rows = await db.query(
      'payment_intents',
      where: 'status = ?',
      whereArgs: ['queued'],
      orderBy: 'created_at DESC',
    );

    return rows.map(_rowToIntent).toList();
  }

  /// Returns all intents regardless of status.
  Future<List<PaymentIntentModel>> getAllIntents() async {
    final db = _db;
    if (db == null) return [];

    final rows = await db.query(
      'payment_intents',
      orderBy: 'created_at DESC',
    );

    return rows.map(_rowToIntent).toList();
  }

  /// Updates the status of an intent in the database.
  Future<void> updateIntentStatus(String intentId, IntentStatus status) async {
    final db = _db;
    if (db == null) return;

    await db.update(
      'payment_intents',
      {'status': status.name},
      where: 'id = ?',
      whereArgs: [intentId],
    );
  }

  // ─── Broadcasting ──────────────────────────────────────────────

  /// Flushes all queued intents by broadcasting them to Solana devnet.
  Future<void> _flushQueue() async {
    final intents = await getQueuedIntents();
    final now = DateTime.now();

    for (final intent in intents) {
      try {
        await updateIntentStatus(intent.id, IntentStatus.broadcasting);

        // Check for stale blockhash (2 minutes)
        if (now.difference(intent.createdAt).inMinutes >= 2) {
          throw Exception('Blockhash expired. Intent is older than 2 minutes.');
        }

        // Broadcast the signed transaction
        await solanaService.sendRawTransaction(intent.signedTransactionBytes);

        await updateIntentStatus(intent.id, IntentStatus.confirmed);
        onIntentBroadcast?.call(intent);
      } catch (e) {
        await updateIntentStatus(intent.id, IntentStatus.failed);
        onIntentFailed?.call(intent, e.toString());
      }
    }
  }

  /// Manually triggers a queue flush.
  Future<void> manualFlush() => _flushQueue();

  // ─── Helpers ───────────────────────────────────────────────────

  PaymentIntentModel _rowToIntent(Map<String, dynamic> row) {
    return PaymentIntentModel(
      id: row['id'] as String,
      recipientAddress: row['recipient_address'] as String,
      amountUsdc: (row['amount_usdc'] as num).toDouble(),
      memo: row['memo'] as String?,
      signedTransactionBytes: base64Decode(row['signed_tx_bytes'] as String),
      createdAt: DateTime.parse(row['created_at'] as String),
      status: IntentStatus.values.byName(row['status'] as String),
      recipientName: row['recipient_name'] as String?,
    );
  }

  /// Disposes resources.
  Future<void> dispose() async {
    await _connectivitySubscription?.cancel();
    await _db?.close();
  }
}
