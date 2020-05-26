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


+ (void) showAlertMessage:(NSString *)message withTitle:(NSString *)title viewController:(UIViewController *)viewController {
  __block UIWindow* topWindow;
  if (!viewController) {
    topWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    topWindow.rootViewController = [UIViewController new];
    topWindow.windowLevel = UIWindowLevelAlert + 1;
  }
  UIAlertController* alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
  [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    if (!viewController) {
      topWindow.hidden = YES;
      topWindow = nil;
    }
  }]];

  if (!viewController) {
    [topWindow makeKeyAndVisible];
  }
  [viewController ? viewController : topWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}

+ (void) showToastMessage:(NSString *)message withTitle:(NSString *)title timeout:(double)timeout viewController:(UIViewController *)viewController {
  if (timeout <= 0.01) {
    timeout = 1.0;
  }
  __block UIWindow* topWindow;
  if (!viewController) {
    topWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    topWindow.rootViewController = [UIViewController new];
    topWindow.windowLevel = UIWindowLevelAlert + 1;
  }
  UIAlertController* alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
  
  if (!viewController) {
    [topWindow makeKeyAndVisible];
  }
  [viewController ? viewController : topWindow.rootViewController presentViewController:alert animated:YES completion:nil];
  
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [alert dismissViewControllerAnimated:YES completion:^{
      if (!viewController) {
        topWindow.hidden = YES;
        topWindow = nil;
      }
    }];
  });
}
@end