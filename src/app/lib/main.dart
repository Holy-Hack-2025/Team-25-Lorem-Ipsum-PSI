import 'package:app/app.dart';
import 'package:app/i18n/strings.g.dart';
import 'package:app/providers/saus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LocaleSettings.useDeviceLocale();

  runApp(
    TranslationProvider(
      child: MultiProvider(
        providers: [Provider(create: (_) => SausProvider())],
        child: GlobalKitchenApp(),
      ),
    ),
  );
}
