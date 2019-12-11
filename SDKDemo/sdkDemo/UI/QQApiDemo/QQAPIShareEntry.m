//
//  QQApiShareEntryControllerViewController.m
//  sdkDemo
//
//  Created by JeaminW on 13-7-28.
//  Copyright (c) 2013年 xiaolongzhang. All rights reserved.
//

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import "QQAPIShareEntry.h"
#import "QuickDialogController.h"
#import "QRootElement.h"
#import "QBooleanElement.h"
#import <objc/runtime.h>

#import "sdkDemoAppDelegate.h"
#import "sdkCall.h"
#import "NSData+HexAdditions.h"

typedef void (^verifyResultBlock)(NSURLResponse *response, NSDictionary *result);

#if BUILD_QQAPIDEMO
#import "TencentOpenAPI/QQApiInterface.h"
#endif
#if !QQ_OPEN_SDK_LITE
#import "TencentOpenAPI/QQApiInterface+Private.h"
#import "TencentOpenAPI/QQApiInterfaceObject+Private.h"
#endif

#define SDK_TEST_IMAGE_FILE_NAME             @"/test"  //为了测试多种图片类型的分享流程，这里需要在应用目录下放置不同类型图片

@implementation QQApiShareEntry

+ (UIViewController *)EntryController
{
#if QQ_OPEN_SDK_LITE
    UIViewController *QDialog = [QuickDialogController controllerForRoot:[QRootElement rootForJSON:@"QQAPIDemo_lite" withObject:nil]];
#else
    UIViewController *QDialog = [QuickDialogController controllerForRoot:[QRootElement rootForJSON:@"QQAPIDemo" withObject:nil]];
#endif
    return QDialog;
}

+ (UIViewController *)QQqunEntryController {
    UIViewController *QDialog = [QuickDialogController controllerForRoot:[QRootElement rootForJSON:@"QQAPIQQqunDemo" withObject:nil]];
    return QDialog;
}

+ (BOOL)isRequestFromQQ {
    id<UIApplicationDelegate> appDelegate = [[UIApplication sharedApplication] delegate];
    if ([appDelegate isKindOfClass:sdkDemoAppDelegate.class]) {
        return ((sdkDemoAppDelegate*)appDelegate).isRequestFromQQ;
    }
    return NO;
}

#if BUILD_QQAPIDEMO
#pragma mark - QQApiInterfaceDelegate
+ (void)onReq:(QQBaseReq *)req
{
    switch (req.type)
    {
        case EGETMESSAGEFROMQQREQTYPE:      // 手Q -> 第三方应用，请求第三方应用向手Q发送消息
        {
            id<UIApplicationDelegate> appDelegate = [[UIApplication sharedApplication] delegate];
            if ([appDelegate isKindOfClass:sdkDemoAppDelegate.class]) {
                ((sdkDemoAppDelegate*)appDelegate).isRequestFromQQ = YES;
            }
            break;
        }
        default:
        {
            break;
        }
    }
}

