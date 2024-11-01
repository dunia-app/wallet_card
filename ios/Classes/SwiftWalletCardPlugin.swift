import Flutter
import Foundation
import PassKit
import UIKit
import WatchConnectivity

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
      let pluginResponse = WalletPluginResponse(methodName: call.method, status: false)
        
      switch call.method {
        case "canAddPass":
            print("canAddPass")
            let args = call.arguments as! [String: Any]
            let accountIdentifier = args["accountIdentifier"] as! String
            let suffix = args["cardSuffix"] as! String
            print(suffix)
          
            let canAddPassResult = canAddPass(accountIdentifier: accountIdentifier, suffix: suffix)
            pluginResponse.message = ["result": canAddPassResult]
            pluginResponse.status = canAddPassResult
            result(pluginResponse.toDictionary())
            
        default:
            pluginResponse.status = false
            pluginResponse.message = ["result": "Method not implemented"]
            result(pluginResponse.toDictionary())
        }
    }

    private func canAddPass(accountIdentifier: String, suffix: String) -> Bool {
        let canAddPass = PKAddPaymentPassViewController.canAddPaymentPass()
        let passes = PKPassLibrary().passes(of: .secureElement)
        print(passes)
        print(passes.count)
        
        var canAddPassPhone = true
        for pass in passes {
            print(pass)
            print(pass.secureElementPass)
            print(pass.secureElementPass?.deviceAccountNumberSuffix)
            print(pass.secureElementPass?.primaryAccountNumberSuffix)
            print(suffix)
            if (pass.secureElementPass?.primaryAccountNumberSuffix == suffix) {
                canAddPassPhone = false
            }
        }
        
        if (WCSession.isSupported() && WCSession.default.isPaired) {
            var canAddPassWatch = true
            let remotePasses = PKPassLibrary().remoteSecureElementPasses
            for pass in remotePasses {
              print(pass)
              if (pass.secureElementPass?.deviceAccountNumberSuffix == suffix) {
                canAddPassWatch = false
              }
            }

            print(canAddPass)
            print(canAddPassPhone)
            print(canAddPassWatch)
            return canAddPass && canAddPassPhone && canAddPassWatch
        } else {
            print(canAddPass)
            print(canAddPassPhone)
            return canAddPass && canAddPassPhone
        }
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
    private var _accountIdentifier: String
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
        _accountIdentifier = args["accountIdentifier"] as! String
        _channel = channel
        super.init()
        createAddPassButton()
    }

    func view() -> UIView {
        _view
    }

    func createAddPassButton() {
        let passButton = PKAddPassButton(addPassButtonStyle: .blackOutline)
        passButton.addTarget(self, action: #selector(passButtonAction), for: .touchUpInside)
        view().addSubview(passButton)
        passButton.translatesAutoresizingMaskIntoConstraints = false
        passButton.leadingAnchor.constraint(equalTo: view().leadingAnchor, constant: 32).isActive = true
        passButton.trailingAnchor.constraint(equalTo: view().trailingAnchor, constant: -32).isActive = true
    }

    @objc func passButtonAction() {
        PKAddPaymentPassViewController.canAddPaymentPass()
        guard let configuration = PKAddPaymentPassRequestConfiguration(encryptionScheme: .ECC_V2) else {
          return
        }

        print("accountIdentifier")
        print(_accountIdentifier)

        configuration.cardholderName = _cardHolderName
        configuration.primaryAccountSuffix = _cardSuffix
        configuration.primaryAccountIdentifier = _accountIdentifier
        configuration.paymentNetwork = PKPaymentNetwork.masterCard

        guard let addPassViewController = PKAddPaymentPassViewController(requestConfiguration: configuration, delegate: self),
              let rootVC = UIApplication.shared.keyWindow?.rootViewController else {
            return
        }

        rootVC.present(addPassViewController, animated: true)
    }

    func addPaymentPassViewController(
        _ controller: PKAddPaymentPassViewController,
        generateRequestWithCertificateChain certificates: [Data],
        nonce: Data, nonceSignature: Data,
        completionHandler handler: @escaping (PKAddPaymentPassRequest) -> Void) {

        var certifs: [String] = []
        for certificate in certificates { 
            certifs.append(certificate.base64EncodedString())
        }
      
        _channel.invokeMethod("add_payment_pass", arguments: ["key": _key, "certificates": certifs, "nonce": nonce.base64EncodedString(), "nonceSignature": nonceSignature.base64EncodedString()], result: { r in
          let decoder = JSONDecoder()
          guard let result = r as? String,
                let otpData = try? JSONSerialization.data(withJSONObject: ["issuerInitiatedDigitizationData": result]),
                let decoded = try? decoder.decode(DigitizationData.self, from: otpData) else {
            return
          }

          let request = PKAddPaymentPassRequest()
          request.activationData = decoded.activationData
          request.ephemeralPublicKey = decoded.ephemeralPublicKey
          request.encryptedPassData = decoded.encryptedPassData

          handler(request)
        })
    }
    
    func addPaymentPassViewController(
        _ controller: PKAddPaymentPassViewController,
        didFinishAdding pass: PKPaymentPass?,
        error: Error?) {

        print("addPaymentPassViewController : ")
        print(error)
        _channel.invokeMethod("add_payment_pass_success", arguments: ["key": _key, "primaryAccountIdentifier": pass?.primaryAccountIdentifier], result: { r in
          controller.dismiss(animated: true)
        })
    }
}

