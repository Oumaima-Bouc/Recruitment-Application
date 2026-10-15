import 'dart:async';
import 'package:app_links/app_links.dart';

// Small compatibility wrapper that exposes uni_links-like API using app_links.
class DeepLinks {
  static final StreamController<Uri?> _controller = StreamController<Uri?>.broadcast();
  static Stream<Uri?> get uriLinkStream => _controller.stream;
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // Register AppLinks with a callback that forwards into our stream.
    try {
      final appLinks = AppLinks();
      appLinks.uriLinkStream.listen((uri) {
        _controller.add(uri);
      });
      
      // Get initial link
      appLinks.getInitialLink().then((uri) {
        if (uri != null) _controller.add(uri);
      });
    } catch (_) {
      // ignore initialization errors
    }


  }

  static void dispose() {
    _controller.close();
  }
}