+ (void)onResp:(QQBaseResp *)resp
{
    switch (resp.type)
    {
        case ESENDMESSAGETOQQRESPTYPE:
        {
            SendMessageToQQResp* sendReq = (SendMessageToQQResp*)resp;
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:sendReq.result message:sendReq.errorDescription delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            break;
        }
        default:
        {
            break;
        }
    }
}
#endif
+ (void)handleSendResult:(QQApiSendResultCode)sendResult
{
    switch (sendResult)
    {
        case EQQAPISENDSUCESS:
            break;
        default: {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"发送失败" message:[self showAlert:sendResult] delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
    }
}

+ (NSString*)showAlert:(QQApiSendResultCode)sendResult {
    switch (sendResult) {
        case EQQAPIAPPNOTREGISTED:
            return @"App未注册";
        case EQQAPIMESSAGECONTENTINVALID:
        case EQQAPIMESSAGECONTENTNULL:
        case EQQAPIMESSAGETYPEINVALID:
            return @"发送参数错误";
        case EQQAPIQQNOTINSTALLED:
            return @"未安装手Q";
        case EQQAPIQQNOTSUPPORTAPI:
            return @"手Q API接口不支持";
//        case EQQAPISENDFAILD:
//            return @"发送失败";
        case EQQAPIQZONENOTSUPPORTTEXT:
            return @"空间分享不支持QQApiTextObject，请使用QQApiImageArrayForQZoneObject分享";
        case EQQAPIQZONENOTSUPPORTIMAGE:
            return @"空间分享不支持QQApiImageObject，请使用QQApiImageArrayForQZoneObject分享";
        case EQQAPIVERSIONNEEDUPDATE:
            return @"当前QQ版本太低，需要更新";
        case ETIMAPIVERSIONNEEDUPDATE:
            return @"当前TIM版本太低，需要更新";
        case EQQAPITIMNOTINSTALLED:
            return @"未安装TIM";
        case EQQAPITIMNOTSUPPORTAPI:
            return @"TIM API接口不支持";
        case EQQAPISHAREDESTUNKNOWN:
            return @"未指定分享到QQ或TIM";
        case EQQAPIMESSAGE_MINI_CONTENTNULL:
            return @"小程序必填参数为空";
        case EQQAPI_INCOMING_PARAM_ERROR:
            return @"外部传参错误";
        case EQQAPI_THIRD_APP_GROUP_ERROR_APP_NOT_AUTHORIZIED:
            return @"App未获得授权";
        case EQQAPI_THIRD_APP_GROUP_ERROR_CGI_FAILED:
            return @"CGI请求失败";
        case EQQAPI_THIRD_APP_GROUP_ERROR_HAS_BINDED:
            return @"该组织已经绑定群聊";
        case EQQAPI_THIRD_APP_GROUP_ERROR_NOT_BINDED:
            return @"该组织尚未绑定群聊";
        case EQQAPISENDSUCESS:
            return nil;
        default:
            return [NSString stringWithFormat:@"Error Code:%ld，具体原因见打印", (long)sendResult];
    }
}
@end


@interface QQAPIDemoCommonController : QuickDialogController

@property (nonatomic, strong) NSString *binding_title;
@property (nonatomic, strong) NSString *binding_text;
@property (nonatomic, strong) NSString *binding_description;
@property (nonatomic, strong) NSString *binding_url;
@property (nonatomic, strong) UIImage *binding_previewImage;
@property (nonatomic, strong) NSString *binding_previewImageUrl;
@property (nonatomic, strong) NSString *binding_webpImageUrl;
@property (nonatomic, strong) NSString *binding_streamUrl;
@property (nonatomic, strong) NSString *binding_openID;
@property (nonatomic, strong) NSString *binding_subID;
@property (nonatomic, strong) NSString *binding_remark;

@property (nonatomic, strong) NSString *binding_ownerSignature;
@property (nonatomic, strong) NSString *binding_GameSectionID;
@property (nonatomic, strong) NSString *binding_GroupID;
@property (nonatomic, strong) NSString *binding_GroupKey;
@property (nonatomic, strong) NSString *binding_imageCount;
@property (nonatomic, strong) NSString *binding_bid;
@property (nonatomic, strong) NSString *binding_groupTribeName;

@property (nonatomic, strong) NSString *binding_appkey;

@property (nonatomic, strong) NSString *tenpayID;
@property (nonatomic, strong) NSString *tenpayAppInfo;
@property (nonatomic, strong) UIControl *qrcodePanel;
@property (nonatomic, strong) UIImageView *qrcodeImgView;

@property (nonatomic, strong) NSArray *imageAssetsForQZone;
@property (nonatomic, strong) NSURL *videoAssetForQZone;

// WPA
@property (nonatomic, strong) NSString *binding_uin;

@property (nonatomic, strong) QQApiObject *qqApiObject;
@property (nonatomic, strong) ArkObject *arkObject;

@property (nonatomic, assign) BOOL webpFlag;

- (void)doOpenApiExtraService:(NSDictionary *)userInfo;

@end

@implementation QQAPIDemoCommonController

- (id)init
{
    if (self = [super init])
    {
        self.webpFlag = NO;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self.root.object isKindOfClass:[NSDictionary class]])
    {
        NSString *jsonConfig = self.root.object[@"jsonConfig"];
        if ([jsonConfig isKindOfClass:[NSString class]])
        {
            self.root = [QRootElement rootForJSON:jsonConfig withObject:nil];
        }
    }
    
    CGRect frame = [[self view] bounds];
    self.qrcodePanel = [[UIControl alloc] initWithFrame:frame];
    self.qrcodePanel.hidden = YES;
    self.qrcodePanel.backgroundColor = [UIColor colorWithWhite:0.9 alpha:0.9];
    [self.qrcodePanel addTarget:self action:@selector(onQRCodePanelClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.qrcodePanel];
    
    CGRect panelFrame = [self.qrcodePanel bounds];
    CGFloat minSize = MIN(panelFrame.size.width, panelFrame.size.height) * 0.9f;
    self.qrcodeImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, minSize, minSize)];
    self.qrcodeImgView.center = CGPointMake(CGRectGetMidX(panelFrame), CGRectGetMidY(panelFrame));
    [self.qrcodePanel addSubview:self.qrcodeImgView];
    
    if ([[self.root key] isEqualToString:@"QQAPIDemo"])
    {
        [[self currentNavContext] removeAllObjects];
    }
}