public struct DigitizationData {
    public let activationData: Data
    public let encryptedPassData: Data
    public let ephemeralPublicKey: Data
}

extension DigitizationData: Codable {
    private enum CodingKeys: String, CodingKey {
        case content = "issuerInitiatedDigitizationData"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let content = try container.decode(Data.self, forKey: .content)
        
        guard let dictionary = try JSONSerialization.jsonObject(with: content) as? [String: String] else {
            throw DecodingError.typeMismatch(
                [String: String].self,
                DecodingError.Context(
                    codingPath: [CodingKeys.content],
                    debugDescription: "Unable to serialise `issuerInitiatedDigitizationData` as `[String: String]`."
                )
            )
        }

        guard let activationData = dictionary["activationData"],
            let encryptedPassData = dictionary["encryptedPassData"],
            let ephemeralPublicKey = dictionary["ephemeralPublicKey"] else {
                throw DecodingError.dataCorruptedError(
                    forKey: .content,
                    in: container,
                    debugDescription: "`issuerInitiatedDigitizationData` has a missing key (\"activationData\", \"encryptedPassData\" or \"ephemeralPublicKey\")."
                )
            }

        guard let data = Data(base64Encoded: activationData),
              let activationDataDictionary = try JSONSerialization.jsonObject(with: data) as? [String: String] else {
                throw DecodingError.typeMismatch(
                    [String: String].self,
                    DecodingError.Context(
                    codingPath: [CodingKeys.content],
                    debugDescription: "Unable to serialise `activationData` as `[String: String]`."
                    )
                )
        }

        guard let activationData = activationDataDictionary["tokenizationAuthenticationValue"] else {
            throw DecodingError.dataCorruptedError(
                forKey: .content,
                in: container,
                debugDescription: "The key \"tokenizationAuthenticationValue\" is missing from the `activationData` dictionary."
            )
        }

        guard let activationData = Data(base64Encoded: activationData),
            let encryptedPassData = Data(base64Encoded: encryptedPassData),
            let ephemeralPublicKey = Data(base64Encoded: ephemeralPublicKey) else {
            throw DecodingError.dataCorruptedError(
            forKey: .content,
            in: container,
            debugDescription: "Unable to convert a base64 string to Data."
            )
        }

        self.activationData = activationData
        self.encryptedPassData = encryptedPassData
        self.ephemeralPublicKey = ephemeralPublicKey
    }

    public func encode(to _: Encoder) throws { // swiftlint:disable:this unavailable_function
        fatalError("encode(to:) has not been implemented")
        }
}

class WalletPluginResponse {
    var methodName: String
    var status: Bool
    var message: [String: Any]
    
    init(methodName: String, status: Bool) {
        self.methodName = methodName
        self.status = status
        message = [:]
    }
    
    init(methodName: String, status: Bool, message: [String: Any]) {
        self.methodName = methodName
        self.status = status
        self.message = message
    }
    
    func toDictionary() -> [String: Any] {
        print("réponse")
        print("méthode : ")
        print(methodName)
        print("message : ")
        print(message)
        
        return ["methodName": methodName, "status": status, "message": message]
    }
}
