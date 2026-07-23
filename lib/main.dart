import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app/app.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      await initializeDateFormatting('de_DE', null);
    } catch (_) {
      // Fallback if locale data fails to load
    }
    runApp(const ProviderScope(child: NutriLocalApp()));
  }, (error, stack) {
    debugPrint('NutriLocal Caught Error: $error');
  });
}
