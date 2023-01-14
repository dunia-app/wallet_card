#import "WalletCardPlugin.h"
#if __has_include(<wallet_card/wallet_card-Swift.h>)
#import <wallet_card/wallet_card-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "wallet_card-Swift.h"
#endif

@implementation WalletCardPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftWalletCardPlugin registerWithRegistrar:registrar];
}
@end
