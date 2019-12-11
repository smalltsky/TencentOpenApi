//
//  ExtraServiceSettingViewController.m
//  sdkDemo
//
//  Created by rockeyyan on 2019/8/23.
//  Copyright © 2019年 qqconnect. All rights reserved.
//

#import "ExtraServiceSettingViewController.h"
#import "sdkCall.h"
#import "QQAPIShareEntry.h"

#define SDK_INVISIBLE_CHAR  @"\u200B"
#define kTagServiceId 10300
#define kTagOpenId    10301
#define kTagToUin     10302

#pragma mark - ExServiceCellModel
@interface ExServiceCellModel : NSObject
@property (nonatomic, assign) int cellTag;
@property (nonatomic, copy) NSString *cellKey;
@property (nonatomic, copy) NSString *cellValue;
+ (ExServiceCellModel *)createCellModelForTag:(int)tag key:(NSString *)key value:(NSString *)value;
@end

@implementation ExServiceCellModel
+ (ExServiceCellModel *)createCellModelForTag:(int)tag key:(NSString *)key value:(NSString *)value
{
    ExServiceCellModel *resultModel = [ExServiceCellModel new];
    resultModel.cellTag = tag;
    resultModel.cellKey = key;
    resultModel.cellValue = value;
    return resultModel;
}
@end

#pragma mark - ExServiceCellView
@protocol ExServiceCellDelegate <NSObject>
@optional
- (void)ExServiceTextField:(NSString*)textFieldText cellTag:(int)cellTag;
@end

@interface ExServiceCellView : UIView <UITextFieldDelegate>
{
    id _cellInfo;
    UILabel *_titleLabel;
    UITextField *_editTextfield;
}

@property (nonatomic, weak) id<ExServiceCellDelegate> delegate;

- (void)loadCellWithModel:(id)cellInfo;
@end

@implementation ExServiceCellView
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        CGFloat cellWidth = self.frame.size.width;
        CGFloat cellHeight = self.frame.size.height;
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, (cellHeight-13)/2, 60, 13)];
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12.f];
        [self addSubview:_titleLabel];
        
        _editTextfield = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_titleLabel.frame)+2.f, 0, cellWidth-CGRectGetMaxX(_titleLabel.frame)-2.f, cellHeight)];
        _editTextfield.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.f];
        _editTextfield.layer.borderWidth = 0.35f;
        _editTextfield.layer.borderColor = [UIColor grayColor].CGColor;
        _editTextfield.delegate = self;
        [self addSubview:_editTextfield];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:_editTextfield];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadCellWithModel:(id)cellInfo {
    if (cellInfo == nil || ![cellInfo isKindOfClass:[ExServiceCellModel class]]) {
        return;
    }
    
    _cellInfo = cellInfo;
    ExServiceCellModel *cellModel = (ExServiceCellModel*)cellInfo;
    _titleLabel.text = cellModel.cellKey;
    _editTextfield.text = cellModel.cellValue;
    [self setNeedsLayout];
}

- (BOOL)setBecomeFirstResponder
{
    return [_editTextfield becomeFirstResponder];
}

- (BOOL)setResignFirstResponder
{
    return [_editTextfield resignFirstResponder];
}

#pragma mark -- UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    _editTextfield.returnKeyType = UIReturnKeyDone;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [self setResignFirstResponder];
}

