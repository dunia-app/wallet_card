package com.example.wallet_card

import android.app.Activity
import android.util.Log
import android.view.View
import android.widget.TextView
import androidx.annotation.NonNull
import com.google.android.gms.tapandpay.TapAndPay
import com.google.android.gms.tapandpay.TapAndPayClient
import com.google.android.gms.tapandpay.issuer.PushTokenizeRequest
import com.google.android.gms.tapandpay.issuer.UserAddress
import com.google.android.gms.wallet.*
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler


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
  private lateinit var tapAndPayClient: TapAndPayClient

  private val REQUEST_CODE_PUSH_TOKENIZE: kotlin.Int = 3

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "wallet_card")
    channel.setMethodCallHandler(this)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
    tapAndPayClient = TapAndPay.getClient(activity)
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

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
    if (!operations.containsKey(call.method)) {
      operations[call.method] = WalletCardPluginResponseWrapper(call.method, result)
    }

    val walletCardPluginResponseWrapper = operations[call.method]!!
    walletCardPluginResponseWrapper.methodResult = result
    walletCardPluginResponseWrapper.response = WalletCardPluginResponse(call.method)

    currentOperation = walletCardPluginResponseWrapper

    when (call.method) {
      "savePass" -> savePass(call.argument("holderName") as String?, call.argument("suffix") as String?, call.argument("pass") as String?).flutterResult()
      "canAddPass" -> canAddPass(call.argument("accountIdentifier") as String?)
      else -> result.notImplemented()
    }
  }

  private fun canAddPass(accountIdentifier: String?): WalletCardPluginResponseWrapper {
    val currentOp = operations["savePass"]!!
    currentOp.response.message = mutableMapOf("initialized" to true)

    tapAndPayClient
      .listTokens()
      .addOnCompleteListener(
        object : OnCompleteListener<List<TokenInfo?>?>() {
          fun onComplete(@NonNull task: Task<List<TokenInfo?>?>) {
            val listTokensError: TextView = getView().findViewById(R.id.list_tokens_error)
            if (task.isSuccessful()) {
              for (token in task.getResult()) {
                val operation = operations["savePass"]!!
                operation.response.status = false
                operation.flutterResult()
              }
            } else {
              val operation = operations["savePass"]!!
              operation.response.status = true
              operation.flutterResult()
            }
          }
        })

    return currentOp
  }

  private fun savePass(holderName: String?, suffix: String?, pass: String?): WalletCardPluginResponseWrapper {
    val currentOp = operations["savePass"]!!
    try {
      activity.runOnUiThread(Runnable {
        try {
          val opcBytes: kotlin.ByteArray = pass!!.toByteArray()
          var userAddress: UserAddress = UserAddress.newBuilder()
            .setName("")
            .setAddress1("")
            .setLocality("")
            .setAdministrativeArea("")
            .setCountryCode("")
            .setPostalCode("")
            .setPhoneNumber("")
            .build()

          var pushTokenizeRequest: PushTokenizeRequest = PushTokenizeRequest.Builder()
            .setOpaquePaymentCard(opcBytes)
            .setNetwork(TapAndPay.CARD_NETWORK_MASTERCARD)
            .setTokenServiceProvider(TapAndPay.TOKEN_PROVIDER_MASTERCARD)
            .setDisplayName(holderName!!)
            .setLastDigits(suffix!!)
            .setUserAddress(userAddress)
            .build()

          Log.i("TAG", "before push");
          tapAndPayClient.pushTokenize(
            activity,
            pushTokenizeRequest,
            REQUEST_CODE_PUSH_TOKENIZE
          )
          Log.i("TAG", "after push");
        } catch (e: Exception) {
          Log.i("TAG", e.message!!);
        }
      })

      currentOp.response.message = mutableMapOf("initialized" to true)
      currentOp.response.status = true
    } catch (e: Exception) {
      currentOp.response.message = mutableMapOf("initialized" to false, "errors" to e.message)
      currentOp.response.status = false
    }
    return currentOp
  }
}

class WalletCardPluginResponseWrapper(@NonNull var methodName: String, @NonNull var methodResult: MethodChannel.Result) {
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