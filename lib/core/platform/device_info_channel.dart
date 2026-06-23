import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';

class DeviceInfoChannel {
  static const MethodChannel _channel = MethodChannel(
    'com.mindlog.device_info',
  );

  static Future<String> getDeviceName() async {
    if (kIsWeb) return 'Navegador Web';

    try {
      final String? deviceName = await _channel.invokeMethod('getDeviceName');
      return deviceName ?? 'Dispositivo desconocido';
    } on PlatformException catch (_) {
      return 'Dispositivo no disponible';
    } on MissingPluginException catch (_) {
      return 'Canal no configurado';
    }
  }

  static Future<String> getOsVersion() async {
    if (kIsWeb) return 'Web';

    try {
      final String? version = await _channel.invokeMethod('getOsVersion');
      return version ?? 'Desconocida';
    } on PlatformException catch (_) {
      return 'No disponible';
    } on MissingPluginException catch (_) {
      return 'No configurado';
    }
  }
}
