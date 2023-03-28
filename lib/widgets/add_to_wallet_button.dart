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
  final String? accountIdentifier;
  final Widget? unsupportedPlatformChild;
  final void Function()? onPressed;
  final FutureOr<String?> Function(
    List<Object?>,
    String,
    String,
  )? loadCard;
  final void Function(String)? addedCard;
  final String _id = const Uuid().v4();

  AddToWalletButton({
    Key? key,
    required this.width,
    required this.height,
    required this.cardHolderName,
    required this.cardSuffix,
    required this.accountIdentifier,
    this.onPressed,
    this.loadCard,
    this.addedCard,
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
        'accountIdentifier': widget.accountIdentifier ?? '',
      };

  @override
  void initState() {
    super.initState();
    WalletCard().addHandler(widget._id, (call) {
      switch (call.method) {
        case "add_payment_pass":
          return getPass(call);
        case "add_payment_pass_success":
          return passSuccess(call);
        default:
          return null;
      }
    });
  }

  Future<String?> getPass(MethodCall call) async {
    var result = await widget.loadCard?.call(
      call.arguments["certificates"] as List<Object?>,
      call.arguments["nonce"] as String,
      call.arguments["nonceSignature"] as String,
    );

    return result;
  }

  Future<void> passSuccess(MethodCall call) async {
    String? primaryAccountIdentifier =
        call.arguments["primaryAccountIdentifier"];
    widget.addedCard?.call(primaryAccountIdentifier ?? '');
  }

  @override
  void dispose() {
    WalletCard().removeHandler(widget._id);
    super.dispose();
  }

  Future<Object?>? canAddPass() async {
    var result = await WalletCard().canAddPass({
      "accountIdentifier": widget.accountIdentifier ?? "",
      "cardSuffix": widget.cardSuffix ?? "",
    });

    if (result == false) {
      widget.addedCard!('');
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: canAddPass(),
      builder: (context, snapshot) {
        if (snapshot.data == true) {
          return SizedBox(
            width: widget.width,
            height: widget.height,
            child: platformWidget(context),
          );
        }

        return Container();
      },
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
        return InkWell(
          onTap: widget.onPressed,
          child: Image.asset(
            'packages/wallet_card/assets/add_wallet.png',
            width: widget.width,
          ),
        );
      default:
        if (widget.unsupportedPlatformChild == null) {
          throw UnsupportedError('Unsupported platform view');
        }
        return widget.unsupportedPlatformChild!;
    }
  }
}
