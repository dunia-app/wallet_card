/// Response returned from native platform
class WalletCardPluginResponse {
  final String methodName;
  final bool status;
  final Map<dynamic, dynamic>? message;

  WalletCardPluginResponse.fromMap(Map<dynamic, dynamic> response)
      : methodName = response['methodName'],
        status = response['status'],
        message = response['message'];

  @override
  String toString() {
    return 'Method: $methodName, status: $status, message: $message';
  }
}
