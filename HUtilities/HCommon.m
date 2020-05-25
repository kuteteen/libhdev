#import "../HUtilities/HCommon.h"

@implementation HCommon
+ (NSString *)localizedItem:(NSString *)key bundlePath:(NSString *)bundlePath{
  NSBundle *tweakBundle = [NSBundle bundleWithPath:bundlePath];
  return [tweakBundle localizedStringForKey:key value:@"" table:@"Root"];
}

+ (UIColor *)colorFromHex:(NSString *)hexString {
  unsigned rgbValue = 0;
  if ([hexString hasPrefix:@"#"]) hexString = [hexString substringFromIndex:1];
  if (hexString) {
  NSScanner *scanner = [NSScanner scannerWithString:hexString];
  [scanner setScanLocation:0]; // bypass '#' character
  [scanner scanHexInt:&rgbValue];
  return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
  }
  else return [UIColor grayColor];
}

+ (void)respring {
  NSTask *killall = [[NSTask alloc] init];
  [killall setLaunchPath:@"/usr/bin/killall"];
  [killall setArguments:[NSArray arrayWithObjects:@"backboardd", nil]];
  [killall launch];
}

+ (void)killProcess:(NSString *)procName viewController:(UIViewController *)viewController alertTitle:(NSString *)alertTitle message:(NSString *)message confirmActionLabel:(NSString *)confirmActionLabel cancelActionLabel:(NSString *)cancelActionLabel {
  UIAlertController *killConfirm = [UIAlertController alertControllerWithTitle:alertTitle message:message?:[NSString stringWithFormat:@"Kill %@?", procName] preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:confirmActionLabel?:@"Confirm" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
    NSTask *killall = [[NSTask alloc] init];
    [killall setLaunchPath:@"/usr/bin/killall"];
    [killall setArguments:@[@"-9", procName]];
    [killall launch];
  }];

  UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelActionLabel?:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
  [killConfirm addAction:confirmAction];
  [killConfirm addAction:cancelAction];
  [viewController presentViewController:killConfirm animated:YES completion:nil];
}
@end