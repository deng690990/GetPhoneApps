//
//  WorkspaceTool.m
//  HHDemo
//
//  Created by Tim on 2024/7/16.
//

#import "WorkspaceTool.h"
#import <UIKit/UIKit.h>

@implementation WorkspaceAppInfo

@end

@implementation WorkspaceTool

+ (void)getApplications:(WorkspaceToolBlock)block {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *apps = [NSMutableArray array];
        NSMutableArray *ids = [NSMutableArray array];

        id space = [NSClassFromString(@"LSApplicationWorkspace") performSelector:@selector(defaultWorkspace)];
        NSArray *plugins = [space performSelector:@selector(installedPlugins)];
        NSMutableSet *list = [[NSMutableSet alloc] init];
        for (id plugin in plugins) {
            id bundle = [plugin performSelector:@selector(containingBundle)];
            if (bundle)
                [list addObject:bundle];
        }
        for (id plugin in list) {
            NSString *applicationType = [plugin performSelector:@selector(applicationType)];
            NSString *itemID = [plugin performSelector:@selector(itemID)];

            if (([applicationType isEqualToString:@"User"] || [applicationType isEqualToString:@"System"]) && itemID != nil && ![[NSString stringWithFormat:@"%@", itemID] isEqualToString: @"0"]) {
                
                NSString *bundleIdentifier = [plugin performSelector:@selector(bundleIdentifier)];
                NSString *applicationIdentifier = [plugin performSelector:@selector(applicationIdentifier)];
                NSString *itemName = [plugin performSelector:@selector(itemName)];
                
                NSLog(@"%@ %@ %@ %@", bundleIdentifier, applicationType, itemID, itemName);

                WorkspaceAppInfo *info = [[WorkspaceAppInfo alloc] init];
                info.name = itemName;
                info.bundleID = bundleIdentifier;
                info.applicationIdentifier = applicationIdentifier;
                info.applicationType = applicationType;
                info.itemID = [NSString stringWithFormat:@"%@", itemID];
                info.isOn = YES;
                
                [apps addObject:info];
                [ids addObject:[NSString stringWithFormat:@"%@", itemID]];
            }
            
        }
        
        [self getInfoWithItemID:[ids componentsJoinedByString:@","] completedHandler:^(NSArray *infos) {

            for (NSDictionary *dic in infos) {
                NSString *bundleId = dic[@"bundleId"];
                NSString *iconUrl = dic[@"artworkUrl60"];
                
                for (WorkspaceAppInfo *app in apps) {
                    
                    if ([app.bundleID isEqualToString:bundleId]) {
                        app.iconUrl = iconUrl;
                        break;
                    }
                }
            }
            
            // TODO: 是否有图标
            NSMutableArray *temp = [NSMutableArray array];
            for (WorkspaceAppInfo *app in apps) {
                if (app.iconUrl.length > 0) {
                    [temp addObject:app];
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                block(temp);
            });
            
        }];
    });

}

+ (void)getInfoWithItemID:(NSString *)itemID completedHandler:(void(^)(NSArray *infos))completedHandler {
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"https://itunes.apple.com/lookup?id=%@", itemID];
    NSString *countryCode = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    if (countryCode) {
        [urlString appendFormat:@"&country=%@", countryCode];
    }
    NSURL *appURL = [NSURL URLWithString: urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:appURL cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30.f];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil && data != nil) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            if (completedHandler) {
                NSArray *array = dict[@"results"];
                if (array == nil || ![array isKindOfClass:NSArray.class]) {
                    array = @[];
                }
                completedHandler(array);
            }
        } else {
            if (completedHandler) {
                completedHandler(@[]);
            }
        }
    }];
    [task resume];
}

@end
