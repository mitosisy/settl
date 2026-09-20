import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:settl/models/identity_model.dart';

class IdentityService {
  final Map<String, String> _settlIdToPubKey = {};
  final Map<String, String> _pubKeyToSettlId = {};

  bool _isLoaded = false;

  IdentityService() {
    loadDirectory();
  }

  /// Loads the directory JSON from assets and builds O(1) lookup maps.
  Future<void> loadDirectory() async {
    if (_isLoaded) return;

    try {
      final jsonString = await rootBundle.loadString('assets/data/directory.json');
      final Map<String, dynamic> data = jsonDecode(jsonString);
      
      if (data.containsKey('identities')) {
        final List<dynamic> identities = data['identities'];
        for (final item in identities) {
          final model = IdentityModel.fromJson(item);
          _settlIdToPubKey[model.settlId.trim()] = model.pubKey.trim();
          _pubKeyToSettlId[model.pubKey.trim()] = model.settlId.trim();
        }
      }
      _isLoaded = true;
    } catch (e) {
      // In a production app, handle missing asset or parsing errors gracefully.
      debugPrint('Error loading directory: $e');
    }
  }

  /// Returns the public key for a given @settl ID.
  String? resolveSettlIdToPubKey(String settlId) {
    return _settlIdToPubKey[settlId.trim()];
  }

  String? resolvePubKeyToSettlId(String pubKey) {
    return _pubKeyToSettlId[pubKey.trim()];
  }
}
