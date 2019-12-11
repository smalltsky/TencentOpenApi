//
//  FeaturesTableViewController.m
//  sdkDemo
//
//  Created by xianminxiao on 2019/4/22.
//  Copyright © 2019年 qqconnect. All rights reserved.
//

#import "FeaturesTableViewController.h"
#import "cellInfo.h"
#import "QQAvatarSettingViewController.h"
#import "ImageFacesShareToFaceCollectionViewController.h"
#import "ExtraServiceSettingViewController.h"

@interface FeaturesTableViewController ()

@end

@implementation FeaturesTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        NSMutableArray *cellQZone = [NSMutableArray array];
        [cellQZone addObject:[cellInfo info:@"设置QQ头像" target:self Sel:@selector(doQQAvatarSetting) viewController:nil]];
        [cellQZone addObject:[cellInfo info:@"组图分享到表情收藏" target:self Sel:@selector(doImageFacesShareToFaceCollection) viewController:nil]];
        [cellQZone addObject:[cellInfo info:@"手Q唤起小程序" target:self Sel:@selector(doLaunchMiniApp) viewController:nil]];
        [[super sectionName] addObject:@"手Q支持能力"];
        [[super sectionRow] addObject:cellQZone];
        
        NSMutableArray *cellExtraService = [NSMutableArray array];
        [cellExtraService addObject:[cellInfo info:@"扩展服务" target:self Sel:@selector(doExtraServiceHandle) viewController:nil]];
        [[super sectionName] addObject:@"手Q扩展服务能力"];
        [[super sectionRow] addObject:cellExtraService];
    }
    return self;
}

#pragma mark - QZONE RELATIVE
- (void)doQQAvatarSetting
{
    QQAvatarSettingViewController *ctr = [QQAvatarSettingViewController new];
    [self.navigationController pushViewController:ctr animated:YES];
}

- (void)doImageFacesShareToFaceCollection
{
    ImageFacesShareToFaceCollectionViewController *ctr = [ImageFacesShareToFaceCollectionViewController new];
    [self.navigationController pushViewController:ctr animated:YES];
}

- (void)doLaunchMiniApp {
    UIViewController* ctr = [QuickDialogController controllerForRoot:[QRootElement rootForJSON:@"QQAPI_LaunchMiniApp" withObject:nil]];
    [self.navigationController pushViewController:ctr animated:YES];
}

#pragma mark - ExtraService
- (void)doExtraServiceHandle
{
    ExtraServiceSettingViewController *ctr = [ExtraServiceSettingViewController new];
    [self.navigationController pushViewController:ctr animated:YES];
}

@end
