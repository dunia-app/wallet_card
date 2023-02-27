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
      var result =
          "eyJjYXJkSW5mbyI6eyJwdWJsaWNLZXlGaW5nZXJwcmludCI6IkY3Q0FBNzAyM0RENkZDRTk5Q0Q0NEM1RUEzOUY2N0FGRUM0Rjg0NzUiLCJlbmNyeXB0ZWRLZXkiOiIwNDRkOTlmYjhjNzhlNmEwNTgyMzVhNTY4YmNhYmVlNTdjM2E2Y2I4OWJhMmExMDlkZTQ4Mzg3M2FiMzUxZTEyMmJlOGU5NjVkNDQ2Mjk0ZDBjNWQ2NjgyM2I1YzUwODkzYzAzZTg4YTNjMDgxYjBkNGQ4ZDYxZmZlNDc1MTIzNTZiZWI3ZWNlNDIzYzM3MDRlNDg0MTRlMzAzMDZmOTkyNWRmOTZhYWJkMzEyNTNjNWJhYjMyZDEyNTRjNzM5NDIyMjk4MjFhYmE0MzBkOTNhOGQ1NTkyNmJlZWEwZDg5NmUxY2M2NWQxY2MyYzMyZDcwNDU0YWEwNmM5NTVlZGQxYzM4Mjg1ZDU5ZDI2MzU2ZTAxNWMxNzE0NzRiZWJmYTM5MWZkMGE0NzhkNGE2OGQ3Yzc5NDg3MzZkZjM4ODgyOGUwNDlmYjhhOThjYTdjMTE3ZGYzMWZmODhmOTU1YmQ1OGJmMTRiYzIyMWYxNjJjNTQ5ZDUzMjExYzg4MzhkODNiMWQ1ZmQ3MWE3NDhiNDRmODhlYmU4YjJlYzM5OTY0ZDI0ZGFjZTU3ZGRkYTM3YTczNDRjNDViZDc5ZDZlYWVjYTliYmJmYmZhZjgwNGY0YzM4NGY2M2NlZTY2ODViOTI3ZDVlMTQyYTFkMmY0Yjg1MDI2ZTIxN2ZiOGNlOWExOCIsIm9hZXBIYXNoaW5nQWxnb3JpdGhtIjoiU0hBMjU2IiwiaXYiOiJhOTZhZjYzNjQ3OGVlYjZiMDI5MGU3MGJmMWRkZTk2YiIsImVuY3J5cHRlZERhdGEiOiJjM2JhMmU0YzU5MTk1N2ZjZDM5NDAyOTQxODJkNGExYzg0ZTFmODRhODY3YjU2ZTI2MjVhOTE4ZTRlMzkxOWE0MmFhYTU3OTM2YTBiM2IzNWQ1NDdkNGUzYjBlZDY3Y2Q4Yzg1ZmI5ODg2NTZiNDQ0NzhiNGVjNzNhNGNkZjdmMDMyZjMzZTVmMGRjMzE0MGQ1OThiNmY5NjUxZmUzZmE5OTY2ZTBkNDc1YTk4YWRjOTIzZTA2NGU3ZmE0OWQ4MTk3YTRmNWM2ZWJhN2U3NWEzYzk2MjdlY2EzZGNmYmQ5MTcwMWEzNTIxYzViZDRkMDdmOTg2ODY5YmEwZTE4ZmIzM2ZhNDEzYmUxMzAwZGNjMTBlZmNkMTc4MGY1ODZmZjczMDI3N2I3YjBjNTc1Mjc0NWU1OTMxZTRjNDZkYjA5ZDUxY2NiYjM0ZGIyMWZmN2EzM2JlN2RlMjMzMTkyZjg4MDE5YTJiYTMxNzE5ODE4MjdhNDUxNGI0ODAyNGU1NjgifSwidG9rZW5pemF0aW9uQXV0aGVudGljYXRpb25WYWx1ZSI6ImV5SjJaWEp6YVc5dUlqb2lNaUlzSW1WNGNHbHlZWFJwYjI1RVlYUmxTVzVqYkhWa1pXUWlPaUowY25WbElpd2lkRzlyWlc1VmJtbHhkV1ZTWldabGNtVnVZMlZKYm1Oc2RXUmxaQ0k2SW1aaGJITmxJaXdpYzJsbmJtRjBkWEpsUVd4bmIzSnBkR2h0SWpvaVVsTkJMVk5JUVRJMU5pSXNJbk5wWjI1aGRIVnlaU0k2SW5kTUsyeHFiVTVRZGtOWWJFMXdVamx0WTNaTE5ESTRkVFZWUjBGNmNqaG5XVzlOVUc5YU1UQkNiV1kxWkVGUFJEVm9VMmxXYUV4elFYTjBWMGsxTUdOSVMzSXZiSGRuWW0wemFVZFRXR3AyUm5sdk9ISlpaVzB4TlhOb01IVkdjVzlYT0daSloxaHpaRVJSY1dGNVNXcHJRa1poWW5abGVYbElPRXQzVEhoNWVHNHZUblZwTXpoM1pGUlVlRnBTZUV3M1FXSk1jbWQxTUZwNFpXVTBWMEkzTVc5UFNuTkdhV0l6VkRVMlEyczNabTFuYUdoaE1IVkxZMlJDVkhkeWJHa3JZakJsVFZFNVNFNXJOMFpyVFdVdk1rWnRUVlJwUjJsVlVrTkZPWE5SVEcwclQzSlViVTFFTkZaVFlrWlZVbHB3V0dKUVJERnFURUYyYUhnNVpteHdUVVpyTHpkMVNVMUJiWHB5Ykd0d1ZrNVhOalZLZFV0Uk0xQllWRFJsYlU0MFNGUmhWVms1Vkc1TlIwWTJZMGxpU1ZKWGN6SlJVVXBQYURoR2FHcG5SMmRRWTAxQ1ltOXhRV1pMY0RGNVdGUjBNMGRsWnowOUluMD0ifQ==";
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
            accountIdentifier: "",
            onPressed: () {
              _onPress(context, holderName, suffix);
            },
            loadCard: (certificates, nonce, nonceSignature) {
              return "vKK3QZcNbTrOUqrwIjU/2GbpXjFIqLiN+sohNtfReDHXiFRHwOji131CmkwCQBKMHv+758F9IFPyRnWBLQf0aMrlmUxJv0IGLTKp3TJu0MiTQJA98KH89D55oZ8+WNQT+adfTtMA9JxgMpjQdnyQVatGQy/wyIyiAF70a25obzj1/Ucz0g24OrJw9GS3b3v7NdoBYfVmxDMbvAp2lg5ca+hhGblpvExO/DZP5K0WdpMIuVyGqDxTusau/OS4PJ0FRHe+x6p9Etu9BFT5H7aBFozmhfIr8prkXopJFnM6KWhORlnCSKtjFq5FgkyU1l8WZoZYkw9pFXjWqNc3v8QIOHWnBcmwAPVAHS6+paAgGUC0A0OiilXPAnoseJDhSf2NhY3M8C0H/nXjNfSz";
            },
          ),
        ),
      ),
    );
  }
}
