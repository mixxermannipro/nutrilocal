import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/models/models.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  static const _primaryKey = 'nutri_primary_api_key';
  static const _fallbackKey = 'nutri_fallback_api_key';
  static const _speechKey = 'nutri_speech_api_key';

  static Future<void> saveApiKeys({
    required String primaryKey,
    required String fallbackKey,
    required String speechKey,
  }) async {
    await _storage.write(key: _primaryKey, value: primaryKey);
    await _storage.write(key: _fallbackKey, value: fallbackKey);
    await _storage.write(key: _speechKey, value: speechKey);
  }

  static Future<Map<String, String>> readApiKeys() async {
    final primary = await _storage.read(key: _primaryKey) ?? '';
    final fallback = await _storage.read(key: _fallbackKey) ?? '';
    final speech = await _storage.read(key: _speechKey) ?? '';
    return {
      'primaryApiKey': primary,
      'fallbackApiKey': fallback,
      'speechApiKey': speech,
    };
  }

  static Future<void> deleteAllKeys() async {
    await _storage.deleteAll();
  }
}
