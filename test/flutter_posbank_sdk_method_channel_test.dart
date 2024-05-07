import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_posbank_sdk/src/flutter_posbank_sdk_method_channel.dart';

void main() {
  MethodChannelFlutterPosbankSdk platform = MethodChannelFlutterPosbankSdk();
  const MethodChannel channel = MethodChannel('flutter_posbank_sdk');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  // test('getPlatformVersion', () async {
  //   expect(await platform.getPlatformVersion(), '42');
  // });
}
