#import "HDownloadMedia.h"

@implementation HDownloadMedia
+ (void)checkPermissionToPhotosAndDownload:(NSString *)url appendExtension:(NSString *)fileExtension mediaType:(HDownloadMediaType)mediaType toAlbum:(NSString *)albumName {
  if (!url.length || !mediaType) {
    return;
  }

  PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
  switch (status) {
    case PHAuthorizationStatusNotDetermined: {
      [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus authorizationStatus) {
        if(authorizationStatus == PHAuthorizationStatusAuthorized) {
          [HDownloadMedia downloadAndSaveMediaToPhotoLibrary:url appendExtension:fileExtension mediaType:mediaType toAlbum:albumName];
        }
      }];
      break;
    }

    case PHAuthorizationStatusAuthorized: {
      [HDownloadMedia downloadAndSaveMediaToPhotoLibrary:url appendExtension:fileExtension mediaType:mediaType toAlbum:albumName];
      break;
    }

    case PHAuthorizationStatusDenied: {
      __block UIWindow* topWindow;
      topWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
      topWindow.rootViewController = [UIViewController new];
      topWindow.windowLevel = UIWindowLevelAlert + 1;
      UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Permission Required" message:@"App needs permission to Photos" preferredStyle:UIAlertControllerStyleAlert];
      [alert addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        topWindow.hidden = YES;
        topWindow = nil;
      }]];
      [alert addAction:[UIAlertAction actionWithTitle:@"Go To Settings" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
        topWindow.hidden = YES;
        topWindow = nil;
      }]];
      [topWindow makeKeyAndVisible];
      [topWindow.rootViewController presentViewController:alert animated:YES completion:nil];
      break;
    }

    case PHAuthorizationStatusRestricted: {
      [HCommon showAlertMessage:@"You don't have permission to Photos" withTitle:@"Restricted!" viewController:nil];
      break;
    }
  }
}

+ (void)downloadAndSaveMediaToPhotoLibrary:(NSString *)url appendExtension:(NSString *)fileExtension mediaType:(HDownloadMediaType)mediaType toAlbum:(NSString *)albumName {
  if (!url.length || !mediaType) {
    return;
  }

  NSURL *mediaUrl = [NSURL URLWithString:url];

  NSURLSessionDownloadTask* downloadTask = [[NSURLSession sharedSession] downloadTaskWithURL:mediaUrl completionHandler:^(NSURL* location, NSURLResponse* response, NSError* error) {
    if (error) {
      dispatch_async(dispatch_get_main_queue(), ^{
        [HCommon showAlertMessage:[error localizedDescription] withTitle:@"Download Error" viewController:nil];
      });
    }

    NSString* fileName = [mediaUrl lastPathComponent];
    if (fileExtension) {
      fileName = [fileName stringByAppendingPathExtension:fileExtension];
    }
    [location setResourceValue:fileName forKey:NSURLNameKey error:nil];
    location = [[location URLByDeletingLastPathComponent] URLByAppendingPathComponent:fileName];

    void (^completionHandlerBlock)(BOOL success, NSError* error) = ^void(BOOL success, NSError* error) {
      [[NSFileManager defaultManager] removeItemAtURL:location error:nil];
      if(success) {
        dispatch_async(dispatch_get_main_queue(), ^{
          [HCommon showToastMessage:@"Download Success" withTitle:nil timeout:1.0 viewController:nil];
        });
      } else {
        dispatch_async(dispatch_get_main_queue(), ^{
          [HCommon showAlertMessage:[error localizedDescription] withTitle:@"Download Error" viewController:nil];
        });
      }
    };

    if (!albumName.length) {
      [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:location];
      } completionHandler:completionHandlerBlock];
    } else {
      void (^saveBlock)(PHAssetCollection *assetCollection) = ^void(PHAssetCollection *assetCollection) {
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
          PHAssetChangeRequest *assetChangeRequest;
          if (mediaType == Image) {
            assetChangeRequest = [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:location];
          } else if (mediaType == Video) {
            assetChangeRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:location];
          }
          PHAssetCollectionChangeRequest *assetCollectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
          [assetCollectionChangeRequest addAssets:@[[assetChangeRequest placeholderForCreatedAsset]]];
        } completionHandler:completionHandlerBlock];
      };

      PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
      fetchOptions.predicate = [NSPredicate predicateWithFormat:@"localizedTitle = %@", albumName];
      PHFetchResult *fetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:fetchOptions];
      if (fetchResult.count > 0) {
        saveBlock(fetchResult.firstObject);
      } else {
        __block PHObjectPlaceholder *albumPlaceholder;
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
          PHAssetCollectionChangeRequest *changeRequest = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:albumName];
          albumPlaceholder = changeRequest.placeholderForCreatedAssetCollection;
        } completionHandler:^(BOOL success, NSError *error) {
          if (success) {
            PHFetchResult *fetchResult = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[albumPlaceholder.localIdentifier] options:nil];
            if (fetchResult.count > 0) {
              saveBlock(fetchResult.firstObject);
            }
          } else {
            [HCommon showAlertMessage:[error localizedDescription] withTitle:@"Error creating album" viewController:nil];
          }
        }];
      }
    }
  }];
  [downloadTask resume];
}
@end
