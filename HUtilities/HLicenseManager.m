#import "HLicenseManager.h"

@implementation HLicenseManager

+ (void)licenseTracker:(NSString *)licenseServer apiKey:(NSString *)apiKey plistFile:(NSString *)plistFile tweakName:(NSString *)tweakName tweakVersion:(NSString *)tweakVersion {
  NSString *documentDirPlistPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:plistFile];
  NSMutableDictionary *documentDirSettings = [[NSMutableDictionary alloc] initWithContentsOfFile:documentDirPlistPath] ?: [@{} mutableCopy];
  BOOL init1 = [[documentDirSettings objectForKey:tweakVersion] ?: @(NO) boolValue];
  if (init1) {
    return;
  }

  // get device info
  NSString *name= [[UIDevice currentDevice] name];
  NSString *uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
  struct utsname systemInfo;
  uname(&systemInfo);
  NSString *device_type = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
  NSString *ios_version = [[UIDevice currentDevice] systemVersion];

  // make request
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:licenseServer]];
  NSString *post =[NSString stringWithFormat:@"name=%@&uuid=%@&device_type=%@&ios_version=%@&tweak_name=%@&tweak_version=%@", name, uuid, device_type, ios_version, tweakName, tweakVersion];
  NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
  NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
  [request setHTTPMethod:@"POST"];
  [request setHTTPBody:postData];
  [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
  [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
  [request setValue:apiKey forHTTPHeaderField:@"api-access-token"];
  [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];

  NSURLSession *session = [NSURLSession sharedSession];
  NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if (httpResponse.statusCode == 200) {
      NSError *parseError = nil;
      NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
      NSInteger result = [[responseDictionary objectForKey:@"result"] integerValue];
      if (result == 1) {
        [documentDirSettings setObject:[NSNumber numberWithBool:TRUE] forKey:tweakVersion];
        [documentDirSettings writeToFile:documentDirPlistPath atomically:YES];
      }
    }
  }];
  [dataTask resume];
}

@end