- (void)textFieldTextDidChange:(NSNotification *)notification
{
    _editTextfield.text = ((UITextField*)notification.object).text;
    if ([_delegate respondsToSelector:@selector(ExServiceTextField:cellTag:)]) {
        [_delegate ExServiceTextField:[_editTextfield.text stringByReplacingOccurrencesOfString:SDK_INVISIBLE_CHAR withString:@""]
                              cellTag:((ExServiceCellModel*)_cellInfo).cellTag];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    _editTextfield.text = textField.text;
    if ([_delegate respondsToSelector:@selector(ExServiceTextField:cellTag:)]) {
        [_delegate ExServiceTextField:[_editTextfield.text stringByReplacingOccurrencesOfString:SDK_INVISIBLE_CHAR withString:@""]
                              cellTag:((ExServiceCellModel*)_cellInfo).cellTag];
    }
}

@end

#pragma mark - ExtraServiceSettingViewController
@interface ExtraServiceSettingViewController () <UITableViewDelegate, UITableViewDataSource, ExServiceCellDelegate>
{
    NSMutableArray *_dataSource;
    UITableView *_tableView;
    
    NSString *_serviceId;
    NSString *_openId;
    NSString *_toUin;
    UIButton *_confirmBtn;
}
@end

@implementation ExtraServiceSettingViewController

- (instancetype)init
{
    if (self = [super init]) {
        _serviceId = @"18";
        _openId = [sdkCall getinstance].oauth.openId;
        _toUin = @"";
        _dataSource = [NSMutableArray arrayWithCapacity:0];
        
        ExServiceCellModel *serviceId = [ExServiceCellModel createCellModelForTag:kTagServiceId key:@"ServiceID: " value:_serviceId];
        [_dataSource addObject:serviceId];
        ExServiceCellModel *openId = [ExServiceCellModel createCellModelForTag:kTagOpenId key:@"OpenID: " value:_openId];
        [_dataSource addObject:openId];
        ExServiceCellModel *friUin = [ExServiceCellModel createCellModelForTag:kTagToUin key:@"对方QQ号: " value:_toUin];
        [_dataSource addObject:friUin];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"扩展服务";
    self.view.backgroundColor = [UIColor whiteColor];
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.scrollEnabled = NO;
    _tableView.contentInset = UIEdgeInsetsMake(64+34, 0, 0, 0);
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.estimatedRowHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    if (@available(iOS 11.0, *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [self.view addSubview:_tableView];
    
    _confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _confirmBtn.frame = CGRectMake((screenWidth-100)/2, 44*4, 100, 44);
    _confirmBtn.layer.cornerRadius = 6;
    _confirmBtn.layer.borderWidth = 0.8f;
    _confirmBtn.layer.borderColor = [UIColor grayColor].CGColor;
    _confirmBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
    [_confirmBtn setTitle:@"发送" forState:UIControlStateNormal];
    [_confirmBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_confirmBtn addTarget:self action:@selector(clickConfirmSend:) forControlEvents:UIControlEventTouchUpInside];
    [_tableView addSubview:_confirmBtn];
    
    UILabel *tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(_confirmBtn.frame)+10, screenWidth-30, 100)];
    tipsLabel.textColor = [UIColor grayColor];
    tipsLabel.textAlignment = NSTextAlignmentCenter;
    tipsLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:13];
    tipsLabel.text = @"ServiceID为必填字段，支持的类型请参照官网文档说明。";
    [_tableView addSubview:tipsLabel];
}

- (void)ExServiceTextField:(NSString *)textFieldText cellTag:(int)cellTag
{
    if (cellTag == kTagServiceId) _serviceId = textFieldText;
    if (cellTag == kTagOpenId) _openId = textFieldText;
    if (cellTag == kTagToUin) _toUin = textFieldText;
}

- (void)clickConfirmSend:(id)sender
{
    NSDictionary *userInfo = @{@"openId":_openId?:@"", @"serviceId":_serviceId?:@"0", @"toUin":_toUin?:@""};
    [QQApiExtraServiceEntry StartCallApiExtraService:userInfo];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataSource count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= [_dataSource count])
        return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    ExServiceCellModel *cellModel = [_dataSource objectAtIndex:indexPath.row];
    
    NSString *cellIdentifier = @"SdkExtraServiceEditCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        UIView *cellView = [[ExServiceCellView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44)];
        cellView.tag = cellModel.cellTag;
        [cell.contentView addSubview:cellView];
    }
    
    UIView *viewId = [cell.contentView viewWithTag:cellModel.cellTag];
    [(ExServiceCellView *)viewId loadCellWithModel:cellModel];
    ((ExServiceCellView *)viewId).delegate = self;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