- (NSMutableDictionary *)currentNavContext
{
    UINavigationController *navCtrl = [self navigationController];
    NSMutableDictionary *context = objc_getAssociatedObject(navCtrl, (__bridge void *)(@"currentNavContext"));
    if (nil == context)
    {
        context = [NSMutableDictionary dictionaryWithCapacity:3];
        objc_setAssociatedObject(navCtrl, (__bridge void *)(@"currentNavContext"), context, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return context;
}

- (void)onSwitchCFlag:(QElement *)sender
{
    if ([sender isKindOfClass:[QBooleanElement class]])
    {
        QBooleanElement *boolElem = (QBooleanElement *)sender;
        NSString *flagKey = boolElem.key;
        uint32_t flagValue = [boolElem.object[@"flagValue"] unsignedIntValue] * (!![boolElem boolValue]);
        [[self currentNavContext] setObject:[NSNumber numberWithUnsignedInt:flagValue] forKey:flagKey];

        NSLog(@"%@",[self currentNavContext]);
    }
}

- (uint64_t)shareControlFlags
{
    NSDictionary *context = [self currentNavContext];
    __block uint64_t cflag = 0;
    [context enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSNumber class]] &&
            [key isKindOfClass:[NSString class]] &&
            [key hasPrefix:@"kQQAPICtrlFlag"])
        {
            cflag |= [obj unsignedIntValue];
        }
    }];
    
    return cflag;
}

- (ShareDestType)getShareType
{
    BOOL flag = [[[NSUserDefaults standardUserDefaults] objectForKey:@"sdkSwitchFlag"] boolValue];
    return flag? ShareDestTypeTIM :ShareDestTypeQQ;
}

#if BUILD_QQAPIDEMO
- (void)onShowShareSubMenu:(QElement *)sender
{
    NSArray<NSString*>* entryList = @[@"inputArkJson", @"inputMiniAppid", @"inputMiniPath", @"inputMiniWebUrl", @"inputMiniType"];
    
    for (NSString* key in entryList) {
        QEntryElement *entry  = (QEntryElement *) [self.root elementWithKey:key];
        if(entry.key && entry.textValue){
            [[self currentNavContext] setObject:entry.textValue forKey:entry.key];
        }
    }
}

- (void)onShareText:(QElement *)sender
{
    [self.view endEditing:YES];
    [self.root fetchValueUsingBindingsIntoObject:self];
    
    QQApiTextObject *txtObj = [QQApiTextObject objectWithText:self.binding_text ? : @""];
    [txtObj setCflag:[self shareControlFlags]];
    if (txtObj.cflag & kQQAPICtrlFlagQZoneShareOnStart) {
        UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"提示" message:@"纯文本暂不支持直接分享到Qzone" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
        [msgbox show];
        return;
    }
    
    _qqApiObject = txtObj;
    QQApiSendResultCode ret = EQQAPISENDFAILD;
    QQBaseReq *req = [self getReq:txtObj thisTypeEnableArk:YES arkJson:nil];
    ret = [QQApiInterface sendReq:req];
    [self handleSendResult:ret];
}


- (void)onloadImage:(QElement *)sender
{
    [self.root fetchValueUsingBindingsIntoObject:self];
}


- (void)onShareImage:(QElement *)sender
{
    [self.view endEditing:YES];
    [self.root fetchValueUsingBindingsIntoObject:self];
    
    NSData *imgData = nil;
    NSData *preImgData = imgData;
    
    if (self.binding_previewImage)
    {
        NSData *selectedImgData = UIImageJPEGRepresentation(self.binding_previewImage, 1);
        NSData *selectedPreImgData = UIImageJPEGRepresentation(self.binding_previewImage, 0.20);//对于大于1M的图直接作为缩略图会过大，因此压缩系数要更小
        if (selectedImgData)
        {
            imgData = selectedImgData;
        }
        if (selectedPreImgData)
        {
            preImgData = selectedPreImgData;
        }
    } else {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *path = [documentsDirectory stringByAppendingString:SDK_TEST_IMAGE_FILE_NAME];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]){
            imgData = [NSData dataWithContentsOfFile:path];
        }else {
            NSString *imgPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"test.gif"];
            imgData = [NSData dataWithContentsOfFile:imgPath];
        }
    }
    
    QQApiImageObject *imgObj = [QQApiImageObject objectWithData:imgData
                                 previewImageData:preImgData
                                            title:self.binding_title ? : @""
                                      description:self.binding_description ? : @""];
    
    [imgObj setCflag:[self shareControlFlags]];
    QQApiSendResultCode ret = [QQApiInterface sendReq:[self getReq:imgObj thisTypeEnableArk:YES arkJson:nil]];
    [self handleSendResult:ret];
}

