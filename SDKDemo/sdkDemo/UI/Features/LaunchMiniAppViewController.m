//
//  LaunchMiniAppViewController.m
//  sdkDemo
//
//  Created by cocozzhang on 2019/9/18.
//  Copyright © 2019 qqconnect. All rights reserved.
//

#import "LaunchMiniAppViewController.h"
#import <TencentOpenAPI/QQApiInterfaceObject.h>
#if BUILD_QQAPIDEMO
#import "TencentOpenAPI/QQApiInterface.h"
#endif
#import "QQAPIShareEntry.h"

@interface LaunchMiniAppViewController ()
@property (nonatomic, strong) NSString *binding_miniAppId;
@property (nonatomic, strong) NSString *binding_miniPath;
@property (nonatomic, strong) NSString *binding_miniType;
@end

@implementation LaunchMiniAppViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)onLaunchMiniApp:(QElement *)sender {
    [self.view endEditing:YES];
    [self.root fetchValueUsingBindingsIntoObject:self];
    
    QQApiLaunchMiniProgramObject* launchMiniApp = [QQApiLaunchMiniProgramObject new];
    launchMiniApp.miniAppID = self.binding_miniAppId;
    launchMiniApp.miniPath = self.binding_miniPath;
    launchMiniApp.miniprogramType = [self.binding_miniType integerValue];
    
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:launchMiniApp];
    QQApiSendResultCode ret = [QQApiInterface sendReq:req];
    [QQApiShareEntry handleSendResult:ret];
}

@end
