import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'device_info_channel.dart';

final deviceNameProvider = FutureProvider<String>((ref) async {
  return await DeviceInfoChannel.getDeviceName();
});

final osVersionProvider = FutureProvider<String>((ref) async {
  return await DeviceInfoChannel.getOsVersion();
});