- (QQBaseReq *)getReq:(QQApiObject *)qqobj thisTypeEnableArk:(BOOL)thisTypeEnableArk arkJson:(NSString *)arkJson
{
    SendMessageToQQReq *req = nil;
    if( thisTypeEnableArk && ((qqobj.cflag & kQQAPICtrlFlagQQShareEnableArk) == kQQAPICtrlFlagQQShareEnableArk) ){
        NSString *json = ( (arkJson == nil) ? [self getDebugArkJson] : arkJson);
        ArkObject *arkObj = [ArkObject objectWithData:json qqApiObject:qqobj];
        _arkObject = arkObj;
        req = [SendMessageToQQReq reqWithArkContent:arkObj];
    }
    else if ((qqobj.cflag & kQQAPICtrlFlagQQShareEnableMiniProgram) == kQQAPICtrlFlagQQShareEnableMiniProgram) {
            QQApiMiniProgramObject *miniObj = [QQApiMiniProgramObject new];
            miniObj.qqApiObject = qqobj;
        NSDictionary *context = [self currentNavContext];
        __block NSString *inputMiniAppid = nil;
        __block NSString *inputMiniPath = nil;
        __block NSString *inputMiniWebUrl = nil;
        __block NSString *inputMiniType = nil;
        [context enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([obj isKindOfClass:[NSString class]] &&
                [key isKindOfClass:[NSString class]]) {
                if ([key isEqualToString:@"inputMiniAppid"]) {
                    inputMiniAppid = (NSString*)obj;
                } else if ([key isEqualToString:@"inputMiniPath"]) {
                    inputMiniPath = (NSString*)obj;
                } else if ([key isEqualToString:@"inputMiniWebUrl"]) {
                    inputMiniWebUrl = (NSString*)obj;
                } else if ([key isEqualToString:@"inputMiniType"]) {
                    inputMiniType = (NSString*)obj;
                }
            }
        }];
            miniObj.miniAppID = inputMiniAppid;
            miniObj.miniPath = inputMiniPath;
            miniObj.webpageUrl = inputMiniWebUrl;
            miniObj.miniprogramType = [inputMiniType integerValue];
            
            req = [SendMessageToQQReq reqWithMiniContent:miniObj];
    }
    else {
        _qqApiObject = qqobj;
        req = [SendMessageToQQReq reqWithContent:qqobj];
    }
    return req;
}

- (NSString *)getDebugArkJson
{
    
    NSDictionary *context = [self currentNavContext];
    __block NSString *arkJson = nil;
    [context enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSString class]] &&
            [key isKindOfClass:[NSString class]] &&
            [key isEqualToString:@"inputArkJson"])
        {
            arkJson = (NSString*)obj;
        }
    }];
    if (arkJson.length > 0) {
        return arkJson;
    }
    
    NSData *objectData = [@"{\"config\":{\"forward\":true,\"type\":\"card\",\"autosize\":true},\"prompt\":\"[应用]音乐\",\"app\":\"com.tencent.music\",\"ver\":\"1.0.1.26\",\"view\":\"Share\",\"meta\":{\"Share\":{\"musicId\":\"4893051\"}},\"desc\":\"音乐\"}" dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:objectData
                                                             options:NSJSONReadingMutableContainers // Pass 0 if you don't care about the readability of the generated string
                                                               error:nil];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];



    NSString *jsonString = @"";

    if (! jsonData)
    {
        NSLog(@"Got an error: %@", error);
    }else
    {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }

    jsonString = [jsonString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //去除掉首尾的空白字符和换行字符

    [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];

    return jsonString;
}

////网络单图分享
//- (void)onShareWebImage:(QElement *)sender
//{
//    [self.view endEditing:YES];
//    [self.root fetchValueUsingBindingsIntoObject:self];
//
//    QQApiWebImageObject *webImageObj = [QQApiWebImageObject
//                                         objectWithPreviewImageURL:[NSURL URLWithString:self.binding_previewImageUrl ? : @""]
//                                         title:self.binding_title ? : @""
//                                         description:self.binding_description ? : @""];
//    [webImageObj setCflag:[self shareControlFlags]];
//    _qqApiObject = webImageObj;
//    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:webImageObj];
//    QQApiSendResultCode ret = [QQApiInterface sendReq:req];
//    [self handleSendResult:ret];
//}

