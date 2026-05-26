import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flow_desk/core/router/app_router.dart';
import 'package:flow_desk/core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait orientation
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style for a seamless dark look
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: FlowDeskColors.surfaceDark,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    // ProviderScope at the root — all Riverpod providers available app-wide
    const ProviderScope(child: FlowDeskApp()),
  );
}

class FlowDeskApp extends ConsumerWidget {
  const FlowDeskApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'FlowDesk',
      debugShowCheckedModeBanner: false,
      theme: FlowDeskTheme.darkTheme,
      // Use Material 3 — set in ThemeData.useMaterial3 = true
      routerConfig: router,
    );
  }
}
