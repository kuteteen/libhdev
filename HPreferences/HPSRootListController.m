#include "HPSRootListController.h"

@implementation HPSRootListController

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  UIColor *tintColor = [HCommon colorFromHex:self.tintColorHex];
  // set switches color
  UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
  self.view.tintColor = tintColor;
  keyWindow.tintColor = tintColor;
  [UISwitch appearanceWhenContainedInInstancesOfClasses:@[self.class]].onTintColor = tintColor;
  // set navigation bar color
  self.navigationController.navigationController.navigationBar.barTintColor = tintColor;
  self.navigationController.navigationController.navigationBar.tintColor = [UIColor whiteColor];
  [self.navigationController.navigationController.navigationBar setShadowImage: [UIImage new]];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self.navigationController.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
  keyWindow.tintColor = nil;
  self.navigationController.navigationController.navigationBar.barTintColor = nil;
  self.navigationController.navigationController.navigationBar.tintColor = nil;
  [self.navigationController.navigationController.navigationBar setShadowImage:nil];
  [self.navigationController.navigationController.navigationBar setTitleTextAttributes:nil];
}

- (NSArray *)specifiers {
  if (!_specifiers) {
    _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
  }
  return _specifiers;
}

- (id)readPreferenceValue:(PSSpecifier *)specifier {
  NSString *path = [self getSavedPrefPath:specifier];
  NSDictionary *settings = [[NSDictionary alloc] initWithContentsOfFile:path];
  return settings[[[specifier properties] objectForKey:@"key"]] ?: [[specifier properties] objectForKey:@"default"];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
  NSString *path = [self getSavedPrefPath:specifier];
  NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:path] ?: [@{} mutableCopy];
  [settings setObject:value forKey:[[specifier properties] objectForKey:@"key"]];
  [settings writeToFile:path atomically:YES];
  [self notifyPrefChanges:specifier];
}

- (void)resetSettings:(PSSpecifier *)specifier {
  NSString *path = [self getSavedPrefPath:specifier];
  [@{} writeToFile:path atomically:YES];
  [self reloadSpecifiers];
  [self notifyPrefChanges:specifier];
}

- (void)notifyPrefChanges:(PSSpecifier *)specifier {
  CFStringRef notificationName = (__bridge CFStringRef)specifier.properties[@"PostNotification"];
  if (notificationName) {
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), notificationName, NULL, NULL, true);
  }
}

- (void)openURL:(PSSpecifier *)specifier {
  UIApplication *app = [UIApplication sharedApplication];
  NSString *url = [specifier.properties objectForKey:@"url"];
  [app openURL:[NSURL URLWithString:url] options:@{} completionHandler:nil];
}

- (NSString *)getSavedPrefPath:(PSSpecifier *)specifier {
  return [NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
}

- (NSString *)localizedItem:(NSString *)key {
  return [HCommon localizedItem:key bundlePath:self.bundlePath];
}

@end