- (void)onShareMutileImage:(QElement *)sender
{
    uint64_t flag = [self shareControlFlags];
    if ((flag & kQQAPICtrlFlagQQShareFavorites) != kQQAPICtrlFlagQQShareFavorites) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"error" message:@"请你回到上一级目录，在顶头只打开'收藏'开关，再来测试。" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    [self.view endEditing:YES];
    [self.root fetchValueUsingBindingsIntoObject:self];
    
    NSString *imgPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"test.gif"];
    NSData *imgData = [NSData dataWithContentsOfFile:imgPath];
    NSData *preImgData = imgData;
    if (self.binding_previewImage)
    {
        NSData *selectedImgData = UIImageJPEGRepresentation(self.binding_previewImage, 0.85);
        NSData *selectedPreImgData = UIImageJPEGRepresentation(self.binding_previewImage, 0.20);
        if (selectedImgData)
        {
            imgData = selectedImgData;
        }
        if (selectedPreImgData)
        {
            preImgData = selectedPreImgData;
        }
    }
    
    NSString *imgPath2 = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"news.jpg"];
    NSData *imgData2 = [NSData dataWithContentsOfFile:imgPath2];
    NSString *imgPath3 = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"img.jpg"];
    NSData *imgData3 = [NSData dataWithContentsOfFile:imgPath3];
    
    NSArray* imgArray = [NSArray arrayWithObjects:imgData, imgData2, imgData3, nil]; //多个图片
    QQApiImageObject *imgObj =  [QQApiImageObject objectWithData:imgData
                     previewImageData:preImgData
                                title:self.binding_title ? : @""
                          description:self.binding_description ? : @""
                       imageDataArray:imgArray];
    
    //key_ImageDataArray;
    
    [imgObj setCflag:[self shareControlFlags]];
    _qqApiObject = imgObj;
    QQApiSendResultCode ret = [QQApiInterface sendReq:[self getReq:imgObj thisTypeEnableArk:YES arkJson:nil]];
    [self handleSendResult:ret];
}

- (void)onShareNewsLocal:(QElement *)sender
{
    [self.view endEditing:YES];
    [self.root fetchValueUsingBindingsIntoObject:self];
    
    NSString *previewPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"news.jpg"];
    NSData *previewData = [NSData dataWithContentsOfFile:previewPath];
    if (self.binding_previewImage)
    {
        NSData *selectedImgData = UIImageJPEGRepresentation(self.binding_previewImage, 0.20);
        if (selectedImgData)
        {
            previewData = selectedImgData;
        }
    }
    
    NSString *utf8String = [self.binding_url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    QQApiNewsObject *newsObj = [QQApiNewsObject objectWithURL:[NSURL URLWithString:utf8String ? : @""]
                                                        title:self.binding_title ? : @""
                                                  description:self.binding_description ? : @""
                                             previewImageData:previewData];
    [newsObj setCflag:[self shareControlFlags]];
    _qqApiObject = newsObj;
    QQApiSendResultCode ret = [QQApiInterface sendReq:[self getReq:newsObj thisTypeEnableArk:YES arkJson:nil]];
    [self handleSendResult:ret];
}

