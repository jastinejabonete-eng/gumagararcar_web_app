import 'package:flutter/material.dart';
import 'screens/store_shell.dart';
import 'state/store_controller.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GumagararcarApp());
}

class GumagararcarApp extends StatefulWidget {
  const GumagararcarApp({super.key, this.controller});
  final StoreController? controller;
  @override
  State<GumagararcarApp> createState() => _GumagararcarAppState();
}

class _GumagararcarAppState extends State<GumagararcarApp> {
  late final StoreController store;
  @override
  void initState() {
    super.initState();
    store = widget.controller ?? StoreController();
    if (!store.isLoaded) store.initialize();
  }

  @override
  void dispose() {
    if (widget.controller == null) store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) => MaterialApp(
      title: 'Gumagararcar',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme(Brightness.light),
      darkTheme: AppTheme.theme(Brightness.dark),
      themeMode: store.themeMode,
      home: store.isLoaded
          ? StoreShell(store: store)
          : const Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  semanticsLabel: 'Loading your garage',
                ),
              ),
            ),
    ),
  );
}
