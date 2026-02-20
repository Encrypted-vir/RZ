//lib/main.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'models/capsule_item.dart';
import 'providers/capsule_provider.dart';
import 'data/repositories/capsule_repository.dart';
import 'router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(CapsuleItemAdapter());
  await Hive.openBox<CapsuleItem>('capsules');

  runApp(
    ChangeNotifierProvider(
      create: (_) => CapsuleProvider(CapsuleRepository()), // 👈 inyección
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
    );
  }
}
