import 'dart:async';

import 'package:flutter/services.dart';
import 'package:wallet_card/wallet_card_plugin_response.dart';

export 'widgets/add_to_wallet_button.dart';

class WalletCard {
  static const MethodChannel _channel = MethodChannel('wallet_card');

  static final WalletCard _instance = WalletCard._internal();

  /// Associate each rendered Widget to its `onPressed` event handler
  static final Map<String, FutureOr<dynamic> Function(MethodCall)> _handlers =
      {};

  factory WalletCard() {
    return _instance;
  }

  WalletCard._internal() {
    _initMethodCallHandler();
  }

  void _initMethodCallHandler() => _channel.setMethodCallHandler(_handleCalls);

  Future<dynamic> _handleCalls(MethodCall call) async {
    var handler = _handlers[call.arguments['key']];
    return handler != null ? await handler(call) : null;
  }

  Future<void> addHandler<T>(
    String key,
    FutureOr<T>? Function(MethodCall) handler,
  ) async {
    _handlers[key] = handler;
  }

  void removeHandler(String key) {
    _handlers.remove(key);
  }

  Future<bool> canAddPass(String accountIdentifier) async {
    final method = await _channel.invokeMethod('canAddPass', accountIdentifier);
    final response = WalletCardPluginResponse.fromMap(method);
    return response.status;
  }

  Future<WalletCardPluginResponse> saveAndroidPass(
      String holderName, String suffix, String pass) async {
    final method = await _channel.invokeMethod('savePass', <String, String>{
      'holderName': holderName,
      'suffix': suffix,
      'pass': pass,
    });
    final response = WalletCardPluginResponse.fromMap(method);
    return response;
  }
}
