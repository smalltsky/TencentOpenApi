//
//  ImageFacesShareToFaceCollectionViewController.m
//  sdkDemo
//
//  Created by xianminxiao on 2019/4/22.
//  Copyright © 2019年 qqconnect. All rights reserved.
//

#import "ImageFacesShareToFaceCollectionViewController.h"
#import "QBImagePickerController.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/QQApiInterfaceObject.h>
#import "UICommonDefine.h"

@interface ImageFacesShareToFaceCollectionViewController () <QBImagePickerControllerDelegate>
{
    NSMutableArray *_imageViewButtonArray;
    NSArray *_imageAssets;
    
    NSInteger _imageViewButtonCount;
}

@property (nonatomic, retain) UIButton *imageViewButton;

@end

@implementation ImageFacesShareToFaceCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _imageViewButtonCount = 9;
    _imageViewButtonArray = [NSMutableArray arrayWithCapacity:_imageViewButtonCount];
    
    NSString *title = @"组图分享到表情收藏";
    NSString *btnTitle = @"选择组图";
    self.navigationItem.title = title;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(onClickConfirm:)];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(20.0f, 120, self.view.bounds.size.width - 40.0f, 45)];
    [btn setTitle:btnTitle forState:UIControlStateNormal];
    [btn setTitleColor:RGBColorC(0x000000) forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onClickBtn:) forControlEvents:UIControlEventTouchUpInside];
    btn.layer.cornerRadius = 2;
    btn.layer.borderWidth = 0.5;
    btn.layer.borderColor = RGBColorC(0xdddddd).CGColor;
    [self.view addSubview:btn];
    
    CGFloat space = 10.0f;
    CGFloat baseLeft = btn.frame.origin.x;
    CGFloat baseTop = btn.frame.origin.y+btn.frame.size.height+space;
    CGFloat imageViewButtonWidth = 80.0f;
    CGFloat imageViewButtonHeight = 80.0f;
    for (NSInteger index=0; index<9; index++)
    {
        NSInteger xNum = index%3;
        NSInteger yNum = index/3;
        CGFloat left = baseLeft + (imageViewButtonWidth + space)*xNum;
        CGFloat top  = baseTop +(imageViewButtonHeight + space)*yNum;
        UIButton * imageViewButton = [[UIButton alloc] initWithFrame:CGRectMake(left, top, imageViewButtonWidth, imageViewButtonHeight)];
        imageViewButton.contentMode = UIViewContentModeScaleAspectFill;
        imageViewButton.layer.cornerRadius = 7.2f;
        imageViewButton.layer.masksToBounds = YES;
        imageViewButton.contentMode = UIViewContentModeScaleAspectFill;
        imageViewButton.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.1];
        imageViewButton.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
        imageViewButton.hidden = YES;
        [self.view addSubview:imageViewButton];
        
        [_imageViewButtonArray addObject:imageViewButton];
        
    }
}

- (void)onClickConfirm:(id)sender
{
    if (!_imageAssets || _imageAssets.count > 9)
    {
        NSString* errorMessage = !_imageAssets ? @"请先选择图片" : @"图片超过9张！";
        UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
        [msgbox show];
        return;
    }
    
    QQApiImageArrayForFaceCollectionObject *img = [QQApiImageArrayForFaceCollectionObject objectWithimageDataArray:_imageAssets];
    SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:img];
    QQApiSendResultCode sent = [QQApiInterface sendMessageToFaceCollectionWithReq:req];
    
    NSMutableString* strErrorInfo = [NSMutableString stringWithString:@"错误"];
    NSUInteger allImageDataLength = 0;
    for (int index=0; index<img.imageDataArray.count; index++)
    {
        NSUInteger tmpLength = [img.imageDataArray[index] length];
        if (tmpLength > 1024*1024)
        {
            NSString* strError = [NSString stringWithFormat:@"，第%d张超1M", (index+1)];
            [strErrorInfo appendString:strError];
        }
        allImageDataLength += tmpLength;
    }
    if (allImageDataLength > 1024*1024*3)
    {
        [strErrorInfo appendString:@"，总共超过3M！"];
    }
    else
        [strErrorInfo appendString:@"。"];
    
    [self handleSendResult:sent strErrorInfo:strErrorInfo];
}

- (void)onClickBtn:(id)sender
{
    for (int i=0; i<_imageViewButtonArray.count; i++)
    {
        UIButton* imageViewButton = _imageViewButtonArray[i];
        imageViewButton.hidden= YES;
    }
    
    QBImagePickerController *imgPicker = [[QBImagePickerController alloc] init];
    imgPicker.delegate = self;
    imgPicker.allowsMultipleSelection = YES;
    imgPicker.maximumNumberOfSelection = 9;
    imgPicker.filterType = QBImagePickerControllerFilterTypePhotos;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imgPicker];
    [self.navigationController presentViewController:navigationController animated:YES completion:NULL];
}

#pragma mark - QBImagePickerControllerDelegate

- (void)imagePickerController:(QBImagePickerController *)imagePickerController didSelectAssets:(NSArray *)assets
{
    NSMutableArray *photoArray = [NSMutableArray array];
    
    NSInteger index = 0;
    for (ALAsset *asset in assets)
    {
        ALAssetRepresentation *rep = [asset defaultRepresentation];
        Byte *buffer = (Byte*)malloc(rep.size);
        NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
        NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];//this is NSData may be what you want
        [photoArray addObject:data];
        
        if (index>_imageViewButtonCount-1)
            index = _imageViewButtonCount-1;
        UIImage *preImage = [UIImage imageWithData:data];
        UIButton* imageViewButton = _imageViewButtonArray[index];
        [imageViewButton setImage:preImage forState:UIControlStateNormal];
        imageViewButton.hidden = NO;
        
        index++;
    }
    _imageAssets = [photoArray copy];
    [imagePickerController dismissViewControllerAnimated:YES completion:nil];
}


- (void)imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController
{
    [imagePickerController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -

- (void)handleSendResult:(QQApiSendResultCode)sendResult strErrorInfo:(NSString*)strErrorInfo
{
    switch (sendResult)
    {
        case EQQAPISENDSUCESS:
        {
            break;
        }
        default:
        {
            NSString* strMessage = @"错误，详细见QQApiSendResultCode定义";
            if (EQQAPIMESSAGECONTENTINVALID == sendResult)
            {
                strMessage = strErrorInfo;
            }
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:strMessage delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
    }
}


@end
