import 'dart:io';

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

  _onPress(
    BuildContext context,
    String holderName,
    String suffix,
  ) async {
    if (Platform.isAndroid) {
      var result = "azerttyuio";
      WalletCard().saveAndroidPass(holderName, suffix, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    String holderName = "Test Test";
    String suffix = "1234";

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: AddToWalletButton(
            width: 150,
            height: 30,
            cardHolderName: holderName,
            cardSuffix: suffix,
            onPressed: () {
              _onPress(context, holderName, suffix);
            },
            loadCard: (certificates, nonce, nonceSignature) {
              return {
                "encryptedPassData":
                    "vKK3QZcNbTrOUqrwIjU/2GbpXjFIqLiN+sohNtfReDHXiFRHwOji131CmkwCQBKMHv+758F9IFPyRnWBLQf0aMrlmUxJv0IGLTKp3TJu0MiTQJA98KH89D55oZ8+WNQT+adfTtMA9JxgMpjQdnyQVatGQy/wyIyiAF70a25obzj1/Ucz0g24OrJw9GS3b3v7NdoBYfVmxDMbvAp2lg5ca+hhGblpvExO/DZP5K0WdpMIuVyGqDxTusau/OS4PJ0FRHe+x6p9Etu9BFT5H7aBFozmhfIr8prkXopJFnM6KWhORlnCSKtjFq5FgkyU1l8WZoZYkw9pFXjWqNc3v8QIOHWnBcmwAPVAHS6+paAgGUC0A0OiilXPAnoseJDhSf2NhY3M8C0H/nXjNfSz",
                "activationData":
                    "eyJ2ZXJzaW9uIjoiMiIsImV4cGlyYXRpb25EYXRlSW5jbHVkZWQiOiJ0cnVlIiwidG9rZW5VbmlxdWVSZWZlcmVuY2VJbmNsdWRlZCI6ImZhbHNlIiwic2lnbmF0dXJlQWxnb3JpdGhtIjoiUlNBLVNIQTI1NiIsInNpZ25hdHVyZSI6IndMK2xqbU5QdkNYbE1wUjltY3ZLNDI4dTVVR0F6cjhnWW9NUG9aMTBCbWY1ZEFPRDVoU2lWaExzQXN0V0k1MGNIS3IvbHdnYm0zaUdTWGp2RnlvOHJZZW0xNXNoMHVGcW9XOGZJZ1hzZERRcWF5SWprQkZhYnZleXlIOEt3THh5eG4vTnVpMzh3ZFRUeFpSeEw3QWJMcmd1MFp4ZWU0V0I3MW9PSnNGaWIzVDU2Q2s3Zm1naGhhMHVLY2RCVHdybGkrYjBlTVE5SE5rN0ZrTWUvMkZtTVRpR2lVUkNFOXNRTG0rT3JUbU1ENFZTYkZVUlpwWGJQRDFqTEF2aHg5ZmxwTUZrLzd1SU1BbXpybGtwVk5XNjVKdUtRM1BYVDRlbU40SFRhVVk5VG5NR0Y2Y0liSVJXczJRUUpPaDhGaGpnR2dQY01CYm9xQWZLcDF5WFR0M0dlZz09In0=",
                "ephemeralPublicKey":
                    "BJfe5WKlAKlJSlaR6+k7yl7L7WpCrSrzgnMY5x33schp1zDYMGgSkpzo9iee4SbY2CAKgUfJohfz7fLT/vtZBxQ=",
              };
            },
          ),
        ),
      ),
    );
  }
}
