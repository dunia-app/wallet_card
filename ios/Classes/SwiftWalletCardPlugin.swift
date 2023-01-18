import Flutter
import Foundation
import PassKit
import UIKit

import Flutter
import UIKit

public class SwiftWalletCardPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "wallet_card", binaryMessenger: registrar.messenger())
    let instance = SwiftWalletCardPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)

    let factory = PKAddPassButtonNativeViewFactory(messenger: registrar.messenger(), channel: channel)
    registrar.register(factory, withId: "PKAddPassButton")
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    print("Not implemented")
    return result(FlutterMethodNotImplemented)
  }
}


class PKAddPassButtonNativeViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger
    private var channel: FlutterMethodChannel

    init(messenger: FlutterBinaryMessenger, channel: FlutterMethodChannel) {
        self.messenger = messenger
        self.channel = channel
        super.init()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return PKAddPassButtonNativeView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args as! [String: Any],
            binaryMessenger: messenger,
            channel: channel)
    }
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
          return FlutterStandardMessageCodec.sharedInstance()
    }
}

class PKAddPassButtonNativeView: NSObject, FlutterPlatformView, PKAddPaymentPassViewControllerDelegate {
    private var _view: UIView
    private var _width: CGFloat
    private var _height: CGFloat
    private var _key: String
    private var _cardHolderName: String
    private var _cardSuffix: String
    private var _channel: FlutterMethodChannel

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: [String: Any],
        binaryMessenger messenger: FlutterBinaryMessenger?,
        channel: FlutterMethodChannel
    ) {
        _view = UIView()
        _width = args["width"] as? CGFloat ?? 140
        _height = args["height"] as? CGFloat ?? 30
        _key = args["key"] as! String
        _cardHolderName = args["cardHolderName"] as! String
        _cardSuffix = args["cardSuffix"] as! String
        _channel = channel
        super.init()
        createAddPassButton()
    }

    func view() -> UIView {
        _view
    }

    func createAddPassButton() {
        let passButton = PKAddPassButton(addPassButtonStyle: PKAddPassButtonStyle.black)
        passButton.frame = CGRect(x: 0, y: 0, width: _width, height: _height)
        passButton.addTarget(self, action: #selector(passButtonAction), for: .touchUpInside)
        _view.addSubview(passButton)
    }

    @objc func passButtonAction() {
        guard let configuration = PKAddPaymentPassRequestConfiguration(encryptionScheme: .ECC_V2) else {
            print("InApp enrollment configuraton fails")
            //showPassKitUnavailable(message: "InApp enrollment configuraton fails")
            return
        }

        configuration.cardholderName = _cardHolderName
        configuration.primaryAccountSuffix = _cardSuffix

        guard let addPassViewController = PKAddPaymentPassViewController(requestConfiguration: configuration, delegate: self) else {
            print("View controller messed up")
            return
        }

        guard let rootVC = UIApplication.shared.keyWindow?.rootViewController else {
            print("Root VC unavailable")
            return
        }
        rootVC.present(addPassViewController, animated: true)
    }

    func addPaymentPassViewController(
        _ controller: PKAddPaymentPassViewController,
        generateRequestWithCertificateChain certificates: [Data],
        nonce: Data, nonceSignature: Data,
        completionHandler handler: @escaping (PKAddPaymentPassRequest) -> Void) {
      
        _channel.invokeMethod("add_payment_pass", arguments: ["key": _key, "certificates": certificates, "nonce": nonce, "nonceSignature": nonceSignature], result: { r in
          print(r)
          print(r as? Dictionary<String, String?>)
          guard let params = r as? Dictionary<String, String?> else {
            print("Error addPaymentPassViewController"); return
          }
            
          guard let data = params["encryptedPassData"] as? String,
            let key = params["ephemeralPublicKey"] as? String,
            let otp = params["activationData"] as? String else {
              print("Error addPaymentPassViewController"); return
          }
          
          let encryptedPassData = Data(base64Encoded: data)
          let ephemeralPublicKey = Data(base64Encoded: key)
          let activationData = Data(otp.utf8).base64EncodedData()

          let request = PKAddPaymentPassRequest()
          request.activationData = activationData
          request.encryptedPassData = encryptedPassData
          request.ephemeralPublicKey = ephemeralPublicKey

          print(request)
          print(request.activationData)
          print(request.encryptedPassData)
          print(request.ephemeralPublicKey)

          handler(request)
        })
    }
    
    func addPaymentPassViewController(
        _ controller: PKAddPaymentPassViewController,
        didFinishAdding pass: PKPaymentPass?,
        error: Error?) {
        print(error)
        print(pass)
    }
}
