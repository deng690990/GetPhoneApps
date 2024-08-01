//
//  WorkspaceTool.h
//  HHDemo
//
//  Created by Tim on 2024/7/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WorkspaceAppInfo : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *bundleID;
@property (nonatomic, strong) NSString *itemID;
@property (nonatomic, strong) NSString *applicationType;
@property (nonatomic, strong) NSString *applicationIdentifier;
@property (nonatomic, strong) NSString *iconUrl;
@property (nonatomic, strong) NSString *iconName;

@property (nonatomic, assign) BOOL isOn;

@end

typedef void (^WorkspaceToolBlock)(NSArray<WorkspaceAppInfo *> *appInfos);

@interface WorkspaceTool : NSObject

+ (void)getApplications:(WorkspaceToolBlock)block;

@end

NS_ASSUME_NONNULL_END
