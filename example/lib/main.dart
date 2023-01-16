import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:wallet_card/wallet_card.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  //final _walletCardPlugin = WalletCard();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: AddToWalletButton(
            width: 150,
            height: 30,
            cardHolderName: "Holder Name",
            cardSuffix: "1234",
            loadCard: (certificates, nonce, nonceSignature) {
              return {
                "encryptedPassData": "test",
                "activationData": "test",
                "ephemeralPublicKey": "test",
              };
            },
          ),
        ),
      ),
    );
  }
}
