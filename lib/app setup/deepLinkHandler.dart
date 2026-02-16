import 'dart:async';
import 'package:app_links/app_links.dart';
import '../nav/appRouter.dart';

class DeepLinkHandler {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;

  Future<void> init() async {
    // 1️⃣ Cold start
    final Uri? initialUri = await _appLinks.getInitialLink();
    print('🔗 Initial URI: $initialUri');

    if (initialUri != null) {
      _handleUri(initialUri);
    }

    // 2️⃣ App running / background
    _sub = _appLinks.uriLinkStream.listen((Uri uri) {
      print('🔗 Stream URI: $uri');
      _handleUri(uri);
    });
  }

  void _handleUri(Uri uri) {
    print('🔗 Handling URI: $uri');

    if (uri.scheme != 'malahariyoga') {
      print('❌ Wrong scheme');
      return;
    }

    if (uri.host != 'reset-password') {
      print('❌ Wrong host');
      return;
    }

    final oobCode = uri.queryParameters['oobCode'];
    print('🔑 Extracted oobCode: $oobCode');

    if (oobCode == null || oobCode.isEmpty) return;

    // 🚀 Navigate directly using router instance
    appRouter.go('/resetPasswordConfirm?oobCode=$oobCode');
  }

  void dispose() {
    _sub?.cancel();
  }
}