- (void)onShareNewsWeb:(QElement *)sender
{
    [self.view endEditing:YES];
    [self.root fetchValueUsingBindingsIntoObject:self];
    
    NSString *utf8String = [self.binding_url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    QQApiNewsObject *newsObj = nil;
    if (self.webpFlag) {
        newsObj = [QQApiNewsObject objectWithURL:[NSURL URLWithString:utf8String ? : @""]
                                                            title:self.binding_title ? : @""
                                                      description:self.binding_description ? : @""
                                                  previewImageURL:[NSURL URLWithString:self.binding_webpImageUrl ? : @""]];
    }
    else {
        newsObj = [QQApiNewsObject objectWithURL:[NSURL URLWithString:utf8String ? : @""]
                                               title:self.binding_title ? : @""
                                         description:self.binding_description ? : @""
                                     previewImageURL:[NSURL URLWithString:self.binding_previewImageUrl ? : @""]];
    }
    [newsObj setCflag:[self shareControlFlags]];
    _qqApiObject = newsObj;
    QQApiSendResultCode ret = [QQApiInterface sendReq:[self getReq:newsObj thisTypeEnableArk:YES arkJson:nil]];
    [self handleSendResult:ret];
}

- (void)onSwitchWebpFlag:(QElement *)sender {
    QBooleanElement *boolElem = (QBooleanElement *)sender;
    uint32_t flagValue = [boolElem.object[@"flagValue"] unsignedIntValue] * (!![boolElem boolValue]);
    self.webpFlag = flagValue > 0 ? YES : NO;
}

- (void)onShareAudio:(QElement *)sender
{
    [self.view endEditing:YES];
    [self.root fetchValueUsingBindingsIntoObject:self];
    
    if (self.binding_streamUrl == nil || [self.binding_streamUrl length] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"error" message:@"请输入streamUrl" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
        alertView.tag = 0x110;
        [alertView show];
        
        return;
    }
    
    NSData *previewData = nil;
    
    NSString *utf8String = [self.binding_url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
    QQApiAudioObject* audioObj = [QQApiAudioObject objectWithURL:[NSURL URLWithString:utf8String ? : @""] title:self.binding_title ? : @"" description:self.binding_description ? : @"" previewImageData:previewData];
    
    utf8String = [self.binding_previewImageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [audioObj setPreviewImageURL:[NSURL URLWithString: utf8String? : @""]];
    utf8String = [self.binding_streamUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [audioObj setFlashURL:[NSURL URLWithString:utf8String ? : @""]];
    [audioObj setCflag:[self shareControlFlags]];
    _qqApiObject = audioObj;
    QQApiSendResultCode ret = [QQApiInterface sendReq:[self getReq:audioObj thisTypeEnableArk:YES arkJson:nil]];
    [self handleSendResult:ret];
}

-(void)onShareLocalFile:(QElement*)sender
{
    [self.view endEditing:YES];
    [self.root fetchValueUsingBindingsIntoObject:self];
    
    NSString *filePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"test.txt"];
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    
    QQApiFileObject *fileObj = [QQApiFileObject objectWithData:fileData
                                               previewImageData:nil
                                                          title:self.binding_title ? : @""
                                                    description:self.binding_description ? : @""];
    
    if (self.binding_description != nil && ![self.binding_description isEqualToString:@""])
    {
        fileObj.fileName = self.binding_description;
    }
    else
    {
        fileObj.fileName = @"test.txt";
    }
    
    [fileObj setCflag:[self shareControlFlags]];
    _qqApiObject = fileObj;
    QQApiSendResultCode ret = [QQApiInterface sendReq:[self getReq:fileObj thisTypeEnableArk:YES arkJson:nil]];
    [self handleSendResult:ret];

}

- (void)onShareVideo:(QElement *)sender
{
    [self.view endEditing:YES];
    [self.root fetchValueUsingBindingsIntoObject:self];

    NSString *previewPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"video.jpg"];
    NSData* previewData = [NSData dataWithContentsOfFile:previewPath];
    if (self.binding_previewImage)
    {
        NSData *selectedImgData = UIImageJPEGRepresentation(self.binding_previewImage, 0.20);
        if (selectedImgData)
        {
            previewData = selectedImgData;
        }
    }
    
    NSString *utf8String = [self.binding_url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    QQApiVideoObject *videoObj = [QQApiVideoObject objectWithURL:[NSURL URLWithString:utf8String ? : @""]
                                                           title:self.binding_title ? : @""
                                                     description:self.binding_description ? : @""
                                                previewImageData:previewData];
    
    
    utf8String = [self.binding_streamUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [videoObj setFlashURL:[NSURL URLWithString:utf8String ? : @""]];
    [videoObj setCflag:[self shareControlFlags]];
    _qqApiObject = videoObj;
    QQApiSendResultCode ret = [QQApiInterface sendReq:[self getReq:videoObj thisTypeEnableArk:YES arkJson:nil]];
    [self handleSendResult:ret];
}
#if OPEN_API_ADD_FRIEND
- (void)onAddOpenFriend:(QElement *)sender {
    [self.view endEditing:YES];
    [self.root fetchValueUsingBindingsIntoObject:self];
    
    QQApiAddFriendObject *object = [[QQApiAddFriendObject alloc] initWithOpenID:self.binding_openID];
    object.description = self.binding_description;
    object.subID = self.binding_subID;
    object.remark = self.binding_remark;
    object.shareDestType = [self getShareType];
    SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:object];
    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    [self handleSendResult:sent];
}
#endif
#if OPEN_API_UNBIND_GROUP
#pragma mark 第三方app新的解绑群
- (void)thirdAppUnbindGroup:(QElement *)sender
{
    [self.view endEditing:YES];
    [self.root fetchValueUsingBindingsIntoObject:self];
    
    if ([[sdkCall getinstance].oauth.openId length] == 0)
    {
        UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"需要先登录" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
        [msgbox show];
        return;
    }
    
    NSString* appId = [sdkCall getinstance].oauth.appId;
    NSDictionary *mDic = @{@"access_token":[sdkCall getinstance].oauth.accessToken,
                           @"openid":[sdkCall getinstance].oauth.openId,
                           @"pay_token":[sdkCall getinstance].oauth.passData[@"pay_token"],
                           @"pfkey":[sdkCall getinstance].oauth.passData[@"pfkey"]
                           };
    NSString* url = [NSString stringWithFormat:@"https://openmobile.qq.com/cgi-bin/qunopensdk/unbind?appid=%@&orgid=%@", appId,self.binding_GroupID];
    url = [self serializeURL:url params:mDic];
    
    NSMutableURLRequest* request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                          cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                      timeoutInterval:30];
    [request setValue:@"TencentConnect" forHTTPHeaderField:@"User-Agent"];
    [request setHTTPMethod:@"GET"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse * __nullable response, NSData * __nullable data, NSError * __nullable connectionError) {
        
        //4.解析服务器返回的数据
        NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
           [[[UIAlertView alloc] initWithTitle:nil message:str delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        });
    }];
}
#endif //#if OPEN_API_UNBIND_GROUP
- (NSDictionary *)jasonValueWithStringData:(NSData *)data
{
    if (nil == data)
    {
        return nil;
    }

    NSError * error = nil;
    id jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (!jsonDict)
    {
        NSLog(@"JSONValue errcode = %ld, msg = %@", (long)error.code, error.description);
    }
    return jsonDict;
}

- (NSString*)serializeURL:(NSString *)baseUrl
                   params:(NSDictionary *)params {
    
    NSURL* parsedURL = [NSURL URLWithString:baseUrl];
    NSString* queryPrefix = parsedURL.query ? @"&" : @"?";
    
    NSMutableArray* pairs = [NSMutableArray array];
    for (NSString* key in [params keyEnumerator]) {
        NSString* escaped_value = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                      NULL, /* allocator */
                                                                                      (CFStringRef)[params objectForKey:key],
                                                                                      NULL, /* charactersToLeaveUnescaped */
                                                                                      (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                      kCFStringEncodingUTF8);
        
        [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, escaped_value]];
    }
    NSString* query = [pairs componentsJoinedByString:@"&"];
    
    return [NSString stringWithFormat:@"%@%@%@", baseUrl, queryPrefix, query];
}

