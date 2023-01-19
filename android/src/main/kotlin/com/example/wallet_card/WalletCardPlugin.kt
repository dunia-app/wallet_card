package com.example.wallet_card

import android.app.Activity
import androidx.annotation.NonNull
import com.google.android.gms.pay.Pay
import com.google.android.gms.pay.PayClient
import com.google.android.gms.wallet.*
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import com.google.android.gms.tapandpay.TapAndPay
import com.google.android.gms.tapandpay.TapAndPayClient
import com.google.android.gms.tapandpay.issuer.PushTokenizeRequest
import com.google.android.gms.tapandpay.issuer.UserAddress


/** WalletCardPlugin */
class WalletCardPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  private var operations: MutableMap<String, WalletCardPluginResponseWrapper> = mutableMapOf()
  private lateinit var currentOperation: WalletCardPluginResponseWrapper

  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var activity: Activity
  private lateinit var channel : MethodChannel

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "wallet_card")
    channel.setMethodCallHandler(this)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivity() {
    TODO("Not yet implemented")
  }

  override fun onDetachedFromActivityForConfigChanges() {
    TODO("Not yet implemented")
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    TODO("Not yet implemented")
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (!operations.containsKey(call.method)) {
      operations[call.method] = WalletCardPluginResponseWrapper(call.method, result)
    }

    val walletCardPluginResponseWrapper = operations[call.method]!!
    walletCardPluginResponseWrapper.methodResult = result
    walletCardPluginResponseWrapper.response = WalletCardPluginResponse(call.method)

    currentOperation = walletCardPluginResponseWrapper

    when (call.method) {
      "savePass" -> savePass(call.argument("holderName") as String?, call.argument("suffix") as String?, call.argument("pass") as String?).flutterResult()
      else -> result.notImplemented()
    }
  }

  private fun savePass(holderName: String?, suffix: String?, pass: String?): WalletCardPluginResponseWrapper {
    val currentOp = operations["savePass"]!!
    try {
      val opcBytes: kotlin.ByteArray = pass!!.toByteArray()
      val pushTokenizeRequest: PushTokenizeRequest = PushTokenizeRequest.Builder()
        .setOpaquePaymentCard(opcBytes)
        .setNetwork(TapAndPay.CARD_NETWORK_MASTERCARD)
        .setTokenServiceProvider(TapAndPay.TOKEN_PROVIDER_MASTERCARD)
        .setDisplayName(holderName!!)
        .setLastDigits(suffix!!)
        .build()

      val tapAndPayClient = TapAndPay.getClient(activity);
      tapAndPayClient.pushTokenize(
        activity,  // here i'm passing my current activity.
        pushTokenizeRequest,
        1
      )
      /*
      val walletClient: PayClient = Pay.getClient(activity.application)
      walletClient.savePasses(pass, activity, 0)
       */
      currentOp.response.message = mutableMapOf("initialized" to true)
      currentOp.response.status = true
    } catch (e: Exception) {
      currentOp.response.message = mutableMapOf("initialized" to false, "errors" to e.message)
      currentOp.response.status = false
    }
    return currentOp
  }
}

class WalletCardPluginResponseWrapper(@NonNull var methodName: String, @NonNull var methodResult: Result) {
    lateinit var response: WalletCardPluginResponse
    fun flutterResult() {
        methodResult.success(response.toMap())
    }
}

class WalletCardPluginResponse(@NonNull var methodName: String) {
    var status: Boolean = false
    lateinit var message: MutableMap<String, Any?>
    fun toMap(): Map<String, Any?> {
        return mapOf("status" to status, "message" to message, "methodName" to methodName)
    }
}