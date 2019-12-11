//
//  QQAvatarSettingViewController.m
//  sdkDemo
//
//  Created by xianminxiao on 2019/2/15.
//  Copyright © 2019年 qqconnect. All rights reserved.
//

#import "QQAvatarSettingViewController.h"
#import "QBImagePickerController.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/QQApiInterfaceObject.h>
#import "UICommonDefine.h"

typedef NS_ENUM(NSInteger, ShareToQQAvatarType) {
    ShareToQQAvatar_Image,
    ShareToQQAvatar_Video,
};

@interface QQAvatarSettingViewController () <QBImagePickerControllerDelegate>
{
    NSData *_imageData;
    UIButton *_imageViewButton;
    ShareToQQAvatarType _shareType;
    NSURL *_videoURL;
    NSData *_videoData;
}

@property (nonatomic, retain) UIButton *imageViewButton;

@end

@implementation QQAvatarSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"设置QQ头像";
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(onClickConfirm:)];
    
    UIButton* btn = [self createButtonWithTitle:@"选择图片" action:@selector(onClickBtn:)];
    btn.tag = ShareToQQAvatar_Image;
    btn.frame = CGRectMake(20.0f, 120, self.view.bounds.size.width - 40.0f, 45);
    
    UIButton* btn2 = [self createButtonWithTitle:@"选择视频" action:@selector(onClickBtn:)];
    btn2.tag = ShareToQQAvatar_Video;
    btn2.frame = CGRectMake(20.0f, btn.bottom + 10, self.view.width - 40.0f, 45);
    
    _imageViewButton = [[UIButton alloc] initWithFrame:CGRectMake(btn.left, btn2.bottom+10.0f, self.view.width - btn.left*2, self.view.width - btn.left*2)];
    _imageViewButton.layer.cornerRadius = 7.2f;
    _imageViewButton.layer.masksToBounds = YES;
    _imageViewButton.contentMode = UIViewContentModeScaleAspectFit;
    _imageViewButton.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.1];
    [self.view addSubview:_imageViewButton];

}

- (UIButton*)createButtonWithTitle:(NSString*)title action:(SEL)seletor {
    UIButton *btn = [UIButton new];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:RGBColorC(0x000000) forState:UIControlStateNormal];
    [btn addTarget:self action:seletor forControlEvents:UIControlEventTouchUpInside];
    btn.layer.cornerRadius = 2;
    btn.layer.borderWidth = 0.5;
    btn.layer.borderColor = RGBColorC(0xdddddd).CGColor;
    [self.view addSubview:btn];
    return btn;
}

- (void)onClickConfirm:(id)sender {
    if (!_imageData && !_videoURL) {
        UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"请先选择图片or视频" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
        [msgbox show];
        return;
    }
    
    if (_shareType == ShareToQQAvatar_Image) {
        QQApiImageForQQAvatarObject *imgObj = [QQApiImageForQQAvatarObject objectWithData:_imageData
                                                                         previewImageData:nil
                                                                                    title:@""
                                                                              description:@""];
        
        SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:imgObj];
        QQApiSendResultCode sent = [QQApiInterface sendMessageToQQAvatarWithReq:req];
        [self handleSendResult:sent];
    } else if (_shareType == ShareToQQAvatar_Video) {
        QQApiVideoForQQAvatarObject *videoObj = [QQApiVideoForQQAvatarObject objectWithData:_videoData previewImageData:nil title:@"" description:@""];
        SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:videoObj];
        QQApiSendResultCode sent = [QQApiInterface sendMessageToQQAvatarWithReq:req];
        [self handleSendResult:sent];
    }
    
    
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)onClickBtn:(UIButton*)sender {
    QBImagePickerController *imgPicker = [[QBImagePickerController alloc] init];
    imgPicker.delegate = self;
    imgPicker.allowsMultipleSelection = NO;
    
    _shareType = sender.tag;
    if (_shareType == ShareToQQAvatar_Image) {
        imgPicker.filterType = QBImagePickerControllerFilterTypePhotos;
    } else if (_shareType == ShareToQQAvatar_Video) {
        imgPicker.filterType = QBImagePickerControllerFilterTypeVideos;
    }

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imgPicker];
    [self.navigationController presentViewController:navigationController animated:YES completion:NULL];
}

#pragma mark - QBImagePickerControllerDelegate

- (void)imagePickerController:(QBImagePickerController *)imagePickerController didSelectAsset:(ALAsset *)asset {
    UIImage *preImage = nil;
    
    ALAssetRepresentation *rep = [asset defaultRepresentation];
    Byte *buffer = (Byte*)malloc(rep.size);
    NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
    NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
    
    if (imagePickerController.filterType == QBImagePickerControllerFilterTypePhotos) {

        _imageData = [data copy];
        preImage = [UIImage imageWithData:data];
        
    } else if (imagePickerController.filterType == QBImagePickerControllerFilterTypeVideos) {
        _videoURL = [asset valueForProperty:ALAssetPropertyAssetURL];
        preImage = [UIImage imageWithCGImage:[asset aspectRatioThumbnail]];

        _videoData = [data copy];
    }
    [self.imageViewButton setImage:preImage forState:UIControlStateNormal];
    [imagePickerController dismissViewControllerAnimated:YES completion:nil];
}


- (void)imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController
{
    [imagePickerController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -

- (void)handleSendResult:(QQApiSendResultCode)sendResult
{
    switch (sendResult)
    {
        case EQQAPIAPPNOTREGISTED:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"App未注册" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPIMESSAGECONTENTINVALID:
        case EQQAPIMESSAGECONTENTNULL:
        case EQQAPIMESSAGETYPEINVALID:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"发送参数错误" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPIQQNOTINSTALLED:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"未安装手Q" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPITIMNOTINSTALLED:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"未安装TIM" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPIQQNOTSUPPORTAPI:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"API接口不支持" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPISENDFAILD:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"发送失败" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPIQZONENOTSUPPORTTEXT:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"空间分享不支持QQApiTextObject，请使用QQApiImageArrayForQZoneObject分享" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPIQZONENOTSUPPORTIMAGE:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"空间分享不支持QQApiImageObject，请使用QQApiImageArrayForQZoneObject分享" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPIVERSIONNEEDUPDATE:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"当前QQ版本太低，需要更新" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case ETIMAPIVERSIONNEEDUPDATE:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"当前TIM版本太低，需要更新" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        default:
        {
            break;
        }
    }
}

@end
