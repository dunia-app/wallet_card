import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:wallet_card/wallet_card.dart';

class AddToWalletButton extends StatefulWidget {
  static const viewType = 'PKAddPassButton';

  final double width;
  final double height;
  final String? cardHolderName;
  final String? cardSuffix;
  final Widget? unsupportedPlatformChild;
  final void Function()? onPressed;
  final FutureOr<Map<String, String>?> Function(
    List<Object?>,
    Uint8List,
    Uint8List,
  )? loadCard;
  final String _id = const Uuid().v4();

  AddToWalletButton({
    Key? key,
    required this.width,
    required this.height,
    required this.cardHolderName,
    required this.cardSuffix,
    this.onPressed,
    this.loadCard,
    this.unsupportedPlatformChild,
  }) : super(key: key);

  @override
  State<AddToWalletButton> createState() => _AddToWalletButtonState();
}

class _AddToWalletButtonState extends State<AddToWalletButton> {
  get uiKitCreationParams => {
        'width': widget.width,
        'height': widget.height,
        'key': widget._id,
        'cardHolderName': widget.cardHolderName ?? '',
        'cardSuffix': widget.cardSuffix ?? '',
      };

  @override
  void initState() {
    super.initState();
    WalletCard().addHandler(widget._id, (call) {
      switch (call.method) {
        case "add_payment_pass":
          return getPass(call);

        default:
          return null;
      }
    });
  }

  Future<Map<String, String>?> getPass(MethodCall call) async {
    var result = await widget.loadCard?.call(
      call.arguments["certificates"] as List,
      call.arguments["nonce"] as Uint8List,
      call.arguments["nonceSignature"] as Uint8List,
    );

    return result;
  }

  @override
  void dispose() {
    WalletCard().removeHandler(widget._id);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: platformWidget(context),
    );
  }

  Widget platformWidget(BuildContext context) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return UiKitView(
          viewType: AddToWalletButton.viewType,
          layoutDirection: Directionality.of(context),
          creationParams: uiKitCreationParams,
          creationParamsCodec: const StandardMessageCodec(),
        );
      case TargetPlatform.android:
        return RawMaterialButton(
          child: Text('test'),
          onPressed: widget.onPressed,
        );
      default:
        if (widget.unsupportedPlatformChild == null) {
          throw UnsupportedError('Unsupported platform view');
        }
        return widget.unsupportedPlatformChild!;
    }
  }
}