#if OPNE_API_BIND_GROUP
#pragma mark 第三方app新的绑群
- (void)thirdAppBindGroup:(QElement *)sender
{
    [self.view endEditing:YES];
    [self.root fetchValueUsingBindingsIntoObject:self];
    
    if ([[sdkCall getinstance].oauth.openId length] == 0)
    {
        UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"需要先登录" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
        [msgbox show];
        return;
    }
    
    NSString *displayname = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    QQApiThirdAppBindGroupObject *object = [[QQApiThirdAppBindGroupObject alloc] initWithAccessToken:[sdkCall getinstance].oauth.accessToken payToken:[sdkCall getinstance].oauth.passData[@"pay_token"] pfkey:[sdkCall getinstance].oauth.passData[@"pfkey"] unionID:self.binding_GroupID appDisplayName:displayname];
    object.shareDestType = [self getShareType];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:object];
    
    [QQApiInterface sendThirdAppBindGroupReq:req resultBlock:^(NSDictionary *result) {
        NSLog(@"%s, %@", __func__, result);
        QQApiSendResultCode resultCode = [result[@"QQApiSendResultCode"] integerValue];
        [self handleSendResult:resultCode];
    }];
}
#endif //#if OPNE_API_BIND_GROUP

#if OPNE_API_GAME_BIND_GROUP
//计算签名+绑定
// 绑群
- (void)onGenerateSignatureBind:(QElement *)sender
{
    [self.view endEditing:YES];
    [self.root fetchValueUsingBindingsIntoObject:self];

    if ([[sdkCall getinstance].oauth.openId length] == 0)
    {
        UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"需要先登录" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
        [msgbox show];
        return;
    }

    NSString * orgStr = [NSString stringWithFormat:@"%@_%@_%@_%@_%@",
                         [sdkCall getinstance].oauth.openId,
                         [sdkCall getinstance].oauth.appId,
                         self.binding_appkey,
                         self.binding_GroupID,
                         self.binding_GameSectionID];
    NSData * data = [orgStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString * hexStr = [data md5];

    NSString * displayname = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    QQApiGameConsortiumBindingGroupObject *object = [[QQApiGameConsortiumBindingGroupObject alloc] initWithGameConsortium:hexStr
                                                                                                                  unionid:self.binding_GroupID
                                                                                                                   zoneID:self.binding_GameSectionID
                                                                                                           appDisplayName:displayname];
    object.shareDestType = [self getShareType];
    SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:object];
    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    [self handleSendResult:sent];

}
#endif //#if OPNE_API_GAME_BIND_GROUP

