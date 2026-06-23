import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  ApiConfig._();

  static const String _port = '5135';

  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:$_port/api/';
    if (Platform.isAndroid) return 'http://10.0.2.2:$_port/api/';
    return 'http://localhost:$_port/api/';
  }
}
