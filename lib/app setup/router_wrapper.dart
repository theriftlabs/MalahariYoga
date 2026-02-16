import 'package:flutter/material.dart';
import 'deepLinkHandler.dart';

class RouterWrapper extends StatefulWidget {
  final Widget child;
  const RouterWrapper({super.key, required this.child});

  @override
  State<RouterWrapper> createState() => _RouterWrapperState();
}

class _RouterWrapperState extends State<RouterWrapper> {
  final DeepLinkHandler _deepLinkHandler = DeepLinkHandler();
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      _initialized = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _deepLinkHandler.init();
      });
    }
  }

  @override
  void dispose() {
    _deepLinkHandler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