- (void)showErrorDialog:(NSString *)errorString {
    [[[UIAlertView alloc] initWithTitle:nil message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}
#if OPNE_API_GAME_BIND_GROUP
//绑定
- (void)onGameConsortiumBindingGroup:(QElement *)sender
{
    [self.view endEditing:YES];
    [self.root fetchValueUsingBindingsIntoObject:self];
    
    if ([[sdkCall getinstance].oauth.openId length] == 0) {
        UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"需要先登录" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
        [msgbox show];
        return;
    }
    
    NSString * displayname = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    QQApiGameConsortiumBindingGroupObject *object = [[QQApiGameConsortiumBindingGroupObject alloc] initWithGameConsortium:self.binding_ownerSignature
                                                                                                                  unionid:self.binding_GroupID
                                                                                                                   zoneID:self.binding_GameSectionID
                                                                                                           appDisplayName:displayname];
    object.shareDestType = [self getShareType];
    SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:object];
    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    [self handleSendResult:sent];
}
#endif //#if OPNE_API_GAME_BIND_GROUP
#if OPEN_API_JOIN_GROUP
#pragma mark 第三方app新的加群
- (void)thirdAppJoinGroup:(QElement *)sender
{
    [self.view endEditing:YES];
    [self.root fetchValueUsingBindingsIntoObject:self];
    
    if ([[sdkCall getinstance].oauth.openId length] == 0)
    {
        UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"需要先登录" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
        [msgbox show];
        return;
    }
    
    QQApiThirdAppJoinGroupObject *object = [QQApiThirdAppJoinGroupObject objectWithAccessToken:[sdkCall getinstance].oauth.accessToken payToken:[sdkCall getinstance].oauth.passData[@"pay_token"] pfkey:[sdkCall getinstance].oauth.passData[@"pfkey"] unionID:self.binding_GroupID];
    object.shareDestType = [self getShareType];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:object];
    // 校验是否已经绑群
    [QQApiInterface sendThirdAppJoinGroupReq:req resultBlock:^(NSDictionary *result) {
        NSLog(@"%s, %@", __func__, result);
        QQApiSendResultCode resultCode = [result[@"QQApiSendResultCode"] integerValue];
        [self handleSendResult:resultCode];
    }];
}
#endif // #ifndef OPEN_API_JOIN_GROUP

#if OPEN_API_JOIN_GROUP_OLD
// 加群
- (void)onJoinGroup:(QElement *)sender
{
    [self.view endEditing:YES];
    [self.root fetchValueUsingBindingsIntoObject:self];

    if (self.binding_GroupKey && [self.binding_GroupKey length] > 0)
    {
        //ret = [QQApi joinGroup:self.binding_GroupID key:self.binding_GroupKey];
        QQApiJoinGroupObject *object = [QQApiJoinGroupObject objectWithGroupInfo:self.binding_GroupID key:self.binding_GroupKey];
        object.shareDestType = [self getShareType];
        SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:object];
        QQApiSendResultCode sent = [QQApiInterface sendReq:req];
        [self handleSendResult:sent];

    }
}
#endif //#if OPEN_API_JOIN_GROUP_OLD

- (NSInteger)GetRandomNumber:(NSInteger)start to:(NSInteger)end
{
    return (NSInteger)(start + (arc4random() % (end - start + 1)));
}

- (void)handleSendResult:(QQApiSendResultCode)sendResult
{
    [QQApiShareEntry handleSendResult:sendResult];
}

#endif

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 0xAA)
    {
        SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:_qqApiObject];
        QQApiSendResultCode sent = 0;
        if (0 == buttonIndex)
        {
            sent = [QQApiInterface SendReqToQZone:req];
        }
        else if(1 == buttonIndex)
        {
            sent = [QQApiInterface sendReq:req];
        }
        [self handleSendResult:sent];
    }
}

/*
 * 目前已经支持的手Q扩展IM能力，即ServiceID值包括：
 * 18 - 打开聊天会话（手Q版本 >= 8.1.5）
 * 19 - 打开视频通话（手Q版本 >= 8.1.5）
 * 20  -打开语音通话（手Q版本 >= 8.1.5）
 */
- (void)doOpenApiExtraService:(NSDictionary *)userInfo
{
    if ([[sdkCall getinstance].oauth.openId length] == 0) {
        UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"需要先登录" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
        [msgbox show];
        return;
    }
    
    NSString *serviceId = [userInfo objectForKey:@"serviceId"];
    NSString *openId = [userInfo objectForKey:@"openId"];
    NSString *toUin = [userInfo objectForKey:@"toUin"];
    if ([serviceId length] == 0) {
        UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"需填写有效ServiceID" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
        [msgbox show];
        return;
    }
    
    QQApiExtraServiceObject *object = [[QQApiExtraServiceObject alloc] initWithOpenID:self.binding_openID serviceID:serviceId];
    object.openID = openId;
    object.toUin = toUin;
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:object];
    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    [self handleSendResult:sent];
}

@end

#pragma mark - ExtraService
@implementation QQApiExtraServiceEntry
+ (void)StartCallApiExtraService:(NSDictionary *)userInfo
{
    QQAPIDemoCommonController *contr = [QQAPIDemoCommonController new];
    [contr doOpenApiExtraService:userInfo];
}

@end
