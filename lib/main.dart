import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockmateapp/app.dart';
import 'package:stockmateapp/firebase_options.dart';
import 'package:stockmateapp/providers.dart';
import 'package:stockmateapp/utils/helpers/session_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await SessionService.init();

  runApp(
    MultiProvider(providers: AppProviders.providers(), child: StockMateApp()),
  );
}
