//
//  LoginViewController_iPhone.m
//  LetvIphoneClient
//
//  Created by 鹏飞 季 on 12-8-21.
//  Copyright (c) 2012年 乐视网. All rights reserved.
//
#import <LeTVMobileFoundation/LeTVMobileFoundation.h>
#ifndef LT_MERGE_FROM_IPAD_CLIENT
#import "LoginViewController_iPhone.h"
#import "RegisterViewController_iPhone.h"
#import <LetvMobileGuiKit/UserCenterBundle.h>
#import <LeTVRedPackageSDK/LeTVRedPackageSDK.h>
/*
#import "UserCenterViewController_iPhone.h"
#import "LTThirdPartyLoginTableViewCell.h"
#import "LTMovieDownloadViewController_iPhone.h"
#import "MyselfViewController_iPhone.h"
*/


//#import "LTUIButton.h"
//#import "UIButtonConstructor.h"
//#import "UINavigationController+Extend.h"
//#import "ExtensionUIImage.h"
#import "FindPasswordViewController_iPhone.h"
//#import "LTUserShowTip.h"
//#import "LTWebViewController_iPhone.h"
#import "AuditManager.h"

#define USER_ACCOUNT_TAG 101
#define PASSWORD_TAG 102
#define CustomHeight 480
@interface LoginViewController_iPhone ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate , UIScrollViewDelegate>
{
    UITextField *_editingTextField;
    UIScrollView *_contentScrollView;
    UIActivityIndicatorView * _indicatorView;
    BOOL _isKeyboardShow;
}
@property (nonatomic, strong) UIButton *registerButton;
@property (nonatomic, strong) LTUIButton *loginButton;
@property (nonatomic, strong) UIButton *forgetButton;

@property (nonatomic, strong) UIButton *qqLoginButton;
@property (nonatomic, strong) UIButton *sinaLoginButton;
@property (nonatomic, strong) UIButton *weixinLoginButton;
@property (nonatomic, strong) UIView *thirdLoginView;
@property (nonatomic, strong) UITableView *loginTableView;
@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) LTCommonTextField *userTextField;
@property (nonatomic, strong) LTCommonTextField *passwordTextField;

@property (nonatomic, strong) UITableView *relatedTableView;

@end

@implementation LoginViewController_iPhone

@synthesize deleage;

- (id)initWithEntranceType:(LoginEntranceType)_entranceType {
    if (self = [super init]) {
        _loginEntranceType = _entranceType;
        _isKeyboardShow = NO;
        return self;
    }
    
    return nil;
}

- (id)initWithLoginFinishBlock:(LTLoginFinishBlock)finishBlock
{
    self = [super init];
    if (self) {
        _finishBlock = finishBlock;
        _isKeyboardShow = NO;
    }
    return self;
}

//- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
//{
//    [scrollView setContentOffset:scrollView.contentOffset animated:NO];
//}

- (void)loadView {
    [super loadView];
    
    [self.navigationItem setCustomTitle:NSLocalizedString(@"登录", nil)];
    [self addBackLeftBarButtonItem];
    // [self addDefaultLeftBarButtonItem:@"" isNeedBack:YES];
    
    self.view.backgroundColor = kColor246;
    
    // ios5上从评论进入登陆页_contentScrollView的y值不对
    CGFloat contentScrollViewTop = 0;
    if (!LTAPI_IS_ALLOWED(7.0) && !self.parentViewController.tabBarController) {
        contentScrollViewTop = 43;
    }
    if (_loginEntranceType == eLoginEntranceTypeStar) {
        contentScrollViewTop = 0;
        if (!LTAPI_IS_ALLOWED(7.0)) {
            self.navigationController.navigationBar.translucent = NO;
        }
    }
    _contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, contentScrollViewTop, __MainScreen_Width, __MainScreen_Height - 20 -44)];
    _contentScrollView.backgroundColor = [UIColor clearColor];
    _contentScrollView.alwaysBounceVertical = YES;
    _contentScrollView.scrollEnabled = YES;
    _contentScrollView.delegate = self;
    [self.view addSubview:_contentScrollView];
    
    
    self.thirdLoginView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, __MainScreen_Width, 200)];
    self.thirdLoginView.backgroundColor = kColor246;
    //    [_contentScrollView addSubview:self.thirdLoginView];
    
    CGSize size = CGSizeMake(290, 37);
    CGFloat weixinButtonHeight = size.height;
    //监测未安装微信，或微信api不支持的时候，隐藏微信按钮
    if (![[LTShareEngineInterfaceObjc sharedEngine] shareEngineWeixinEnableShare]) {
        weixinButtonHeight = 0;
        [self.thirdLoginView setFrame:CGRectMake(0, 0, __MainScreen_Width, 200 - 37)];
        
    }
    
    self.weixinLoginButton = [[UIButton alloc] initWithFrame:CGRectMake((__MainScreen_Width - size.width)/2, 15, size.width, weixinButtonHeight)];
    self.weixinLoginButton.backgroundColor = [UIColor clearColor];
    [self.weixinLoginButton setImage:[UIImage UserCenterBundleImageName:NSLocalizedString(@"weixin_login", nil)] forState:UIControlStateNormal];
    [self.weixinLoginButton setImage:[UIImage UserCenterBundleImageName:NSLocalizedString(@"weixin_login_selected", nil)] forState:UIControlStateHighlighted];
    [self.weixinLoginButton addTarget:self action:@selector(weixinLoginButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.thirdLoginView addSubview:self.weixinLoginButton];
    
    self.qqLoginButton = [[LTUIButton alloc] initWithFrame:CGRectMake((__MainScreen_Width - size.width)/2, CGRectGetMaxY(self.weixinLoginButton.frame)+15, size.width, size.height)];
    self.qqLoginButton.backgroundColor = [UIColor clearColor];
    [self.qqLoginButton setImage:[UIImage UserCenterBundleImageName:NSLocalizedString(@"qqLogin", nil)] forState:UIControlStateNormal];
    [self.qqLoginButton setImage:[UIImage UserCenterBundleImageName:NSLocalizedString(@"qqLogin_selected", nil)] forState:UIControlStateHighlighted];
    [self.qqLoginButton addTarget:self action:@selector(qqLoginButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.thirdLoginView addSubview:self.qqLoginButton];
    
    self.sinaLoginButton = [[LTUIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.qqLoginButton.frame), CGRectGetMaxY(self.qqLoginButton.frame) + 15, size.width, size.height)];
    self.sinaLoginButton.backgroundColor = [UIColor clearColor];
    [self.sinaLoginButton setImage:[UIImage UserCenterBundleImageName:NSLocalizedString(@"sinaLogin", nil)] forState:UIControlStateNormal];
    [self.sinaLoginButton setImage:[UIImage UserCenterBundleImageName:NSLocalizedString(@"sinaLogin_selected", nil)] forState:UIControlStateHighlighted];
    [self.sinaLoginButton addTarget:self action:@selector(sinaLoginButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.thirdLoginView addSubview:self.sinaLoginButton];
    


    size = [NSLocalizedString(@"乐视帐号登录", nil) sizeWithFont:[UIFont systemFontOfSize:15]];
    UILabel *label = [UIButtonConstructor createLabelWithText:NSLocalizedString(@"乐视帐号登录", nil)
                                              backgroundColor:[UIColor clearColor]
                                                    textColor:RGBACOLOR(57, 57, 57, 1)
                                                textAlignment:NSTextAlignmentLeft
                                                         font:[UIFont systemFontOfSize:15]];
    label.frame = CGRectMake(15, CGRectGetMaxY(self.sinaLoginButton.frame)+15 , size.width, size.height);
    [self.thirdLoginView addSubview:label];
    
    self.loginTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.thirdLoginView.frame) , __MainScreen_Width, 185)];
    self.loginTableView.backgroundColor = [UIColor whiteColor];
    self.loginTableView.dataSource = self;
    self.loginTableView.delegate = self;
    self.loginTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.loginTableView.scrollEnabled = NO;
    //    [_contentScrollView addSubview:self.loginTableView];
    
    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.loginTableView.frame), __MainScreen_Width, CustomHeight * 88 / 320.0)];
    self.bottomView.backgroundColor = RGBACOLOR(246, 246, 246, 1);
    //    [_contentScrollView addSubview:self.bottomView];
    NSString *string = NSLocalizedString(@"登录可享受云播放记录、追剧提醒、极速", nil);
    size = [string sizeWithFont:[UIFont systemFontOfSize:15]];
    UILabel *bottomLabel = [UIButtonConstructor createLabelWithText:NSLocalizedString(@"登录可享受云播放记录、追剧提醒、极速\n缓存、多屏互动和1080P速递服务。", @"登录可享受云播放记录、追剧提醒、极速\n缓存、多屏互动和1080P速递服务。") backgroundColor:[UIColor clearColor] textColor:RGBACOLOR(161, 161, 161, 1) textAlignment:NSTextAlignmentLeft font:[UIFont systemFontOfSize:15]];
    bottomLabel.numberOfLines = 2;
    bottomLabel.frame = CGRectMake((__MainScreen_Width - size.width)/2, 13, size.width, size.height*2);
    
    [self.bottomView addSubview:bottomLabel];
    
    NSString *labelString = NSLocalizedString(@"如有疑问请拨打客服电话:", @"如有疑问请拨打客服电话:");
    CGSize size2 = [labelString sizeWithFont:[UIFont systemFontOfSize:15]];
    
    NSString *phoneString = @"10109000";
    if ([SettingManager isHK]) {
        phoneString = @"3956 6666";
    }
    CGSize size3 = [phoneString sizeWithFont:[UIFont systemFontOfSize:13]];
    
    UILabel *phoneLabel = [UIButtonConstructor createLabelWithText:NSLocalizedString(@"如有疑问请拨打客服电话:", @"如有疑问请拨打客服电话:") backgroundColor:[UIColor clearColor] textColor:RGBACOLOR(161, 161, 161, 1) textAlignment:NSTextAlignmentLeft font:[UIFont systemFontOfSize:15]];
    phoneLabel.frame = CGRectMake((__MainScreen_Width - size2.width -size3.width - 24 - 16)/2 - 4, 13+5+bottomLabel.frame.size.height, size2.width, size2.height);
    [self.bottomView addSubview:phoneLabel];
    
    UIButton *teleImageButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(phoneLabel.frame), phoneLabel.frame.origin.y-3, 24, 25)];
    [teleImageButton setImage:[UIImage UserCenterBundleImageName:@"uc_telephone"] forState:UIControlStateNormal];
    [teleImageButton addTarget:self action:@selector(callToSevrvice:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:teleImageButton];
    
    UIButton *teleButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(teleImageButton.frame), phoneLabel.frame.origin.y, size3.width+24 + 16, size3.height)];
    [teleButton setTitle:phoneString forState:UIControlStateNormal];
    [teleButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [teleButton setTitleColor:kColorDefaultBlue forState:UIControlStateNormal];
    [teleButton addTarget:self action:@selector(callToSevrvice:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:teleButton];
    
    
    _relatedTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 150 + 44, __MainScreen_Width, 90)];
    _relatedTableView.scrollsToTop = NO;
    _relatedTableView.delegate = self;
    _relatedTableView.dataSource = self;
    _relatedTableView.hidden=YES;
    _relatedTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _relatedTableView.separatorColor = [UIColor grayColor];
    _relatedTableView.backgroundColor = [UIColor whiteColor];
    _relatedTableView.hidden = YES;
    [self.view addSubview:_relatedTableView];
    
    
    
#pragma mark -
#pragma mark self.view 上面的约束
#pragma mark ---看看是否需要适配
    //    if (LTAPI_IS_ALLOWED(6.0)) {
    //        CGFloat heightOf_contentScrollView = __MainScreen_Width * (568 - HEIGHT_OF_STATUS - HEIGHT_OF_TOP) * 320.0;
    //        CGFloat topOf_ralatedTableView = __MainScreen_Width * 194 / 320.0;
    //        CGFloat widthOf_relatedTableView = __MainScreen_Width;
    //        CGFloat heightOf_relatedTableView = __MainScreen_Width * 90 / 320.0;
    //        NSDictionary *selfViews = NSDictionaryOfVariableBindings(_contentScrollView , _relatedTableView);
    //
    //        [_contentScrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    //        [_relatedTableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    //
    //        NSDictionary *selfViewMets = @{@"heightOf_con":@(heightOf_contentScrollView) , @"topOf_tab":@(topOf_ralatedTableView) , @"widthOf_tab":@(widthOf_relatedTableView) , @"heightOf_tab":@(heightOf_relatedTableView)};
    //        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_contentScrollView]-0-|" options:0 metrics:selfViewMets views:selfViews]];
    //        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_relatedTableView]-0-|" options:0 metrics:selfViewMets views:selfViews]];
    //        // ios6上从评论进入登陆页_contentScrollView的y值不对
    //        NSDictionary *topGapMetrics = @{@"topGap": !LTAPI_IS_ALLOWED(7.0) && !self.parentViewController.tabBarController ? @(43) : @(0)};
    //        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-topGap-[_contentScrollView]-0-|" options:0 metrics:topGapMetrics views:selfViews]];
    //        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-topOf_tab-[_relatedTableView(heightOf_tab)]" options:0 metrics:selfViewMets views:selfViews]];
    //    }
    
    
    _contentScrollView.contentSize = CGSizeMake(CGRectGetWidth(_contentScrollView.frame), CGRectGetMaxY(self.bottomView.frame));
    UIView *containview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _contentScrollView.contentSize.width, _contentScrollView.contentSize.height)];
    [containview addSubview:_bottomView];
    [containview addSubview:_loginTableView];
    [containview addSubview:_thirdLoginView];
    [_contentScrollView addSubview:containview];
    
    _contentScrollView.contentSize = CGSizeMake(CGRectGetWidth(_contentScrollView.frame), CGRectGetMaxY(self.bottomView.frame));
    [self addBarBottomLine];
    
}

#pragma mark -- 审核期间，隐藏第三方登陆入口，应对审核被拒

-(void)callToSevrvice:(UIButton *)button
{
    if ([SettingManager isHK]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel://39566666"]];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel://10109000"]];
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    _contentScrollView.contentSize = CGSizeMake(CGRectGetWidth(_contentScrollView.frame), CGRectGetMaxY(self.bottomView.frame));
    [super viewDidAppear:animated];
    
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortraitUpsideDown] forKey:@"orientation"];
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
    
}
- (void)backToNav{
    if (_loginEntranceType == eLoginEntranceTypeWebView) {
        //以webview登录的方式进入登录页面，返回时，退到webview页面之前
        NSArray *vcArr = self.navigationController.viewControllers;
        for (int i = vcArr.count-1 ; i >= 0; i--) {
            UIViewController *tempVC = [vcArr objectAtIndex:i];
            if ([tempVC isKindOfClass:[LTWebViewController_iPhone class]]) {
                //查找到webviewVC，获取webviewVC在当前navigation栈中的index
                NSInteger index = [vcArr indexOfObject:tempVC];
                //当web页面之前还有vc时，返回到前一个页面，否则直接退出登录页面
                if (index-1 >= 0) {
                    LTWebViewController_iPhone* webViewVC =  (LTWebViewController_iPhone *)tempVC;
                    if ([webViewVC.urlString hasPrefix:kMLoginMini] ||
                        [webViewVC.urlString hasPrefix:kMLoginHome]) {
                        //当web页的启示地址包含登录相关信息时，pop到webview前一个页面
                        UIViewController *popToVC = [vcArr objectAtIndex:index-1];
                        [self.navigationController popToViewController:popToVC animated:YES];
                    }else{
                        //当在web页面中点击某个按钮触发的登录时，仅退出登录页面，回到之前web页面
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }else{
                    //容错处理，当navigation栈的栈底是webview时，仅退出登录页面
                    [self.navigationController popViewControllerAnimated:YES];
                    
                }
            }
        }
        
    }else{
        //其他退出登录页面操作，正常pop
        [self.navigationController popViewControllerAnimated:YES];
        
    }
    
    [LTDataCenter addAction:LTDCActionPropertyLoginGoback
                   position:1
                       name:NSLocalizedString(@"返回", nil)
                        cid:NewCID_UnDefine
                        pid:nil
                        vid:nil
                        zid:nil
                     pageID:LTDCPageIDLogin
                 currentUrl:nil
                  isSuccess:YES];
}
- (void)addStatisticsWithPosition:(NSInteger)pos
{
    [LTDataCenter addAction:LTDCActionPropertyCategoryLoginPage
                   position:pos
                       name:nil
                        cid:NewCID_UnDefine
                 currentUrl:nil
                  isSuccess:YES];
}


- (void)registerButtonClicked {

//    [self addStatisticsWithPosition:4];
    
    [LTDataCenter addAction:LTDCActionPropertyLoginAccessory position:1 name:nil cid:NewCID_UnDefine pid:nil vid:nil zid:nil pageID:LTDCPageIDLogin currentUrl:nil isSuccess:YES];
    if ([[LeTVAppModule sharedModule] isImplemented])
    {
        [[LeTVAppModule sharedModule] letv_LTPlayerWrapper_playResumeFlagPlayInterruptShare];
    }
    else
    {
        Class obj=NSClassFromString(@"LTPlayerWrapper");
        [obj performSelector:@selector(playResumeFlagPlayInterruptShare)];
    }
    
//    [LTPlayerWrapper playInterrupt:LTPlayInterruptFlagShare];

    RegisterViewController_iPhone *viewController=[[RegisterViewController_iPhone alloc]init];
   
    if (_loginEntranceType == eLoginEntranceTypeSetting) {
        [self.fatherViewController.navigationController pushViewController:viewController animated:YES];
    }
    else {
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (void)playResumeFlagPlayInterruptShare
{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    /*
    //获取基站信息的干掉
    //获取基站信息
    if([DeviceManager is64bit] == YES)
    {
        return;
    }
    else{
        [[CoreTelephony sharedCoreTelephony] getCellInfo];
    }
    */
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    NSDictionary *userInfo=[SettingManager userCenterUserInfo];
    BOOL isLogin = ![NSObject empty:userInfo] && 1 == [SettingManager  getValueFromUserDefaults:kIsLogin];
    if(isLogin)
    {
        [self performSelector:@selector(loginSuccess:) withObject:userInfo];
    }
    [self performSelector:@selector(addObserverNotif) withObject:nil afterDelay:0];
    
    // ios5上从评论进入登陆页_contentScrollView的y值不对
    CGFloat contentScrollViewTop = 0;
    if (!LTAPI_IS_ALLOWED(7.0) && !self.parentViewController.tabBarController) {
        contentScrollViewTop = 43;
    }
    if (_loginEntranceType == eLoginEntranceTypeStar) {
        contentScrollViewTop = 0;
    }
    _contentScrollView.frame = CGRectMake(0, contentScrollViewTop, __MainScreen_Width, __MainScreen_Height - 20 - 44);
    
    [self hideTabBar:YES];
     [LTDataCenter addShowAction:LTDCActionPropertyCategoryUndefine cid:NewCID_UnDefine wz:-1 andPageID:LTDCPageIDLogin];
#ifndef LT_IPAD_CLIENT
    // 进入登录页面隐藏全app红包入口
    [LeRedPackageEntryManager setAppAllRedPackageEntryHiddenState:YES];
#endif
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}
- (void)addObserverNotif
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyKeyboardWillAppear:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyKeyboardWillDisappear:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(KeyboardChange:) name:UIKeyboardDidChangeFrameNotification object:nil];
}
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
    if (_editingTextField && _isKeyboardShow) {
        [_editingTextField resignFirstResponder];
        _isKeyboardShow = NO;
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
}
#pragma mark - Orientations delegate
- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}




#pragma mark - buttonAction
-(void)weixinLoginButton:(id)sender
{
    if (_editingTextField && _isKeyboardShow) {
        [_editingTextField resignFirstResponder];
        _isKeyboardShow = NO;
    }
    
    //数据统计
    NSString * ref=[LTDataCenter queryRefWithPageid:LTDCPageIDLogin fl:LTDCActionPropertyLoginFromThirdParty wz:3];
    NSString *pageid =[NSString fomatPageIDEnumCode:LTDCPageIDLogin];
    [LTDataCenter addActionData:LTDCActionCodeClick actionProperty:[NSDictionary dictionaryWithObjectsAndKeys:ref,@"ref",[NSString stringWithFormat:@"%d",3],@"wz",[NSString safeString:[DeviceManager getIOSDeviceUUID]],@"iosid",NSLocalizedString(@"微信登录", nil),@"name", pageid,@"pageid",[LTDataCenter getActionCodeByActionCategory:LTDCActionPropertyLoginFromThirdParty],@"fl",nil] actionResult:YES cid:nil pid:nil vid:nil zid:nil currentUrl:nil reid:nil area:nil bucket:nil rank:nil];

    if (![self isConnectedToNetwork]) {
        [self showNetworkException];
        return;
    }


    [[LTShareEngineInterfaceObjc sharedEngine] checkIsInstalledSocialAppForPlatformType:LT_SSO_Platform_WeiXin withBlockFinish:^(BOOL isInstalled) {
        if (isInstalled) {
            id<LTShareEngineInterface> shareEngine =[LTShareEngineInterfaceObjc sharedEngine];
            shareEngine.delegate = self;
            [shareEngine logInPlatform:LT_SSO_Platform_WeiXin];
            
        }
    }];
}

- (void)qqLoginButton:(id)sender{
    if (_editingTextField && _isKeyboardShow) {
        [_editingTextField resignFirstResponder];
        _isKeyboardShow = NO;
    }
    
    //    [self addStatisticsWithPosition:2];
    [LTDataCenter addAction:LTDCActionPropertyLoginFromThirdParty position:1 name:NSLocalizedString(@"腾讯QQ登录", nil) cid:NewCID_UnDefine pid:nil vid:nil zid:nil pageID:LTDCPageIDLogin currentUrl:nil isSuccess:YES];
    
    if (![self isConnectedToNetwork]) {
        [self showNetworkException];
        return;
    }
    
    [LTShareEngineInterfaceObjc sharedEngine].delegate = self;
    [[LTShareEngineInterfaceObjc sharedEngine]logOutPlatform:LT_SSO_Platform_TencentQQ];
    
    //QQ sso调起qq客户端登陆
    [[LTShareEngineInterfaceObjc sharedEngine] checkIsInstalledSocialAppForPlatformType:LT_SSO_Platform_TencentQQ withBlockFinish:^(BOOL isInstalled) {
        
#ifndef LT_SSOLOGIN_QQ_SUPPORT
        isInstalled=NO;
#endif
        if (isInstalled) {
            id<LTShareEngineInterface> shareEngine =[LTShareEngineInterfaceObjc sharedEngine];
                shareEngine.delegate = self;
                [shareEngine logInPlatform:LT_SSO_Platform_TencentQQ];
            
        }else{
            //调起letv web登陆页面
            thirdPartyviewController = [[LTThirdPartyLoginViewController_iPhone alloc] initWithLoginType:eLoginTypeQQ];
            thirdPartyviewController.delegate = self;
            [thirdPartyviewController show];
        }
    }];

}
- (void)sinaLoginButton:(id)sender{
    if (_editingTextField && _isKeyboardShow) {
        [_editingTextField resignFirstResponder];
        _isKeyboardShow = NO;
    }
    
    //    [self addStatisticsWithPosition:1];
    [LTDataCenter addAction:LTDCActionPropertyLoginFromThirdParty position:2 name:NSLocalizedString(@"新浪微博登录", nil) cid:NewCID_UnDefine pid:nil vid:nil zid:nil pageID:LTDCPageIDLogin currentUrl:nil isSuccess:YES];

    if (![self isConnectedToNetwork]) {
        [self showNetworkException];
        return;
    }
    
    [LTShareEngineInterfaceObjc sharedEngine].delegate = self;
    [[LTShareEngineInterfaceObjc sharedEngine]logOutPlatform:LT_SSO_Platform_SinaWeiBo];
    
    //sso调起客户端
    [[LTShareEngineInterfaceObjc sharedEngine] checkIsInstalledSocialAppForPlatformType:LT_SSO_Platform_SinaWeiBo withBlockFinish:^(BOOL isInstalled) {
        
#ifndef LT_SSOLOGIN_SINA_SUPPORT
        isInstalled=NO;
#endif

        if (isInstalled) {
            id<LTShareEngineInterface> shareEngine =[LTShareEngineInterfaceObjc sharedEngine];
            shareEngine.delegate = self;
            [shareEngine logInPlatform:LT_SSO_Platform_SinaWeiBo];
            
        }else
        {
            //调起letv自己的web登陆页面
            thirdPartyviewController = [[LTThirdPartyLoginViewController_iPhone alloc] initWithLoginType:eLoginTypeSinaWeibo];
            thirdPartyviewController.delegate = self;
            [thirdPartyviewController show];

        }
    }];
    
}

#pragma mark - 获取用户信息，用letv token进行letv登陆验证
-(void)processSSOLoginDataInfo:(NSDictionary*)dict withSocialPlatform:(LTSSOLoginPlatformType)type
{
    NSDictionary * beanDict = [dict valueForKeyPath:@"result.bean"];
    NSString * token =[[dict objectForKey:@"result" ]objectForKey:@"sso_tk"];
    NSString * uid = [beanDict valueForKey:@"uid"];
    if (![[NSString safeString:uid] isEqualToString:@""]) {
        [LTDataModelEngine refreshTaskWithUrlModule:LTURLModule_UC_ThirdPartyLogin
                                   andDynamicValues:@[[NSString safeString:token], [DeviceManager getDeviceUUID]]
                                      andHttpMethod:@"GET"
                                      andParameters:nil
                                  completionHandler:^(NSDictionary *responseDic) {
                                      //
                                      if(![NSObject empty:responseDic])
                                      {
                                          NSString *errorCode=[NSString safeString:responseDic[@"errorCode"]];
                                          
                                          if([errorCode isEqualToString:@"1014"])
                                          {
                                              LTStatisticInfo  *statisInfo = [[LTStatisticInfo alloc]init];
                                              statisInfo.acode = LTDCActionCodeShow;
                                              statisInfo.st =  @"0";
                                              statisInfo.pageID = LTDCPageIDUnKnown;
                                              statisInfo.apc = LTDCActionPropertyCategoryLoginFailed;
                                              [LTDataCenter addStatistic:statisInfo];
                                              
                                              
                                              
                                          }
                                      }
                                  } errorHandler:^(NSError *error) {
                                      //
                                  }];
        
        NSString *userName = [beanDict valueForKey:@"nickname"];
        
        [SettingManager setUserCenterPassword:@""];
        [SettingManager setUserCenterTVToken:[NSString safeString:token]];
        [SettingManager setUserCenterUserName:[NSString safeString:userName]];
        
        LTUserCenterEngine *userCenterEngine = [LTUserCenterEngine userCenterEngine];
        
        
        //获取用户信息，用letv token进行letv登陆验证
        [userCenterEngine getUserInfoWithFinishBlock:^(BOOL isSuccess, NSDictionary *feedBack){
            [self removeLoading];
            if (!isSuccess) {
                [[LTUserShowTip shareView] show:YES withText:NSLocalizedString(@"登录失败", nil) isShowIndicator:NO];
                
            }
            else
             {
            [self loginSuccessed:[dict objectForKey:@"result"]];
            [[LTUserShowTip shareView] show:YES withText:NSLocalizedString(@"登录成功", nil) isShowIndicator:NO];
            

            //登陆成功数据统计
            NSString * ref=[LTDataCenter queryRefWithPageid:LTDCPageIDUnKnown fl:LTDCActionPropertyLoginSuccess wz:type+1];
            [LTDataCenter addActionData:LTDCActionCodeClick actionProperty:[NSDictionary dictionaryWithObjectsAndKeys:ref,@"ref",[NSString stringWithFormat:@"%ld",(long)type+1],@"wz", [LTDataCenter getActionCodeByActionCategory:LTDCActionPropertyLoginSuccess],@"fl",nil] actionResult:YES cid:nil pid:nil vid:nil zid:nil currentUrl:nil reid:nil area:nil bucket:nil rank:nil];
            }
        }];
    }else{

        [self removeLoading];
        [[LTUserShowTip shareView] show:YES withText:NSLocalizedString(@"登录失败", nil) isShowIndicator:NO];
    }

}

#pragma mark - 微博sso登陆成功回调,换取letv token
-(void)ltShareEngineSSOLoginAuthSucc:(LTMBaseInterface *)shareEngine platform:(LTSSOLoginPlatformType)platform userInfo:(NSDictionary *)userInfo
{
    LTSharePlatformUserInfo * user = [userInfo objectForKey:LTShareSSOUserInfoKey];
    NSString * accessToken = [NSString safeString:user.accessToken];
    NSString * userID = [NSString safeString:user.userID];
    NSArray * params = [NSArray arrayWithObjects:accessToken,userID,[DeviceManager getDeviceUUID],nil];
    LTURLModule urlModule=LTURLModule_Unknown;
    [self removeLoading];//移除换取微信token时的loading
    [self showLoadingView];
    
    switch (platform) {
        case LT_SSO_Platform_SinaWeiBo:
        {
            urlModule = LTURLModule_UC_SSOLoginSina;
        }
            break;
        case LT_SSO_Platform_TencentQQ:
        {
            urlModule=LTURLModule_UC_SSOLoginQQ;
        }
            break;
            
        case LT_SSO_Platform_WeiXin:
        {
            urlModule=LTURLModule_UC_SSOLoginWX;
        }
            
            break;
            
        default:
            break;
    }
    [SettingManager saveBoolValueToUserDefaults:YES ForKey:kThirdPartyLogin];
    //用qq、sina、weixin token 换取 letv sso_tk
    [LTDataModelEngine refreshTaskWithUrlModule:urlModule andDynamicValues:params isNeedCache:NO andHttpMethod:@"GET" andParameters:nil completionHandler:^(NSDictionary *bodyDict, NSString *markid) {
        if ([NSObject empty:bodyDict]) {
            [self removeLoading];
            [[LTUserShowTip shareView] show:YES withText:NSLocalizedString(@"登录失败", nil) isShowIndicator:NO];
        }else{
            [self processSSOLoginDataInfo:bodyDict withSocialPlatform:platform];
        }
    } nochangeHandler:^{
        [self removeLoading];
    } emptyHandler:^{
        [self removeLoading];
        [[LTUserShowTip shareView] show:YES withText:NSLocalizedString(@"登录失败", nil) isShowIndicator:NO];
    } tokenExpiredHander:nil errorHandler:^(NSError *error) {
        [self removeLoading];
        [[LTUserShowTip shareView] show:YES withText:NSLocalizedString(@"登录失败", nil) isShowIndicator:NO];
    }];
}

#pragma mark - sso登陆失败回调（目前微信授权用到）
-(void)ltShareEngineSSOLoginAuthFail:(LTMBaseInterface *)shareEngine platform:(LTSSOLoginPlatformType)platform userInfo:(NSDictionary *)userInfo
{
    [self removeLoading];
    [[LTUserShowTip shareView] show:YES withText:NSLocalizedString(@"授权失败", nil) isShowIndicator:NO];
}

#pragma mark - 开始请求微信token时loading
-(void)ltShareEngineWeixinStartGetToken
{
    [self showLoadingView];
}

#pragma mark - 请求微信token结束时移除loading
-(void)ltShareEngineWeixinStopGetToken
{
    [self removeLoading];
}

-(void)showLoadingView
{
    [self addLoading];
#ifdef LT_IPAD_CLIENT
    _loadingIndicator.frame=self.view.bounds;
    _loadingIndicator.activityIndicatorViewStyle=UIActivityIndicatorViewStyleGray;
    _loadingIndicator.backgroundColor=[UIColor whiteColor];
#endif
   
}


- (void)registerButton:(id)sender{
//    [self addStatisticsWithPosition:4];
    [LTDataCenter addAction:LTDCActionPropertyLoginAccessory position:1 name:nil cid:NewCID_UnDefine pid:nil vid:nil zid:nil pageID:LTDCPageIDLogin currentUrl:nil isSuccess:YES];

    if ([[LeTVAppModule sharedModule] isImplemented])
    {
        [[LeTVAppModule sharedModule] letv_LTPlayerWrapper_playResumeFlagPlayInterruptShare];
    }
    else
    {
        Class obj=NSClassFromString(@"LTPlayerWrapper");
        [obj performSelector:@selector(playResumeFlagPlayInterruptShare)];
    }
    
//    [LTPlayerWrapper playInterrupt:LTPlayInterruptFlagShare];
    
    RegisterViewController_iPhone *viewController=[[RegisterViewController_iPhone alloc]init];
    viewController.thirdDelegate=self;
    if (_loginEntranceType == eLoginEntranceTypeSetting) {
        [self.fatherViewController.navigationController pushViewController:viewController animated:YES];
    }
    else {
        [self.navigationController pushViewController:viewController animated:YES];
    }
}
- (void)forgetButton:(id)sender{
//    [self addStatisticsWithPosition:3];
    [LTDataCenter addAction:LTDCActionPropertyLoginAccessory position:2 name:nil cid:NewCID_UnDefine pid:nil vid:nil zid:nil pageID:LTDCPageIDLogin currentUrl:nil isSuccess:YES];

    FindPasswordViewController_iPhone *viewController=[[FindPasswordViewController_iPhone alloc]init];
    if (_loginEntranceType == eLoginEntranceTypeSetting) {
        [self.fatherViewController.navigationController pushViewController:viewController animated:YES];
    }
    else{
        [self.navigationController pushViewController:viewController animated:YES];
    }
}
- (void)backButtonClicked {
    [self LTSwipeBackAction];
    [self.navigationController popViewControllerAnimated:YES needNotification:YES];
    [LTDataCenter addAction:LTDCActionPropertyLoginGoback position:1 name:nil cid:NewCID_UnDefine pid:nil vid:nil zid:nil pageID:LTDCPageIDLogin currentUrl:nil isSuccess:YES];
}

- (void)LTSwipeBackAction {
    if (self.finishBlock) {
        self.finishBlock(NO);
    }
}

#ifndef LT_IPAD_CLIENT
- (void)dealloc
{
    [self updateRedpackageFloatViewHiddenState:NO];
}
// 更新红包入口状态
- (void)updateRedpackageFloatViewHiddenState:(BOOL)state
{
    if (!state) { // 处理登录成功后跳到H5页面仍需要隐藏红包入口
        UINavigationController *nav = [(UIViewController *)[GlobalMethods getRootViewController] navigationController];
        UIViewController *topViewController = nav.topViewController;
        if ([topViewController isKindOfClass:[LTWebViewController_iPhone class]]) {
            state = YES;
        }
    }
    [LeRedPackageEntryManager setAppAllRedPackageEntryHiddenState:state];

}
#endif
- (void)login:(id)sender{
    [LTDataCenter addAction:LTDCActionPropertyLoginAction position:1 name:nil cid:NewCID_UnDefine pid:nil vid:nil zid:nil pageID:LTDCPageIDLogin currentUrl:nil isSuccess:YES];

    if ([NSString isBlankString:self.userTextField.text]) {
        [self showAlert:NSLocalizedString(@"请输入乐视帐号", nil)];
        return;
    }
    if ([NSString isBlankString:self.passwordTextField.text]){
        [self showAlert:NSLocalizedString(@"请输入密码", @"请输入密码")];
        return;
    }
    if (![NetworkReachability connectedToNetwork]) {
        [self showAlert:[[LTAlertMsgManager shareAlertManageInstance] getLTAlertMsgByAlertID:LTAlertMsg_Network_LinkError]];
        return;
    }
    
//    [self addStatisticsWithPosition:1];
   
    
    [self.userTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [[LTUserShowTip shareView] show:YES withText:NSLocalizedString(@"登录中...", @"登录中...") isShowIndicator:YES];
    
    LTUserCenterEngine *userCenterEngine = [LTUserCenterEngine userCenterEngine];
    userCenterEngine.delegate = self;
    [userCenterEngine logInWithUserID:self.userTextField.text
                          andPassword:self.passwordTextField.text];
}
- (void)showAlert:(NSString *)message{
    UIAlertView *alert=[[LTAlertView alloc]initWithTitle:@"" message:message delegate:self cancelButtonTitle:NSLocalizedString(@"确定", nil) otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	_editingTextField = textField;
    [UIView animateWithDuration:0.5 animations:^{_contentScrollView.contentOffset=CGPointMake(0, 150);}];
    
    if (textField.text.length == 0) {
        textField.rightViewMode = UITextFieldViewModeNever;
    } else {
        textField.rightViewMode = UITextFieldViewModeAlways;
    }
    CGRect textFieldRect = CGRectZero;
    if (_editingTextField == self.userTextField) {
        textFieldRect = CGRectMake(10, 150 , 300, 44);
    }
    else if (_editingTextField == self.passwordTextField) {
        textFieldRect = CGRectMake(10, 150 + 44, 300, 44);
    }
    [_contentScrollView scrollRectToVisible:textFieldRect animated:NO];
}

- (void) textFieldDidChange:(UITextField *) textField{
    if (textField.text.length == 0) {
        textField.rightViewMode = UITextFieldViewModeNever;
    } else {
        textField.rightViewMode = UITextFieldViewModeAlways;
    }
    if (textField==self.userTextField) {
        if ([textField.text hasSuffix:@"@"]&&_relatedTableView.hidden) {
            [UIView animateWithDuration:0.1 animations:^{
                [_contentScrollView scrollRectToVisible:CGRectMake(10, 150+44 , __MainScreen_Width-20, 90) animated:NO];
                _relatedTableView.hidden=NO;
                _relatedTableView.frame=CGRectMake(10,CGRectGetMinY(self.loginTableView.frame) + 44 - _contentScrollView.contentOffset.y, __MainScreen_Width-20, 90);
            } completion:^(BOOL finished) {
               
                [_relatedTableView reloadData];
                _contentScrollView.scrollEnabled=NO;
            }];
        }else {
            _relatedTableView.hidden=YES;
            _contentScrollView.scrollEnabled=YES;
        }
        
    }
    
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
	_editingTextField = textField;
    textField.rightViewMode = UITextFieldViewModeNever;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.userTextField) {
        [self.passwordTextField becomeFirstResponder];
    }
    else if (textField == self.passwordTextField){
        [textField resignFirstResponder];
        [self login:nil];
    }
    if (_relatedTableView.hidden == NO) {
        _relatedTableView.hidden = YES;
        _contentScrollView.scrollEnabled = YES;
    }
    return YES;
}
#pragma mark - KeyBoardDelegate
- (void)notifyKeyboardWillAppear:(NSNotification*)note
{
    if (_isKeyboardShow) {
        return;
    }
    _isKeyboardShow = YES;
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_3_2
    NSValue *keyboardBoundsValue = [[note userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
#else
    NSValue *keyboardBoundsValue = [[note userInfo] objectForKey:UIKeyboardBoundsUserInfoKey];
#endif
    CGRect keyboardRect = CGRectZero;
    [keyboardBoundsValue getValue:&keyboardRect];
    
    [UIView animateWithDuration:0.25 animations:^{
        CGRect rect = _contentScrollView.frame;
        //rect.origin.y -= keyboardHeight;
        rect.size.height = __MainScreen_Height - 20 - 44 - keyboardRect.size.height;
        _contentScrollView.frame = rect;
        
        CGRect textFieldRect;
        if (_editingTextField == self.userTextField) {
            textFieldRect = CGRectMake(10, 150 , 300, 44);
        }
        else if (_editingTextField == self.passwordTextField) {
            textFieldRect = CGRectMake(10, 150   + 44, 300, 44);
        }
        [_contentScrollView scrollRectToVisible:textFieldRect animated:NO];
    } completion:^(BOOL finished) {
        
    }];
    
    
}
- (void)KeyboardChange:(NSNotification*)note{
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_3_2
    NSValue *keyboardBoundsValue = [[note userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
#else
    NSValue *keyboardBoundsValue = [[note userInfo] objectForKey:UIKeyboardBoundsUserInfoKey];
#endif
    CGRect keyboardRect = CGRectZero;
    [keyboardBoundsValue getValue:&keyboardRect];
    [UIView animateWithDuration:0.25 animations:^{
        CGRect rect = _contentScrollView.frame;
        if (_isKeyboardShow) {
            rect.size.height = __MainScreen_Height - 20 - 44 - keyboardRect.size.height;
        }
        else{
            rect.size.height = __MainScreen_Height - 20 - 44;
        }
        _contentScrollView.frame = rect;
        
        CGRect textFieldRect = CGRectZero;
        if (_editingTextField == self.userTextField) {
            textFieldRect = CGRectMake(10, 150 , 300, 44);
        }
        else if (_editingTextField == self.passwordTextField) {
            textFieldRect = CGRectMake(10, 150 + 44, 300, 44);
        }

        [_contentScrollView scrollRectToVisible:textFieldRect animated:NO];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)notifyKeyboardWillDisappear:(NSNotification*)note
{
    _isKeyboardShow = NO;
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_3_2
    NSValue *keyboardBoundsValue = [[note userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
#else
    NSValue *keyboardBoundsValue = [[note userInfo] objectForKey:UIKeyboardBoundsUserInfoKey];
#endif
    CGRect keyboardRect;
    [keyboardBoundsValue getValue:&keyboardRect];
    [UIView animateWithDuration:0.25 animations:^{
        CGRect rect = _contentScrollView.frame;
        rect.size.height = __MainScreen_Height - 20 - 44 ;
//        rect.origin.y = 0;
        _contentScrollView.frame = rect;
        
    } completion:^(BOOL finished) {
        
    }];
    
}
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == _relatedTableView){
        return 8;
    }
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_relatedTableView==tableView) {
        return 30;
    }
    if (indexPath.row == 0 || indexPath.row == 1) {
        return 44;
    }
    else if (indexPath.row == 2)
    {
        return 97;
    }
    return 0;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == _relatedTableView) {
        static NSString *CellIdentifier = @"relatedCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.backgroundColor = RGBACOLOR(242, 242, 242, 1);
        _relatedTableView.separatorColor = RGBACOLOR(186, 186, 186, 1);
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.textColor = RGBACOLOR(51, 51, 51, 1);
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = [NSString stringWithFormat:@"%@163.com",_userTextField.text];
                break;
            case 1:
                cell.textLabel.text= [NSString stringWithFormat:@"%@sina.com",_userTextField.text];
                break;
            case 2:
                cell.textLabel.text= [NSString stringWithFormat:@"%@qq.com",_userTextField.text];
                break;
            case 3:
                cell.textLabel.text= [NSString stringWithFormat:@"%@sohu.com",_userTextField.text];
                break;
            case 4:
                cell.textLabel.text= [NSString stringWithFormat:@"%@126.com",_userTextField.text];
                break;
            case 5:
                cell.textLabel.text= [NSString stringWithFormat:@"%@gmail.com",_userTextField.text];
                break;
            case 6:
                cell.textLabel.text= [NSString stringWithFormat:@"%@hotmail.com",_userTextField.text];
                break;
            case 7:
                cell.textLabel.text= [NSString stringWithFormat:@"%@yahoo.com",_userTextField.text];
                break;
            default:
                break;
        }
        
        return cell;
        
    }
    else{
        NSString *cellIdentifier = [NSString stringWithFormat:@"loginTableCell%ld",(long)indexPath.row ];
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
        }
        if (indexPath.row == 0) {
            NSString *string = NSLocalizedString(@"帐号", nil);
            CGSize size = [string sizeWithFont:[UIFont systemFontOfSize:15]];
            UILabel *label1 = [UIButtonConstructor createLabelWithText:string
                                                       backgroundColor:[UIColor clearColor]
                                                             textColor:RGBACOLOR(57, 57, 57, 1)
                                                         textAlignment:NSTextAlignmentLeft
                                                                  font:[UIFont systemFontOfSize:15]];
            label1.frame = CGRectMake(15, (44- size.height)/2, size.width, size.height);
            [cell.contentView addSubview:label1];
            size = [NSLocalizedString(@"请输入邮箱", nil) sizeWithFont:[UIFont systemFontOfSize:14]];
            
            self.userTextField = [[LTCommonTextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(label1.frame) + 48, (44-size.height)/2, __MainScreen_Width-CGRectGetMaxX(label1.frame) - 48, size.height)];
            self.userTextField.delegate = self;
            self.userTextField.keyboardType = UIKeyboardTypeEmailAddress;
            self.userTextField.returnKeyType = UIReturnKeyNext;
            self.userTextField.textColor = RGBACOLOR(57, 57, 57, 1);
            [self.userTextField addTarget:self action:@selector(textFieldDidChange:)forControlEvents:UIControlEventEditingChanged];
            self.userTextField.placeholder = NSLocalizedString(@"请输入邮箱/手机号", @"请输入邮箱/手机号");
            [cell.contentView addSubview:self.userTextField];
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(15, 44-0.5, __MainScreen_Width - 15, 0.5)];
            line.backgroundColor = RGBACOLOR(223, 223, 223, 1);
            [cell.contentView addSubview:line]; 
            
            BOOL isThirdPartyLogin = [SettingManager getBoolValueFromUserDefaults:kThirdPartyLogin];
            
            if ([SettingManager userCenterUserName]&&![NSString isBlankString:[SettingManager userCenterUserName]]&&!isThirdPartyLogin) {
                self.userTextField.text = [SettingManager userCenterUserName];
            }
            
        }
        else if (indexPath.row ==1){
            NSString *string = NSLocalizedString(@"密码", nil);
            CGSize size = [string sizeWithFont:[UIFont systemFontOfSize:15]];
            UILabel *label1 = [UIButtonConstructor createLabelWithText:string
                                                       backgroundColor:[UIColor clearColor]
                                                             textColor:RGBACOLOR(57, 57, 57, 1)
                                                         textAlignment:NSTextAlignmentLeft
                                                                  font:[UIFont systemFontOfSize:15]];
            label1.frame = CGRectMake(15, (44- size.height)/2, size.width, size.height);
            [cell.contentView addSubview:label1];
            size = [NSLocalizedString(@"请输入密码", @"请输入密码") sizeWithFont:[UIFont systemFontOfSize:14]];
            self.passwordTextField = [[LTCommonTextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(label1.frame) + 48, (44-size.height)/2, __MainScreen_Width-CGRectGetMaxX(label1.frame) - 48, size.height)];
            
            self.passwordTextField.delegate = self;
            self.passwordTextField.secureTextEntry=YES;
            self.passwordTextField.returnKeyType = UIReturnKeyDone;
            self.passwordTextField.textColor = RGBACOLOR(57, 57, 57, 1);
            self.passwordTextField.placeholder = NSLocalizedString(@"请输入密码", @"请输入密码");
            [cell.contentView addSubview:self.passwordTextField];
            
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 44-0.5, __MainScreen_Width, 0.5)];
            line.backgroundColor = RGBACOLOR(223, 223, 223, 1);
            [cell.contentView addSubview:line];
        }
        else if (indexPath.row == 2){
            LTUIButton *button = [[LTUIButton alloc] initWithFrame:CGRectMake((__MainScreen_Width - 290)/2, 15, 290, 37)];
            button.backgroundColor = [UIColor clearColor];
            [button setBorderColorWithRed:88.f withColorGreen:149.f withColorBlue:237.f];
            button.titleLabel.textAlignment = NSTextAlignmentCenter;
            button.titleLabel.font = [UIFont systemFontOfSize:18];
            [button setTitle:NSLocalizedString(@"登录", nil) forState:UIControlStateNormal];
            [button setTitleColor:kColorDefaultBlue forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            [button setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor] size:button.frame.size] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageWithColor:kColorDefaultBlue size:button.frame.size] forState:UIControlStateHighlighted];
            [button addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:button];
            
            NSString *string = NSLocalizedString(@"立即注册", nil);

            self.registerButton = [UIButtonConstructor createButtonWithFrame:CGRectMake((__MainScreen_Width - 290.0) / 2, CGRectGetMaxY(button.frame) + 2, 159-15, 40) backgroundColor:[UIColor clearColor] text:string textColor:kColorDefaultBlue textAlignment:NSTextAlignmentCenter font:[UIFont systemFontOfSize:15] target:self selector:@selector(registerButton:)];
            [cell.contentView addSubview:self.registerButton];
            
            string = NSLocalizedString(@"忘记密码", @"忘记密码");
            self.forgetButton = [UIButtonConstructor createButtonWithFrame:CGRectMake(CGRectGetMaxX(self.registerButton.frame), CGRectGetMinY(self.registerButton.frame), 159-15, 40) backgroundColor:[UIColor clearColor] text:string textColor:kColorDefaultBlue textAlignment:NSTextAlignmentCenter font:[UIFont systemFontOfSize:15] target:self selector:@selector(forgetButton:)];
            [cell.contentView addSubview:self.forgetButton];
            UIView *centerLine = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.registerButton.frame), 65, 1, 17)];
            centerLine.backgroundColor =RGBACOLOR(223, 223, 223, 1);
            [cell.contentView addSubview:centerLine];
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 97-0.5, __MainScreen_Width, 0.5)];
            line.backgroundColor = RGBACOLOR(223, 223, 223, 1);
            [cell.contentView addSubview:line];
        }
        return cell;
    }

    
}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView==_relatedTableView) {
        _userTextField.text=[tableView cellForRowAtIndexPath:indexPath].textLabel.text;
        _relatedTableView.hidden=YES;
        [_passwordTextField becomeFirstResponder];
        _contentScrollView.scrollEnabled = YES;
    }
}
//#pragma mark - UITextFieldDelegate
//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
//    
//    return NO;
//}
//- (void)textFieldDidBeginEditing:(UITextField *)textField{
//    
//}
//- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
//    return NO;
//}- (void)textFieldDidEndEditing:(UITextField *)textField{
//    
//}
//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
//    return YES;
//}
#pragma mark -
#pragma mark - LTThirdPartyLoginDelegate

- (void)loginSuccessed:(NSDictionary *)dict {
    
//    NSString *token = [dict objectForKey:@"sso_tk"];
    NSDictionary *userInfo = [dict objectForKey:@"bean"];
    if (userInfo != nil) {
        [SettingManager saveIntValueToUserDefaults:1 ForKey:kIsLogin];
        
        
//        [SettingManager setUserCenterUserInfo:userInfo];
        
        
//        NSString *userName = [userInfo objectForKey:@"nickname"];
//        
//        [SettingManager setUserCenterUserName:userName];
//        [SettingManager setUserCenterPassword:@""];
//        [SettingManager setUserCenterTVToken:token];
//        [SettingManager setUserCenterUserName:[NSString safeString:userName]];
        
        if (NEED_CLOUD_FOLLOW) {
            //登录成功，上传本地播放单。
            [HistoryCommand submitToCloudByFavWithFinishBlock:^{
                //[HistoryCommand updateDBWithCloudWithFinishBlock:nil];
            }];
        }
        
        [HistoryCommand commitLocalFav:^{
            nil;
        }];
        
        
        [self performSelector:@selector(loginSuccess:) withObject:userInfo afterDelay:0.0];
        // 登录成功，上报一条login日志
        [LTDataCenter loginToUserCenter];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshUserInfoWithLoginActionNotification object:nil];
    }
}

-(void)loginFailed
{
    
}

//#pragma mark -
//#pragma mark - LTLetvLoginViewControllerDelegate 
//
//- (void)letvLoginSuccess {
//    if ([deleage isKindOfClass:[UserCenterViewController_iPhone class]]) {
//        if ([deleage respondsToSelector:@selector(loginSuccess)]) {
//            [deleage loginSuccess];
//        }
//    }
//}
#pragma mark - LTUserCenterEngineDelegate

- (void)LTUserCenterEngineAlreadyLoggedIn:(LTUserCenterEngine *)engine{
    
    [[LTUserShowTip shareView]close:NO];
}

- (void)LTUserCenterEngineDidLogIn:(LTUserCenterEngine *)engine{
    
    [[LTUserShowTip shareView]close:NO];
    
    NSString *tips=[[LTAlertMsgManager shareAlertManageInstance]getLTAlertMsgByAlertID:LTToastMsg_UserCenter_LoginSuccess];
    [[LTUserShowTip shareView]show:YES withText:tips isShowIndicator:NO];
    
    NSDictionary *userInfo = [SettingManager userCenterUserInfo];
    [self performSelector:@selector(loginSuccess:) withObject:userInfo afterDelay:2.f];
    
    // [SettingManager setUserCenterAutoLoginFlag:(autoLoginBtn.selected)];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshUserInfoWithLoginActionNotification object:nil];
}

- (void)LTUserCenterEngineDidFailToLogIn:(LTUserCenterEngine *)engine WithError:(NSString *)errorMessage{
    
    [[LTUserShowTip shareView] close:NO];
    
    [self showAlert:errorMessage];
}
#pragma mark - 代理
-(void)loginSuccess:(NSDictionary *)dict{
    // 登录成功，上传本地播放记录
    [LTPlayHistoryCommand submitToCloudByRecentWithFinishBlock:^{
        [LTPlayHistoryCommand updateDBWithCloudWithFinishBlock:nil];
    }];
    //登录成功，发送增加积分通知
    [[NSNotificationCenter defaultCenter] postNotificationName:kAddIntegrationNotification object:nil];
    
 #ifndef LT_IPAD_CLIENT
    //春节红包更新信息
    if ([SettingManager isSpringRedPackageOn]) {
        NSString * tm = [NSString stringWithFormat:@"%@",[NSNumber numberWithLongLong:[[NSDate date]timeIntervalSince1970]]];
        NSString * device = [DeviceManager getLetvDeviceUUID];
        NSString * appRunID = [NSString stringWithFormat:@"%@_%@",device,tm];
        
        LeTVRedPackageSDKInfo * info = [LeTVRedPackageSDKInfo registerSDKInfoWithAppCode:kSpringRedPackageLetvAppCode deviceID:[DeviceManager getLetvDeviceUUID] appRunID:appRunID networkType:[NetworkReachability currentNetType]];
        [[LeTVRedPackageSDKManager sharedInstance]ltrp_registerSDKWithAppInfo:info loginToken:[SettingManager userCenterTVToken] userId:[SettingManager getLoginPriorUserId]];
    }
#endif
    
    
    
    if ([deleage respondsToSelector:@selector(isNeedCallJsLogin)]
        && [deleage isNeedCallJsLogin]) {
        // 此时不需要调用JS Login
    }
    else {
        // 如果不是从WebView界面调用的登陆，则调用JS登陆消息
        if (![deleage isKindOfClass:NSClassFromString(@"LTWebViewController_iPhone")]) {
            [LTJSLoginManager shareInstance].delegate = nil;
            [[LTJSLoginManager shareInstance] login];
        }
    }

    if (self.finishBlock) {
        if (self.finishBlock(YES)) {
           return;
        } 
    }
    
    if ([deleage isKindOfClass:NSClassFromString(@"UserCenterViewController_iPhone")]) {
        if ([deleage respondsToSelector:@selector(loginSuccess)]) {
            [deleage loginSuccess];
        }
    }else if ([deleage isKindOfClass:NSClassFromString(@"LTHotVideosViewController_iPhone")]){
        if ([deleage respondsToSelector:@selector(loginSuccess)]) {
            [deleage loginSuccess];
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else if ([deleage isKindOfClass:NSClassFromString(@"LTPayForOrderDetailsViewController")]) {
        if ([deleage respondsToSelector:@selector(loginSuccess)]) {
            [deleage loginSuccess];
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    }
    else if ([deleage isKindOfClass:NSClassFromString(@"LTPayForLetvVIPViewController")]) {
        if ([deleage respondsToSelector:@selector(loginSuccess)]) {
            [deleage loginSuccess];
           // [self.navigationController popViewControllerAnimated:NO];
        }
        
    }else if ([deleage isKindOfClass:NSClassFromString(@"LTSignInWebViewController_iPhone")]) {
        if ([deleage respondsToSelector:@selector(loginSuccess)]) {
            [deleage loginSuccess];
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    }
    else if ([deleage isKindOfClass:NSClassFromString(@"LTWebViewController_iPhone")]) {
        if ([deleage respondsToSelector:@selector(loginSuccess)]) {
            [deleage loginSuccess];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else if ([deleage isKindOfClass:NSClassFromString(@"LT_WoViewController")]){
        if ([deleage respondsToSelector:@selector(loginSuccess)]) {
            [deleage loginSuccess];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else if ([deleage isKindOfClass:NSClassFromString(@"LTRecommendViewController")]){
        //5.5 添加 邀请相关跳转
        if ([deleage respondsToSelector:@selector(loginSuccess)]) {
            [self.navigationController popViewControllerAnimated:NO];
            [deleage loginSuccess];
        }
    }
    else if ([deleage isKindOfClass:NSClassFromString(@"LTLivingPlayerViewController")]){
        if ([deleage respondsToSelector:@selector(loginSuccess)]) {
            [self.navigationController popViewControllerAnimated:NO];
            [deleage loginSuccess];
        }
    }else if ([deleage isKindOfClass:NSClassFromString(@"MyMessageViewController")]){
        if ([deleage respondsToSelector:@selector(loginSuccess)]) {
            [self.navigationController popViewControllerAnimated:NO];
            [deleage loginSuccess];
        }
        
    }else if ([deleage isKindOfClass:NSClassFromString(@"LTStarDetailViewController")]){
        if ([deleage respondsToSelector:@selector(loginSuccess)]) {
           [self.navigationController popViewControllerAnimated:YES];
           [deleage loginSuccess];
        }
        
    }else if ([deleage isKindOfClass:NSClassFromString(@"LTMyVoucherViewController")]){
        if (self.deleage && [self.deleage respondsToSelector:@selector(loginSuccess)]) {
            [self.navigationController popViewControllerAnimated:NO];
            [deleage loginSuccess];
        }
    }else if ([deleage isKindOfClass:NSClassFromString(@"LeTVRedPacketsPopView")]) {
        if (self.deleage && [self.deleage respondsToSelector:@selector(loginSuccess)]) {
            [self.navigationController popViewControllerAnimated:NO];
            [deleage loginSuccess];
        }
    }else {
        for (UIViewController *temp in self.navigationController.viewControllers) {

            if ([temp isKindOfClass:NSClassFromString(@"LTMovieDownloadViewController")]) {
                [self.navigationController popToViewController:temp animated:YES];
                return;
            }
        }
        
        for (UIViewController *temp in self.navigationController.viewControllers) {
            if ([temp isMemberOfClass:NSClassFromString(@"LTMoviePlayerViewController")]) {
//                if ([SettingManager isVipUser]) {
//                    [self.navigationController popToViewController:temp animated:YES];
//                    return;
//                }
//                else{
//                    [self.navigationController popToViewController:temp animated:NO];
//                    [ViewControllerNavManagerHelper navToVipPay:temp];
//                    return;
//                }
                   // [self.navigationController popToViewController:temp animated:YES];
                    [deleage loginSuccess];
                    return;
            }

            if ([temp isKindOfClass:NSClassFromString(@"MyselfViewController_iPhone")]) {
                if ([deleage respondsToSelector:@selector(loginSuccess)]) {
                    [deleage loginSuccess];
                }
                [self.navigationController popToViewController:temp animated:YES];
                
                return;
            }
        }
        [self.navigationController popViewControllerAnimated:YES needNotification:YES];
    }
}
//-(void)loginSuccess:(NSDictionary *)dict {
//    if (_delegate != nil && [_delegate respondsToSelector:@selector(letvLoginSuccess)]) {
//        [self.navigationController popViewControllerAnimated:YES];
//        [_delegate letvLoginSuccess];
//    }
//    else {
//        UIViewController *popToViewController = nil;
//        if ([_popToClassName length] > 0) {
//            NSArray *viewControllers = [self.navigationController viewControllers];
//            
//            for (UIViewController *viewController in viewControllers) {
//                NSString *className = NSStringFromClass([viewController class]);
//                if ([className isEqualToString:_popToClassName]) {
//                    popToViewController = viewController;
//                    break;
//                }
//            }
//        }
//        
//        if (popToViewController != nil) {
//            [self.navigationController popToViewController:popToViewController animated:YES];
//        }
//        else {
//            [self.navigationController popToRootViewControllerAnimated:YES];
//        }
//    }
//    
//    [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshUserInfoWithLoginActionNotification object:nil];
//}


//- (void)addStatisticsWithPosition:(NSInteger)pos
//{
//    [LTDataCenter addAction:LTDCActionPropertyCategoryLetvLoginPage
//                   position:pos
//                       name:nil
//                        cid:NewCID_UnDefine
//                 currentUrl:nil
//                  isSuccess:YES];
//}


@end

#else

//
//  LoginViewController_iPhone.m
//  LetvIphoneClient
//
//  Created by 鹏飞 季 on 12-8-21.
//  Copyright (c) 2012年 乐视网. All rights reserved.
//
#import <LeTVMobileFoundation/LeTVMobileFoundation.h>
#ifndef LT_MERGE_FROM_IPAD_CLIENT
#import "LoginViewController_iPhone.h"
#import "RegisterViewController_iPhone.h"
#import "UserCenterBundle.h"
#import <LeTVRedPackageSDK/LeTVRedPackageSDK.h>
/*
#import "UserCenterViewController_iPhone.h"
#import "LTThirdPartyLoginTableViewCell.h"
#import "LTMovieDownloadViewController_iPhone.h"
#import "MyselfViewController_iPhone.h"
*/


//#import "LTUIButton.h"
//#import "UIButtonConstructor.h"
//#import "UINavigationController+Extend.h"
//#import "ExtensionUIImage.h"
#import "FindPasswordViewController_iPhone.h"
//#import "LTUserShowTip.h"
//#import "LTWebViewController_iPhone.h"
#import "AuditManager.h"

#define USER_ACCOUNT_TAG 101
#define PASSWORD_TAG 102
#define CustomHeight 480
@interface LoginViewController_iPhone ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate , UIScrollViewDelegate>
{
    UITextField *_editingTextField;
    UIScrollView *_contentScrollView;
    UIActivityIndicatorView * _indicatorView;
    BOOL _isKeyboardShow;
}
@property (nonatomic, strong) UIButton *registerButton;
@property (nonatomic, strong) LTUIButton *loginButton;
@property (nonatomic, strong) UIButton *forgetButton;

@property (nonatomic, strong) UIButton *qqLoginButton;
@property (nonatomic, strong) UIButton *sinaLoginButton;
@property (nonatomic, strong) UIButton *weixinLoginButton;
@property (nonatomic, strong) UIView *thirdLoginView;
@property (nonatomic, strong) UITableView *loginTableView;
@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) LTCommonTextField *userTextField;
@property (nonatomic, strong) LTCommonTextField *passwordTextField;

@property (nonatomic, strong) UITableView *relatedTableView;

@end

@implementation LoginViewController_iPhone

@synthesize deleage;

- (id)initWithEntranceType:(LoginEntranceType)_entranceType {
    if (self = [super init]) {
        _loginEntranceType = _entranceType;
        _isKeyboardShow = NO;
        return self;
    }
    
    return nil;
}

- (id)initWithLoginFinishBlock:(LTLoginFinishBlock)finishBlock
{
    self = [super init];
    if (self) {
        _finishBlock = finishBlock;
        _isKeyboardShow = NO;
    }
    return self;
}

//- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
//{
//    [scrollView setContentOffset:scrollView.contentOffset animated:NO];
//}

- (void)loadView {
    [super loadView];
    
    [self.navigationItem setCustomTitle:NSLocalizedString(@"登录", nil)];
    [self addBackLeftBarButtonItem];
    // [self addDefaultLeftBarButtonItem:@"" isNeedBack:YES];
    
    self.view.backgroundColor = kColor246;
    
    // ios5上从评论进入登陆页_contentScrollView的y值不对
    CGFloat contentScrollViewTop = 0;
    if (!LTAPI_IS_ALLOWED(7.0) && !self.parentViewController.tabBarController) {
        contentScrollViewTop = 43;
    }
    if (_loginEntranceType == eLoginEntranceTypeStar) {
        contentScrollViewTop = 0;
        if (!LTAPI_IS_ALLOWED(7.0)) {
            self.navigationController.navigationBar.translucent = NO;
        }
    }
    _contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, contentScrollViewTop, __MainScreen_Width, __MainScreen_Height - 20 -44)];
    _contentScrollView.backgroundColor = [UIColor clearColor];
    _contentScrollView.alwaysBounceVertical = YES;
    _contentScrollView.scrollEnabled = YES;
    _contentScrollView.delegate = self;
    [self.view addSubview:_contentScrollView];
    
    
    self.thirdLoginView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, __MainScreen_Width, 200)];
    self.thirdLoginView.backgroundColor = kColor246;
    //    [_contentScrollView addSubview:self.thirdLoginView];
    
    CGSize size = CGSizeMake(290, 37);
    CGFloat weixinButtonHeight = size.height;
    //监测未安装微信，或微信api不支持的时候，隐藏微信按钮
    if (![[LTWeixinShareManager  shareWeixinManager] weixinEnableShare]) {
        weixinButtonHeight = 0;
        [self.thirdLoginView setFrame:CGRectMake(0, 0, __MainScreen_Width, 200 - 37)];
        
    }
    
    self.weixinLoginButton = [[UIButton alloc] initWithFrame:CGRectMake((__MainScreen_Width - size.width)/2, 15, size.width, weixinButtonHeight)];
    self.weixinLoginButton.backgroundColor = [UIColor clearColor];
    [self.weixinLoginButton setImage:[UIImage UserCenterBundleImageName:NSLocalizedString(@"weixin_login", nil)] forState:UIControlStateNormal];
    [self.weixinLoginButton setImage:[UIImage UserCenterBundleImageName:NSLocalizedString(@"weixin_login_selected", nil)] forState:UIControlStateHighlighted];
    [self.weixinLoginButton addTarget:self action:@selector(weixinLoginButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.thirdLoginView addSubview:self.weixinLoginButton];
    
    self.qqLoginButton = [[LTUIButton alloc] initWithFrame:CGRectMake((__MainScreen_Width - size.width)/2, CGRectGetMaxY(self.weixinLoginButton.frame)+15, size.width, size.height)];
    self.qqLoginButton.backgroundColor = [UIColor clearColor];
    [self.qqLoginButton setImage:[UIImage UserCenterBundleImageName:NSLocalizedString(@"qqLogin", nil)] forState:UIControlStateNormal];
    [self.qqLoginButton setImage:[UIImage UserCenterBundleImageName:NSLocalizedString(@"qqLogin_selected", nil)] forState:UIControlStateHighlighted];
    [self.qqLoginButton addTarget:self action:@selector(qqLoginButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.thirdLoginView addSubview:self.qqLoginButton];
    
    self.sinaLoginButton = [[LTUIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.qqLoginButton.frame), CGRectGetMaxY(self.qqLoginButton.frame) + 15, size.width, size.height)];
    self.sinaLoginButton.backgroundColor = [UIColor clearColor];
    [self.sinaLoginButton setImage:[UIImage UserCenterBundleImageName:NSLocalizedString(@"sinaLogin", nil)] forState:UIControlStateNormal];
    [self.sinaLoginButton setImage:[UIImage UserCenterBundleImageName:NSLocalizedString(@"sinaLogin_selected", nil)] forState:UIControlStateHighlighted];
    [self.sinaLoginButton addTarget:self action:@selector(sinaLoginButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.thirdLoginView addSubview:self.sinaLoginButton];
    


    size = [NSLocalizedString(@"乐视帐号登录", nil) sizeWithFont:[UIFont systemFontOfSize:15]];
    UILabel *label = [UIButtonConstructor createLabelWithText:NSLocalizedString(@"乐视帐号登录", nil)
                                              backgroundColor:[UIColor clearColor]
                                                    textColor:RGBACOLOR(57, 57, 57, 1)
                                                textAlignment:NSTextAlignmentLeft
                                                         font:[UIFont systemFontOfSize:15]];
    label.frame = CGRectMake(15, CGRectGetMaxY(self.sinaLoginButton.frame)+15 , size.width, size.height);
    [self.thirdLoginView addSubview:label];
    
    self.loginTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.thirdLoginView.frame) , __MainScreen_Width, 185)];
    self.loginTableView.backgroundColor = [UIColor whiteColor];
    self.loginTableView.dataSource = self;
    self.loginTableView.delegate = self;
    self.loginTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.loginTableView.scrollEnabled = NO;
    //    [_contentScrollView addSubview:self.loginTableView];
    
    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.loginTableView.frame), __MainScreen_Width, CustomHeight * 88 / 320.0)];
    self.bottomView.backgroundColor = RGBACOLOR(246, 246, 246, 1);
    //    [_contentScrollView addSubview:self.bottomView];
    NSString *string = NSLocalizedString(@"登录可享受云播放记录、追剧提醒、极速", nil);
    size = [string sizeWithFont:[UIFont systemFontOfSize:15]];
    UILabel *bottomLabel = [UIButtonConstructor createLabelWithText:NSLocalizedString(@"登录可享受云播放记录、追剧提醒、极速\n缓存、多屏互动和1080P速递服务。", @"登录可享受云播放记录、追剧提醒、极速\n缓存、多屏互动和1080P速递服务。") backgroundColor:[UIColor clearColor] textColor:RGBACOLOR(161, 161, 161, 1) textAlignment:NSTextAlignmentLeft font:[UIFont systemFontOfSize:15]];
    bottomLabel.numberOfLines = 2;
    bottomLabel.frame = CGRectMake((__MainScreen_Width - size.width)/2, 13, size.width, size.height*2);
    
    [self.bottomView addSubview:bottomLabel];
    
    NSString *labelString = NSLocalizedString(@"如有疑问请拨打客服电话:", @"如有疑问请拨打客服电话:");
    CGSize size2 = [labelString sizeWithFont:[UIFont systemFontOfSize:15]];
    
    NSString *phoneString = @"10109000";
    CGSize size3 = [phoneString sizeWithFont:[UIFont systemFontOfSize:13]];
    
    UILabel *phoneLabel = [UIButtonConstructor createLabelWithText:NSLocalizedString(@"如有疑问请拨打客服电话:", @"如有疑问请拨打客服电话:") backgroundColor:[UIColor clearColor] textColor:RGBACOLOR(161, 161, 161, 1) textAlignment:NSTextAlignmentLeft font:[UIFont systemFontOfSize:15]];
    phoneLabel.frame = CGRectMake((__MainScreen_Width - size2.width -size3.width - 24 - 16)/2 - 4, 13+5+bottomLabel.frame.size.height, size2.width, size2.height);
    [self.bottomView addSubview:phoneLabel];
    
    UIButton *teleImageButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(phoneLabel.frame), phoneLabel.frame.origin.y-3, 24, 25)];
    [teleImageButton setImage:[UIImage UserCenterBundleImageName:@"uc_telephone"] forState:UIControlStateNormal];
    [teleImageButton addTarget:self action:@selector(callToSevrvice:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:teleImageButton];
    
    UIButton *teleButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(teleImageButton.frame), phoneLabel.frame.origin.y, size3.width+24 + 16, size3.height)];
    [teleButton setTitle:phoneString forState:UIControlStateNormal];
    [teleButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [teleButton setTitleColor:kColorDefaultBlue forState:UIControlStateNormal];
    [teleButton addTarget:self action:@selector(callToSevrvice:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:teleButton];
    
    
    _relatedTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 150 + 44, __MainScreen_Width, 90)];
    _relatedTableView.scrollsToTop = NO;
    _relatedTableView.delegate = self;
    _relatedTableView.dataSource = self;
    _relatedTableView.hidden=YES;
    _relatedTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _relatedTableView.separatorColor = [UIColor grayColor];
    _relatedTableView.backgroundColor = [UIColor whiteColor];
    _relatedTableView.hidden = YES;
    [self.view addSubview:_relatedTableView];
    
    
    
#pragma mark -
#pragma mark self.view 上面的约束
#pragma mark ---看看是否需要适配
    //    if (LTAPI_IS_ALLOWED(6.0)) {
    //        CGFloat heightOf_contentScrollView = __MainScreen_Width * (568 - HEIGHT_OF_STATUS - HEIGHT_OF_TOP) * 320.0;
    //        CGFloat topOf_ralatedTableView = __MainScreen_Width * 194 / 320.0;
    //        CGFloat widthOf_relatedTableView = __MainScreen_Width;
    //        CGFloat heightOf_relatedTableView = __MainScreen_Width * 90 / 320.0;
    //        NSDictionary *selfViews = NSDictionaryOfVariableBindings(_contentScrollView , _relatedTableView);
    //
    //        [_contentScrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    //        [_relatedTableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    //
    //        NSDictionary *selfViewMets = @{@"heightOf_con":@(heightOf_contentScrollView) , @"topOf_tab":@(topOf_ralatedTableView) , @"widthOf_tab":@(widthOf_relatedTableView) , @"heightOf_tab":@(heightOf_relatedTableView)};
    //        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_contentScrollView]-0-|" options:0 metrics:selfViewMets views:selfViews]];
    //        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_relatedTableView]-0-|" options:0 metrics:selfViewMets views:selfViews]];
    //        // ios6上从评论进入登陆页_contentScrollView的y值不对
    //        NSDictionary *topGapMetrics = @{@"topGap": !LTAPI_IS_ALLOWED(7.0) && !self.parentViewController.tabBarController ? @(43) : @(0)};
    //        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-topGap-[_contentScrollView]-0-|" options:0 metrics:topGapMetrics views:selfViews]];
    //        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-topOf_tab-[_relatedTableView(heightOf_tab)]" options:0 metrics:selfViewMets views:selfViews]];
    //    }
    
    
    _contentScrollView.contentSize = CGSizeMake(CGRectGetWidth(_contentScrollView.frame), CGRectGetMaxY(self.bottomView.frame));
    UIView *containview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _contentScrollView.contentSize.width, _contentScrollView.contentSize.height)];
    [containview addSubview:_bottomView];
    [containview addSubview:_loginTableView];
    [containview addSubview:_thirdLoginView];
    [_contentScrollView addSubview:containview];
    
    _contentScrollView.contentSize = CGSizeMake(CGRectGetWidth(_contentScrollView.frame), CGRectGetMaxY(self.bottomView.frame));
    [self addBarBottomLine];
    
}

#pragma mark -- 审核期间，隐藏第三方登陆入口，应对审核被拒

-(void)callToSevrvice:(UIButton *)button
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel://10109000"]];
}

- (void)viewDidAppear:(BOOL)animated
{
    _contentScrollView.contentSize = CGSizeMake(CGRectGetWidth(_contentScrollView.frame), CGRectGetMaxY(self.bottomView.frame));
    [super viewDidAppear:animated];
    
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortraitUpsideDown] forKey:@"orientation"];
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
    
}
- (void)backToNav{
    if (_loginEntranceType == eLoginEntranceTypeWebView) {
        //以webview登录的方式进入登录页面，返回时，退到webview页面之前
        NSArray *vcArr = self.navigationController.viewControllers;
        for (int i = vcArr.count-1 ; i >= 0; i--) {
            UIViewController *tempVC = [vcArr objectAtIndex:i];
            if ([tempVC isKindOfClass:[LTWebViewController_iPhone class]]) {
                //查找到webviewVC，获取webviewVC在当前navigation栈中的index
                NSInteger index = [vcArr indexOfObject:tempVC];
                //当web页面之前还有vc时，返回到前一个页面，否则直接退出登录页面
                if (index-1 >= 0) {
                    LTWebViewController_iPhone* webViewVC =  (LTWebViewController_iPhone *)tempVC;
                    if ([webViewVC.urlString hasPrefix:kMLoginMini] ||
                        [webViewVC.urlString hasPrefix:kMLoginHome]) {
                        //当web页的启示地址包含登录相关信息时，pop到webview前一个页面
                        UIViewController *popToVC = [vcArr objectAtIndex:index-1];
                        [self.navigationController popToViewController:popToVC animated:YES];
                    }else{
                        //当在web页面中点击某个按钮触发的登录时，仅退出登录页面，回到之前web页面
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }else{
                    //容错处理，当navigation栈的栈底是webview时，仅退出登录页面
                    [self.navigationController popViewControllerAnimated:YES];
                    
                }
            }
        }
        
    }else{
        //其他退出登录页面操作，正常pop
        [self.navigationController popViewControllerAnimated:YES];
        
    }
    
    [LTDataCenter addAction:LTDCActionPropertyLoginGoback
                   position:1
                       name:NSLocalizedString(@"返回", nil)
                        cid:NewCID_UnDefine
                        pid:nil
                        vid:nil
                        zid:nil
                     pageID:LTDCPageIDLogin
                 currentUrl:nil
                  isSuccess:YES];
}
- (void)addStatisticsWithPosition:(NSInteger)pos
{
    [LTDataCenter addAction:LTDCActionPropertyCategoryLoginPage
                   position:pos
                       name:nil
                        cid:NewCID_UnDefine
                 currentUrl:nil
                  isSuccess:YES];
}


- (void)registerButtonClicked {

//    [self addStatisticsWithPosition:4];
    
    [LTDataCenter addAction:LTDCActionPropertyLoginAccessory position:1 name:nil cid:NewCID_UnDefine pid:nil vid:nil zid:nil pageID:LTDCPageIDLogin currentUrl:nil isSuccess:YES];
    if ([[LeTVAppModule sharedModule] isImplemented])
    {
        [[LeTVAppModule sharedModule] letv_LTPlayerWrapper_playResumeFlagPlayInterruptShare];
    }
    else
    {
        Class obj=NSClassFromString(@"LTPlayerWrapper");
        [obj performSelector:@selector(playResumeFlagPlayInterruptShare)];
    }
    
//    [LTPlayerWrapper playInterrupt:LTPlayInterruptFlagShare];

    RegisterViewController_iPhone *viewController=[[RegisterViewController_iPhone alloc]init];
   
    if (_loginEntranceType == eLoginEntranceTypeSetting) {
        [self.fatherViewController.navigationController pushViewController:viewController animated:YES];
    }
    else {
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (void)playResumeFlagPlayInterruptShare
{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    /*
    //获取基站信息的干掉
    //获取基站信息
    if([DeviceManager is64bit] == YES)
    {
        return;
    }
    else{
        [[CoreTelephony sharedCoreTelephony] getCellInfo];
    }
    */
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    NSDictionary *userInfo=[SettingManager userCenterUserInfo];
    BOOL isLogin = ![NSObject empty:userInfo] && 1 == [SettingManager  getValueFromUserDefaults:kIsLogin];
    if(isLogin)
    {
        [self performSelector:@selector(loginSuccess:) withObject:userInfo];
    }
    [self performSelector:@selector(addObserverNotif) withObject:nil afterDelay:0];
    
    // ios5上从评论进入登陆页_contentScrollView的y值不对
    CGFloat contentScrollViewTop = 0;
    if (!LTAPI_IS_ALLOWED(7.0) && !self.parentViewController.tabBarController) {
        contentScrollViewTop = 43;
    }
    if (_loginEntranceType == eLoginEntranceTypeStar) {
        contentScrollViewTop = 0;
    }
    _contentScrollView.frame = CGRectMake(0, contentScrollViewTop, __MainScreen_Width, __MainScreen_Height - 20 - 44);
    
    [self hideTabBar:YES];
     [LTDataCenter addShowAction:LTDCActionPropertyCategoryUndefine cid:NewCID_UnDefine wz:-1 andPageID:LTDCPageIDLogin];
#ifndef LT_IPAD_CLIENT
    // 进入登录页面隐藏全app红包入口
    [self updateRedpackageFloatViewHiddenState:YES];
#endif
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}
- (void)addObserverNotif
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyKeyboardWillAppear:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyKeyboardWillDisappear:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(KeyboardChange:) name:UIKeyboardDidChangeFrameNotification object:nil];
}
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
    if (_editingTextField && _isKeyboardShow) {
        [_editingTextField resignFirstResponder];
        _isKeyboardShow = NO;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
}
#pragma mark - Orientations delegate
- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}




#pragma mark - buttonAction
-(void)weixinLoginButton:(id)sender
{
    if (_editingTextField && _isKeyboardShow) {
        [_editingTextField resignFirstResponder];
        _isKeyboardShow = NO;
    }
    
    //数据统计
    NSString * ref=[LTDataCenter queryRefWithPageid:LTDCPageIDLogin fl:LTDCActionPropertyLoginFromThirdParty wz:3];
    NSString *pageid =[NSString fomatPageIDEnumCode:LTDCPageIDLogin];
    [LTDataCenter addActionData:LTDCActionCodeClick actionProperty:[NSDictionary dictionaryWithObjectsAndKeys:ref,@"ref",[NSString stringWithFormat:@"%d",3],@"wz",[NSString safeString:[DeviceManager getIOSDeviceUUID]],@"iosid",NSLocalizedString(@"微信登录", nil),@"name", pageid,@"pageid",[LTDataCenter getActionCodeByActionCategory:LTDCActionPropertyLoginFromThirdParty],@"fl",nil] actionResult:YES cid:nil pid:nil vid:nil zid:nil currentUrl:nil reid:nil area:nil bucket:nil rank:nil];

    if (![self isConnectedToNetwork]) {
        [self showNetworkException];
        return;
    }


    [[LTShareEngine sharedEngine] checkIsInstalledSocialAppForPlatformType:LT_SSO_Platform_WeiXin withBlockFinish:^(BOOL isInstalled) {
        if (isInstalled) {
            LTShareEngine *shareEngine =[LTShareEngine sharedEngine];
            shareEngine.delegate = self;
            [shareEngine logInPlatform:LT_SSO_Platform_WeiXin];
            
        }
    }];
}

- (void)qqLoginButton:(id)sender{
    if (_editingTextField && _isKeyboardShow) {
        [_editingTextField resignFirstResponder];
        _isKeyboardShow = NO;
    }
    
    //    [self addStatisticsWithPosition:2];
    [LTDataCenter addAction:LTDCActionPropertyLoginFromThirdParty position:1 name:NSLocalizedString(@"腾讯QQ登录", nil) cid:NewCID_UnDefine pid:nil vid:nil zid:nil pageID:LTDCPageIDLogin currentUrl:nil isSuccess:YES];
    
    if (![self isConnectedToNetwork]) {
        [self showNetworkException];
        return;
    }
    
    [LTShareEngine sharedEngine].delegate = self;
    [[LTShareEngine sharedEngine]logOutPlatform:LT_SSO_Platform_TencentQQ];
    
    //QQ sso调起qq客户端登陆
    [[LTShareEngine sharedEngine] checkIsInstalledSocialAppForPlatformType:LT_SSO_Platform_TencentQQ withBlockFinish:^(BOOL isInstalled) {
        
#ifndef LT_SSOLOGIN_QQ_SUPPORT
        isInstalled=NO;
#endif
        if (isInstalled) {
            LTShareEngine *shareEngine =[LTShareEngine sharedEngine];
                shareEngine.delegate = self;
                [shareEngine logInPlatform:LT_SSO_Platform_TencentQQ];
            
        }else{
            //调起letv web登陆页面
            thirdPartyviewController = [[LTThirdPartyLoginViewController_iPhone alloc] initWithLoginType:eLoginTypeQQ];
            thirdPartyviewController.delegate = self;
            [thirdPartyviewController show];
        }
    }];

}
- (void)sinaLoginButton:(id)sender{
    if (_editingTextField && _isKeyboardShow) {
        [_editingTextField resignFirstResponder];
        _isKeyboardShow = NO;
    }
    
    //    [self addStatisticsWithPosition:1];
    [LTDataCenter addAction:LTDCActionPropertyLoginFromThirdParty position:2 name:NSLocalizedString(@"新浪微博登录", nil) cid:NewCID_UnDefine pid:nil vid:nil zid:nil pageID:LTDCPageIDLogin currentUrl:nil isSuccess:YES];

    if (![self isConnectedToNetwork]) {
        [self showNetworkException];
        return;
    }
    
    [LTShareEngine sharedEngine].delegate = self;
    [[LTShareEngine sharedEngine]logOutPlatform:LT_SSO_Platform_SinaWeiBo];
    
    //sso调起客户端
    [[LTShareEngine sharedEngine] checkIsInstalledSocialAppForPlatformType:LT_SSO_Platform_SinaWeiBo withBlockFinish:^(BOOL isInstalled) {
        
#ifndef LT_SSOLOGIN_SINA_SUPPORT
        isInstalled=NO;
#endif

        if (isInstalled) {
            LTShareEngine *shareEngine =[LTShareEngine sharedEngine];
            shareEngine.delegate = self;
            [shareEngine logInPlatform:LT_SSO_Platform_SinaWeiBo];
            
        }else
        {
            //调起letv自己的web登陆页面
            thirdPartyviewController = [[LTThirdPartyLoginViewController_iPhone alloc] initWithLoginType:eLoginTypeSinaWeibo];
            thirdPartyviewController.delegate = self;
            [thirdPartyviewController show];

        }
    }];
    
}

#pragma mark - 获取用户信息，用letv token进行letv登陆验证
-(void)processSSOLoginDataInfo:(NSDictionary*)dict withSocialPlatform:(LTSSOLoginPlatformType)type
{
    NSDictionary * beanDict = [dict valueForKeyPath:@"result.bean"];
    NSString * token =[[dict objectForKey:@"result" ]objectForKey:@"sso_tk"];
    NSString * uid = [beanDict valueForKey:@"uid"];
    if (![[NSString safeString:uid] isEqualToString:@""]) {
        [LTDataModelEngine refreshTaskWithUrlModule:LTURLModule_UC_ThirdPartyLogin
                                   andDynamicValues:@[[NSString safeString:token], [DeviceManager getDeviceUUID]]
                                      andHttpMethod:@"GET"
                                      andParameters:nil
                                  completionHandler:^(NSDictionary *responseDic) {
                                      //
                                      if(![NSObject empty:responseDic])
                                      {
                                          NSString *errorCode=[NSString safeString:responseDic[@"errorCode"]];
                                          
                                          if([errorCode isEqualToString:@"1014"])
                                          {
                                              LTStatisticInfo  *statisInfo = [[LTStatisticInfo alloc]init];
                                              statisInfo.acode = LTDCActionCodeShow;
                                              statisInfo.st =  @"0";
                                              statisInfo.pageID = LTDCPageIDUnKnown;
                                              statisInfo.apc = LTDCActionPropertyCategoryLoginFailed;
                                              [LTDataCenter addStatistic:statisInfo];
                                              
                                              
                                              
                                          }
                                      }
                                  } errorHandler:^(NSError *error) {
                                      //
                                  }];
        
        NSString *userName = [beanDict valueForKey:@"nickname"];
        
        [SettingManager setUserCenterPassword:@""];
        [SettingManager setUserCenterTVToken:[NSString safeString:token]];
        [SettingManager setUserCenterUserName:[NSString safeString:userName]];
        
        LTUserCenterEngine *userCenterEngine = [LTUserCenterEngine userCenterEngine];
        
        
        //获取用户信息，用letv token进行letv登陆验证
        [userCenterEngine getUserInfoWithFinishBlock:^(BOOL isSuccess, NSDictionary *feedBack){
            [self removeLoading];
            if (!isSuccess) {
                [[LTUserShowTip shareView] show:YES withText:NSLocalizedString(@"登录失败", nil) isShowIndicator:NO];
                
            }
            else
             {
            [self loginSuccessed:[dict objectForKey:@"result"]];
            [[LTUserShowTip shareView] show:YES withText:NSLocalizedString(@"登录成功", nil) isShowIndicator:NO];
            

            //登陆成功数据统计
            NSString * ref=[LTDataCenter queryRefWithPageid:LTDCPageIDUnKnown fl:LTDCActionPropertyLoginSuccess wz:type+1];
            [LTDataCenter addActionData:LTDCActionCodeClick actionProperty:[NSDictionary dictionaryWithObjectsAndKeys:ref,@"ref",[NSString stringWithFormat:@"%ld",(long)type+1],@"wz", [LTDataCenter getActionCodeByActionCategory:LTDCActionPropertyLoginSuccess],@"fl",nil] actionResult:YES cid:nil pid:nil vid:nil zid:nil currentUrl:nil reid:nil area:nil bucket:nil rank:nil];
            }
        }];
    }else{

        [self removeLoading];
        [[LTUserShowTip shareView] show:YES withText:NSLocalizedString(@"登录失败", nil) isShowIndicator:NO];
    }

}

#pragma mark - 微博sso登陆成功回调,换取letv token
-(void)ltShareEngineSSOLoginAuthSucc:(LTShareEngine *)shareEngine platform:(LTSSOLoginPlatformType)platform userInfo:(NSDictionary *)userInfo
{
    LTSharePlatformUserInfo * user = [userInfo objectForKey:LTShareSSOUserInfoKey];
    NSString * accessToken = [NSString safeString:user.accessToken];
    NSString * userID = [NSString safeString:user.userID];
    NSArray * params = [NSArray arrayWithObjects:accessToken,userID,[DeviceManager getDeviceUUID],nil];
    LTURLModule urlModule=LTURLModule_Unknown;
    [self removeLoading];//移除换取微信token时的loading
    [self showLoadingView];
    
    switch (platform) {
        case LT_SSO_Platform_SinaWeiBo:
        {
            urlModule = LTURLModule_UC_SSOLoginSina;
        }
            break;
        case LT_SSO_Platform_TencentQQ:
        {
            urlModule=LTURLModule_UC_SSOLoginQQ;
        }
            break;
            
        case LT_SSO_Platform_WeiXin:
        {
            urlModule=LTURLModule_UC_SSOLoginWX;
        }
            
            break;
            
        default:
            break;
    }
    [SettingManager saveBoolValueToUserDefaults:YES ForKey:kThirdPartyLogin];
    //用qq、sina、weixin token 换取 letv sso_tk
    [LTDataModelEngine refreshTaskWithUrlModule:urlModule andDynamicValues:params isNeedCache:NO andHttpMethod:@"GET" andParameters:nil completionHandler:^(NSDictionary *bodyDict, NSString *markid) {
        if ([NSObject empty:bodyDict]) {
            [self removeLoading];
            [[LTUserShowTip shareView] show:YES withText:NSLocalizedString(@"登录失败", nil) isShowIndicator:NO];
        }else{
            [self processSSOLoginDataInfo:bodyDict withSocialPlatform:platform];
        }
    } nochangeHandler:^{
        [self removeLoading];
    } emptyHandler:^{
        [self removeLoading];
        [[LTUserShowTip shareView] show:YES withText:NSLocalizedString(@"登录失败", nil) isShowIndicator:NO];
    } tokenExpiredHander:nil errorHandler:^(NSError *error) {
        [self removeLoading];
        [[LTUserShowTip shareView] show:YES withText:NSLocalizedString(@"登录失败", nil) isShowIndicator:NO];
    }];
}

#pragma mark - sso登陆失败回调（目前微信授权用到）
-(void)ltShareEngineSSOLoginAuthFail:(LTShareEngine *)shareEngine platform:(LTSSOLoginPlatformType)platform userInfo:(NSDictionary *)userInfo
{
    [self removeLoading];
    [[LTUserShowTip shareView] show:YES withText:NSLocalizedString(@"授权失败", nil) isShowIndicator:NO];
}

#pragma mark - 开始请求微信token时loading
-(void)ltShareEngineWeixinStartGetToken
{
    [self showLoadingView];
}

#pragma mark - 请求微信token结束时移除loading
-(void)ltShareEngineWeixinStopGetToken
{
    [self removeLoading];
}

-(void)showLoadingView
{
    [self addLoading];
#ifdef LT_IPAD_CLIENT
    _loadingIndicator.frame=self.view.bounds;
    _loadingIndicator.activityIndicatorViewStyle=UIActivityIndicatorViewStyleGray;
    _loadingIndicator.backgroundColor=[UIColor whiteColor];
#endif
   
}


- (void)registerButton:(id)sender{
//    [self addStatisticsWithPosition:4];
    [LTDataCenter addAction:LTDCActionPropertyLoginAccessory position:1 name:nil cid:NewCID_UnDefine pid:nil vid:nil zid:nil pageID:LTDCPageIDLogin currentUrl:nil isSuccess:YES];

    if ([[LeTVAppModule sharedModule] isImplemented])
    {
        [[LeTVAppModule sharedModule] letv_LTPlayerWrapper_playResumeFlagPlayInterruptShare];
    }
    else
    {
        Class obj=NSClassFromString(@"LTPlayerWrapper");
        [obj performSelector:@selector(playResumeFlagPlayInterruptShare)];
    }
    
//    [LTPlayerWrapper playInterrupt:LTPlayInterruptFlagShare];
    
    RegisterViewController_iPhone *viewController=[[RegisterViewController_iPhone alloc]init];
    viewController.thirdDelegate=self;
    if (_loginEntranceType == eLoginEntranceTypeSetting) {
        [self.fatherViewController.navigationController pushViewController:viewController animated:YES];
    }
    else {
        [self.navigationController pushViewController:viewController animated:YES];
    }
}
- (void)forgetButton:(id)sender{
//    [self addStatisticsWithPosition:3];
    [LTDataCenter addAction:LTDCActionPropertyLoginAccessory position:2 name:nil cid:NewCID_UnDefine pid:nil vid:nil zid:nil pageID:LTDCPageIDLogin currentUrl:nil isSuccess:YES];

    FindPasswordViewController_iPhone *viewController=[[FindPasswordViewController_iPhone alloc]init];
    if (_loginEntranceType == eLoginEntranceTypeSetting) {
        [self.fatherViewController.navigationController pushViewController:viewController animated:YES];
    }
    else{
        [self.navigationController pushViewController:viewController animated:YES];
    }
}
- (void)backButtonClicked {
    [self LTSwipeBackAction];
    [self.navigationController popViewControllerAnimated:YES needNotification:YES];
    [LTDataCenter addAction:LTDCActionPropertyLoginGoback position:1 name:nil cid:NewCID_UnDefine pid:nil vid:nil zid:nil pageID:LTDCPageIDLogin currentUrl:nil isSuccess:YES];
}

- (void)LTSwipeBackAction {
    if (self.finishBlock) {
        self.finishBlock(NO);
    }
}

#ifndef LT_IPAD_CLIENT
- (void)dealloc
{
    [self updateRedpackageFloatViewHiddenState:NO];
}
#endif
- (void)login:(id)sender{
    [LTDataCenter addAction:LTDCActionPropertyLoginAction position:1 name:nil cid:NewCID_UnDefine pid:nil vid:nil zid:nil pageID:LTDCPageIDLogin currentUrl:nil isSuccess:YES];

    if ([NSString isBlankString:self.userTextField.text]) {
        [self showAlert:NSLocalizedString(@"请输入乐视帐号", nil)];
        return;
    }
    if ([NSString isBlankString:self.passwordTextField.text]){
        [self showAlert:NSLocalizedString(@"请输入密码", @"请输入密码")];
        return;
    }
    if (![NetworkReachability connectedToNetwork]) {
        [self showAlert:[[LTAlertMsgManager shareAlertManageInstance] getLTAlertMsgByAlertID:LTAlertMsg_Network_LinkError]];
        return;
    }
    
//    [self addStatisticsWithPosition:1];
   
    
    [self.userTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [[LTUserShowTip shareView] show:YES withText:NSLocalizedString(@"登录中...", @"登录中...") isShowIndicator:YES];
    
    LTUserCenterEngine *userCenterEngine = [LTUserCenterEngine userCenterEngine];
    userCenterEngine.delegate = self;
    [userCenterEngine logInWithUserID:self.userTextField.text
                          andPassword:self.passwordTextField.text];
}
- (void)showAlert:(NSString *)message{
    UIAlertView *alert=[[LTAlertView alloc]initWithTitle:@"" message:message delegate:self cancelButtonTitle:NSLocalizedString(@"确定", nil) otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	_editingTextField = textField;
    [UIView animateWithDuration:0.5 animations:^{_contentScrollView.contentOffset=CGPointMake(0, 150);}];
    
    if (textField.text.length == 0) {
        textField.rightViewMode = UITextFieldViewModeNever;
    } else {
        textField.rightViewMode = UITextFieldViewModeAlways;
    }
    CGRect textFieldRect = CGRectZero;
    if (_editingTextField == self.userTextField) {
        textFieldRect = CGRectMake(10, 150 , 300, 44);
    }
    else if (_editingTextField == self.passwordTextField) {
        textFieldRect = CGRectMake(10, 150 + 44, 300, 44);
    }
    [_contentScrollView scrollRectToVisible:textFieldRect animated:NO];
}

- (void) textFieldDidChange:(UITextField *) textField{
    if (textField.text.length == 0) {
        textField.rightViewMode = UITextFieldViewModeNever;
    } else {
        textField.rightViewMode = UITextFieldViewModeAlways;
    }
    if (textField==self.userTextField) {
        if ([textField.text hasSuffix:@"@"]&&_relatedTableView.hidden) {
            [UIView animateWithDuration:0.1 animations:^{
                [_contentScrollView scrollRectToVisible:CGRectMake(10, 150+44 , __MainScreen_Width-20, 90) animated:NO];
                _relatedTableView.hidden=NO;
                _relatedTableView.frame=CGRectMake(10,CGRectGetMinY(self.loginTableView.frame) + 44 - _contentScrollView.contentOffset.y, __MainScreen_Width-20, 90);
            } completion:^(BOOL finished) {
               
                [_relatedTableView reloadData];
                _contentScrollView.scrollEnabled=NO;
            }];
        }else {
            _relatedTableView.hidden=YES;
            _contentScrollView.scrollEnabled=YES;
        }
        
    }
    
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
	_editingTextField = textField;
    textField.rightViewMode = UITextFieldViewModeNever;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.userTextField) {
        [self.passwordTextField becomeFirstResponder];
    }
    else if (textField == self.passwordTextField){
        [textField resignFirstResponder];
        [self login:nil];
    }
    if (_relatedTableView.hidden == NO) {
        _relatedTableView.hidden = YES;
        _contentScrollView.scrollEnabled = YES;
    }
    return YES;
}
#pragma mark - KeyBoardDelegate
- (void)notifyKeyboardWillAppear:(NSNotification*)note
{
    if (_isKeyboardShow) {
        return;
    }
    _isKeyboardShow = YES;
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_3_2
    NSValue *keyboardBoundsValue = [[note userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
#else
    NSValue *keyboardBoundsValue = [[note userInfo] objectForKey:UIKeyboardBoundsUserInfoKey];
#endif
    CGRect keyboardRect = CGRectZero;
    [keyboardBoundsValue getValue:&keyboardRect];
    
    [UIView animateWithDuration:0.25 animations:^{
        CGRect rect = _contentScrollView.frame;
        //rect.origin.y -= keyboardHeight;
        rect.size.height = __MainScreen_Height - 20 - 44 - keyboardRect.size.height;
        _contentScrollView.frame = rect;
        
        CGRect textFieldRect;
        if (_editingTextField == self.userTextField) {
            textFieldRect = CGRectMake(10, 150 , 300, 44);
        }
        else if (_editingTextField == self.passwordTextField) {
            textFieldRect = CGRectMake(10, 150   + 44, 300, 44);
        }
        [_contentScrollView scrollRectToVisible:textFieldRect animated:NO];
    } completion:^(BOOL finished) {
        
    }];
    
    
}
- (void)KeyboardChange:(NSNotification*)note{
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_3_2
    NSValue *keyboardBoundsValue = [[note userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
#else
    NSValue *keyboardBoundsValue = [[note userInfo] objectForKey:UIKeyboardBoundsUserInfoKey];
#endif
    CGRect keyboardRect = CGRectZero;
    [keyboardBoundsValue getValue:&keyboardRect];
    [UIView animateWithDuration:0.25 animations:^{
        CGRect rect = _contentScrollView.frame;
        if (_isKeyboardShow) {
            rect.size.height = __MainScreen_Height - 20 - 44 - keyboardRect.size.height;
        }
        else{
            rect.size.height = __MainScreen_Height - 20 - 44;
        }
        _contentScrollView.frame = rect;
        
        CGRect textFieldRect = CGRectZero;
        if (_editingTextField == self.userTextField) {
            textFieldRect = CGRectMake(10, 150 , 300, 44);
        }
        else if (_editingTextField == self.passwordTextField) {
            textFieldRect = CGRectMake(10, 150 + 44, 300, 44);
        }

        [_contentScrollView scrollRectToVisible:textFieldRect animated:NO];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)notifyKeyboardWillDisappear:(NSNotification*)note
{
    _isKeyboardShow = NO;
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_3_2
    NSValue *keyboardBoundsValue = [[note userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
#else
    NSValue *keyboardBoundsValue = [[note userInfo] objectForKey:UIKeyboardBoundsUserInfoKey];
#endif
    CGRect keyboardRect;
    [keyboardBoundsValue getValue:&keyboardRect];
    [UIView animateWithDuration:0.25 animations:^{
        CGRect rect = _contentScrollView.frame;
        rect.size.height = __MainScreen_Height - 20 - 44 ;
//        rect.origin.y = 0;
        _contentScrollView.frame = rect;
        
    } completion:^(BOOL finished) {
        
    }];
    
}
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == _relatedTableView){
        return 8;
    }
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_relatedTableView==tableView) {
        return 30;
    }
    if (indexPath.row == 0 || indexPath.row == 1) {
        return 44;
    }
    else if (indexPath.row == 2)
    {
        return 97;
    }
    return 0;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == _relatedTableView) {
        static NSString *CellIdentifier = @"relatedCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.backgroundColor = RGBACOLOR(242, 242, 242, 1);
        _relatedTableView.separatorColor = RGBACOLOR(186, 186, 186, 1);
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.textColor = RGBACOLOR(51, 51, 51, 1);
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = [NSString stringWithFormat:@"%@163.com",_userTextField.text];
                break;
            case 1:
                cell.textLabel.text= [NSString stringWithFormat:@"%@sina.com",_userTextField.text];
                break;
            case 2:
                cell.textLabel.text= [NSString stringWithFormat:@"%@qq.com",_userTextField.text];
                break;
            case 3:
                cell.textLabel.text= [NSString stringWithFormat:@"%@sohu.com",_userTextField.text];
                break;
            case 4:
                cell.textLabel.text= [NSString stringWithFormat:@"%@126.com",_userTextField.text];
                break;
            case 5:
                cell.textLabel.text= [NSString stringWithFormat:@"%@gmail.com",_userTextField.text];
                break;
            case 6:
                cell.textLabel.text= [NSString stringWithFormat:@"%@hotmail.com",_userTextField.text];
                break;
            case 7:
                cell.textLabel.text= [NSString stringWithFormat:@"%@yahoo.com",_userTextField.text];
                break;
            default:
                break;
        }
        
        return cell;
        
    }
    else{
        NSString *cellIdentifier = [NSString stringWithFormat:@"loginTableCell%ld",(long)indexPath.row ];
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
        }
        if (indexPath.row == 0) {
            NSString *string = NSLocalizedString(@"帐号", nil);
            CGSize size = [string sizeWithFont:[UIFont systemFontOfSize:15]];
            UILabel *label1 = [UIButtonConstructor createLabelWithText:string
                                                       backgroundColor:[UIColor clearColor]
                                                             textColor:RGBACOLOR(57, 57, 57, 1)
                                                         textAlignment:NSTextAlignmentLeft
                                                                  font:[UIFont systemFontOfSize:15]];
            label1.frame = CGRectMake(15, (44- size.height)/2, size.width, size.height);
            [cell.contentView addSubview:label1];
            size = [NSLocalizedString(@"请输入邮箱", nil) sizeWithFont:[UIFont systemFontOfSize:14]];
            
            self.userTextField = [[LTCommonTextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(label1.frame) + 48, (44-size.height)/2, __MainScreen_Width-CGRectGetMaxX(label1.frame) - 48, size.height)];
            self.userTextField.delegate = self;
            self.userTextField.keyboardType = UIKeyboardTypeEmailAddress;
            self.userTextField.returnKeyType = UIReturnKeyNext;
            self.userTextField.textColor = RGBACOLOR(57, 57, 57, 1);
            [self.userTextField addTarget:self action:@selector(textFieldDidChange:)forControlEvents:UIControlEventEditingChanged];
            self.userTextField.placeholder = NSLocalizedString(@"请输入邮箱/手机号", @"请输入邮箱/手机号");
            [cell.contentView addSubview:self.userTextField];
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(15, 44-0.5, __MainScreen_Width - 15, 0.5)];
            line.backgroundColor = RGBACOLOR(223, 223, 223, 1);
            [cell.contentView addSubview:line]; 
            
            BOOL isThirdPartyLogin = [SettingManager getBoolValueFromUserDefaults:kThirdPartyLogin];
            
            if ([SettingManager userCenterUserName]&&![NSString isBlankString:[SettingManager userCenterUserName]]&&!isThirdPartyLogin) {
                self.userTextField.text = [SettingManager userCenterUserName];
            }
            
        }
        else if (indexPath.row ==1){
            NSString *string = NSLocalizedString(@"密码", nil);
            CGSize size = [string sizeWithFont:[UIFont systemFontOfSize:15]];
            UILabel *label1 = [UIButtonConstructor createLabelWithText:string
                                                       backgroundColor:[UIColor clearColor]
                                                             textColor:RGBACOLOR(57, 57, 57, 1)
                                                         textAlignment:NSTextAlignmentLeft
                                                                  font:[UIFont systemFontOfSize:15]];
            label1.frame = CGRectMake(15, (44- size.height)/2, size.width, size.height);
            [cell.contentView addSubview:label1];
            size = [NSLocalizedString(@"请输入密码", @"请输入密码") sizeWithFont:[UIFont systemFontOfSize:14]];
            self.passwordTextField = [[LTCommonTextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(label1.frame) + 48, (44-size.height)/2, __MainScreen_Width-CGRectGetMaxX(label1.frame) - 48, size.height)];
            
            self.passwordTextField.delegate = self;
            self.passwordTextField.secureTextEntry=YES;
            self.passwordTextField.returnKeyType = UIReturnKeyDone;
            self.passwordTextField.textColor = RGBACOLOR(57, 57, 57, 1);
            self.passwordTextField.placeholder = NSLocalizedString(@"请输入密码", @"请输入密码");
            [cell.contentView addSubview:self.passwordTextField];
            
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 44-0.5, __MainScreen_Width, 0.5)];
            line.backgroundColor = RGBACOLOR(223, 223, 223, 1);
            [cell.contentView addSubview:line];
        }
        else if (indexPath.row == 2){
            LTUIButton *button = [[LTUIButton alloc] initWithFrame:CGRectMake((__MainScreen_Width - 290)/2, 15, 290, 37)];
            button.backgroundColor = [UIColor clearColor];
            [button setBorderColorWithRed:88.f withColorGreen:149.f withColorBlue:237.f];
            button.titleLabel.textAlignment = NSTextAlignmentCenter;
            button.titleLabel.font = [UIFont systemFontOfSize:18];
            [button setTitle:NSLocalizedString(@"登录", nil) forState:UIControlStateNormal];
            [button setTitleColor:kColorDefaultBlue forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            [button setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor] size:button.frame.size] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageWithColor:kColorDefaultBlue size:button.frame.size] forState:UIControlStateHighlighted];
            [button addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:button];
            
            NSString *string = NSLocalizedString(@"立即注册", nil);

            self.registerButton = [UIButtonConstructor createButtonWithFrame:CGRectMake((__MainScreen_Width - 290.0) / 2, CGRectGetMaxY(button.frame) + 2, 159-15, 40) backgroundColor:[UIColor clearColor] text:string textColor:kColorDefaultBlue textAlignment:NSTextAlignmentCenter font:[UIFont systemFontOfSize:15] target:self selector:@selector(registerButton:)];
            [cell.contentView addSubview:self.registerButton];
            
            string = NSLocalizedString(@"忘记密码", @"忘记密码");
            self.forgetButton = [UIButtonConstructor createButtonWithFrame:CGRectMake(CGRectGetMaxX(self.registerButton.frame), CGRectGetMinY(self.registerButton.frame), 159-15, 40) backgroundColor:[UIColor clearColor] text:string textColor:kColorDefaultBlue textAlignment:NSTextAlignmentCenter font:[UIFont systemFontOfSize:15] target:self selector:@selector(forgetButton:)];
            [cell.contentView addSubview:self.forgetButton];
            UIView *centerLine = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.registerButton.frame), 65, 1, 17)];
            centerLine.backgroundColor =RGBACOLOR(223, 223, 223, 1);
            [cell.contentView addSubview:centerLine];
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 97-0.5, __MainScreen_Width, 0.5)];
            line.backgroundColor = RGBACOLOR(223, 223, 223, 1);
            [cell.contentView addSubview:line];
        }
        return cell;
    }

    
}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView==_relatedTableView) {
        _userTextField.text=[tableView cellForRowAtIndexPath:indexPath].textLabel.text;
        _relatedTableView.hidden=YES;
        [_passwordTextField becomeFirstResponder];
        _contentScrollView.scrollEnabled = YES;
    }
}
//#pragma mark - UITextFieldDelegate
//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
//    
//    return NO;
//}
//- (void)textFieldDidBeginEditing:(UITextField *)textField{
//    
//}
//- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
//    return NO;
//}- (void)textFieldDidEndEditing:(UITextField *)textField{
//    
//}
//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
//    return YES;
//}
#pragma mark -
#pragma mark - LTThirdPartyLoginDelegate

- (void)loginSuccessed:(NSDictionary *)dict {
    
//    NSString *token = [dict objectForKey:@"sso_tk"];
    NSDictionary *userInfo = [dict objectForKey:@"bean"];
    if (userInfo != nil) {
        [SettingManager saveIntValueToUserDefaults:1 ForKey:kIsLogin];
        
        
//        [SettingManager setUserCenterUserInfo:userInfo];
        
        
//        NSString *userName = [userInfo objectForKey:@"nickname"];
//        
//        [SettingManager setUserCenterUserName:userName];
//        [SettingManager setUserCenterPassword:@""];
//        [SettingManager setUserCenterTVToken:token];
//        [SettingManager setUserCenterUserName:[NSString safeString:userName]];
        
        if (NEED_CLOUD_FOLLOW) {
            //登录成功，上传本地播放单。
            [HistoryCommand submitToCloudByFavWithFinishBlock:^{
                //[HistoryCommand updateDBWithCloudWithFinishBlock:nil];
            }];
        }
        
        [HistoryCommand commitLocalFav:^{
            nil;
        }];
        
        
        [self performSelector:@selector(loginSuccess:) withObject:userInfo afterDelay:0.0];
        // 登录成功，上报一条login日志
        [LTDataCenter loginToUserCenter];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshUserInfoWithLoginActionNotification object:nil];
    }
}

-(void)loginFailed
{
    
}

//#pragma mark -
//#pragma mark - LTLetvLoginViewControllerDelegate 
//
//- (void)letvLoginSuccess {
//    if ([deleage isKindOfClass:[UserCenterViewController_iPhone class]]) {
//        if ([deleage respondsToSelector:@selector(loginSuccess)]) {
//            [deleage loginSuccess];
//        }
//    }
//}
#pragma mark - LTUserCenterEngineDelegate

- (void)LTUserCenterEngineAlreadyLoggedIn:(LTUserCenterEngine *)engine{
    
    [[LTUserShowTip shareView]close:NO];
}

- (void)LTUserCenterEngineDidLogIn:(LTUserCenterEngine *)engine{
    
    [[LTUserShowTip shareView]close:NO];
    
    NSString *tips=[[LTAlertMsgManager shareAlertManageInstance]getLTAlertMsgByAlertID:LTToastMsg_UserCenter_LoginSuccess];
    [[LTUserShowTip shareView]show:YES withText:tips isShowIndicator:NO];
    
    NSDictionary *userInfo = [SettingManager userCenterUserInfo];
    [self performSelector:@selector(loginSuccess:) withObject:userInfo afterDelay:2.f];
    
    // [SettingManager setUserCenterAutoLoginFlag:(autoLoginBtn.selected)];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshUserInfoWithLoginActionNotification object:nil];
}

- (void)LTUserCenterEngineDidFailToLogIn:(LTUserCenterEngine *)engine WithError:(NSString *)errorMessage{
    
    [[LTUserShowTip shareView] close:NO];
    
    [self showAlert:errorMessage];
}
#pragma mark - 代理
-(void)loginSuccess:(NSDictionary *)dict{
    // 登录成功，上传本地播放记录
    [LTPlayHistoryCommand submitToCloudByRecentWithFinishBlock:^{
        [LTPlayHistoryCommand updateDBWithCloudWithFinishBlock:nil];
    }];
    //登录成功，发送增加积分通知
    [[NSNotificationCenter defaultCenter] postNotificationName:kAddIntegrationNotification object:nil];
    
 #ifndef LT_IPAD_CLIENT
    //春节红包更新信息
    if ([SettingManager isSpringRedPackageOn]) {
        NSString * tm = [NSString stringWithFormat:@"%@",[NSNumber numberWithLongLong:[[NSDate date]timeIntervalSince1970]]];
        NSString * device = [DeviceManager getLetvDeviceUUID];
        NSString * appRunID = [NSString stringWithFormat:@"%@_%@",device,tm];
        
        LeTVRedPackageSDKInfo * info = [LeTVRedPackageSDKInfo registerSDKInfoWithAppCode:kSpringRedPackageLetvAppCode deviceID:[DeviceManager getLetvDeviceUUID] appRunID:appRunID networkType:[NetworkReachability currentNetType]];
        [[LeTVRedPackageSDKManager sharedInstance]ltrp_registerSDKWithAppInfo:info loginToken:[SettingManager userCenterTVToken] userId:[SettingManager getLoginPriorUserId]];
    }
#endif
    
    
    
    if ([deleage respondsToSelector:@selector(isNeedCallJsLogin)]
        && [deleage isNeedCallJsLogin]) {
        // 此时不需要调用JS Login
    }
    else {
        // 如果不是从WebView界面调用的登陆，则调用JS登陆消息
        if (![deleage isKindOfClass:NSClassFromString(@"LTWebViewController_iPhone")]) {
            [LTJSLoginManager shareInstance].delegate = nil;
            [[LTJSLoginManager shareInstance] login];
        }
    }

    if (self.finishBlock) {
        if (self.finishBlock(YES)) {
           return;
        } 
    }
    
    if ([deleage isKindOfClass:NSClassFromString(@"UserCenterViewController_iPhone")]) {
        if ([deleage respondsToSelector:@selector(loginSuccess)]) {
            [deleage loginSuccess];
        }
    }else if ([deleage isKindOfClass:NSClassFromString(@"LTHotVideosViewController_iPhone")]){
        if ([deleage respondsToSelector:@selector(loginSuccess)]) {
            [deleage loginSuccess];
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else if ([deleage isKindOfClass:NSClassFromString(@"LTPayForOrderDetailsViewController")]) {
        if ([deleage respondsToSelector:@selector(loginSuccess)]) {
            [deleage loginSuccess];
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    }
    else if ([deleage isKindOfClass:NSClassFromString(@"LTPayForLetvVIPViewController")]) {
        if ([deleage respondsToSelector:@selector(loginSuccess)]) {
            [deleage loginSuccess];
           // [self.navigationController popViewControllerAnimated:NO];
        }
        
    }else if ([deleage isKindOfClass:NSClassFromString(@"LTSignInWebViewController_iPhone")]) {
        if ([deleage respondsToSelector:@selector(loginSuccess)]) {
            [deleage loginSuccess];
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    }
    else if ([deleage isKindOfClass:NSClassFromString(@"LTWebViewController_iPhone")]) {
        if ([deleage respondsToSelector:@selector(loginSuccess)]) {
            [deleage loginSuccess];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else if ([deleage isKindOfClass:NSClassFromString(@"LT_WoViewController")]){
        if ([deleage respondsToSelector:@selector(loginSuccess)]) {
            [deleage loginSuccess];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else if ([deleage isKindOfClass:NSClassFromString(@"LTRecommendViewController")]){
        //5.5 添加 邀请相关跳转
        if ([deleage respondsToSelector:@selector(loginSuccess)]) {
            [self.navigationController popViewControllerAnimated:NO];
            [deleage loginSuccess];
        }
    }
    else if ([deleage isKindOfClass:NSClassFromString(@"LTLivingPlayerViewController")]){
        if ([deleage respondsToSelector:@selector(loginSuccess)]) {
            [self.navigationController popViewControllerAnimated:NO];
            [deleage loginSuccess];
        }
    }else if ([deleage isKindOfClass:NSClassFromString(@"MyMessageViewController")]){
        if ([deleage respondsToSelector:@selector(loginSuccess)]) {
            [self.navigationController popViewControllerAnimated:NO];
            [deleage loginSuccess];
        }
        
    }else if ([deleage isKindOfClass:NSClassFromString(@"LTStarDetailViewController")]){
        if ([deleage respondsToSelector:@selector(loginSuccess)]) {
           [self.navigationController popViewControllerAnimated:YES];
           [deleage loginSuccess];
        }
        
    }else if ([deleage isKindOfClass:NSClassFromString(@"LTMyVoucherViewController")]){
        if (self.deleage && [self.deleage respondsToSelector:@selector(loginSuccess)]) {
            [self.navigationController popViewControllerAnimated:NO];
            [deleage loginSuccess];
        }
    }else if ([deleage isKindOfClass:NSClassFromString(@"LeTVRedPacketsPopView")]) {
        if (self.deleage && [self.deleage respondsToSelector:@selector(loginSuccess)]) {
            [self.navigationController popViewControllerAnimated:NO];
            [deleage loginSuccess];
        }
    }else {
        for (UIViewController *temp in self.navigationController.viewControllers) {

            if ([temp isKindOfClass:NSClassFromString(@"LTMovieDownloadViewController")]) {
                [self.navigationController popToViewController:temp animated:YES];
                return;
            }
        }
        
        for (UIViewController *temp in self.navigationController.viewControllers) {
            if ([temp isMemberOfClass:NSClassFromString(@"LTMoviePlayerViewController")]) {
//                if ([SettingManager isVipUser]) {
//                    [self.navigationController popToViewController:temp animated:YES];
//                    return;
//                }
//                else{
//                    [self.navigationController popToViewController:temp animated:NO];
//                    [ViewControllerNavManagerHelper navToVipPay:temp];
//                    return;
//                }
                   // [self.navigationController popToViewController:temp animated:YES];
                    [deleage loginSuccess];
                    return;
            }

            if ([temp isKindOfClass:NSClassFromString(@"MyselfViewController_iPhone")]) {
                if ([deleage respondsToSelector:@selector(loginSuccess)]) {
                    [deleage loginSuccess];
                }
                [self.navigationController popToViewController:temp animated:YES];
                
                return;
            }
        }
        [self.navigationController popViewControllerAnimated:YES needNotification:YES];
    }
}
//-(void)loginSuccess:(NSDictionary *)dict {
//    if (_delegate != nil && [_delegate respondsToSelector:@selector(letvLoginSuccess)]) {
//        [self.navigationController popViewControllerAnimated:YES];
//        [_delegate letvLoginSuccess];
//    }
//    else {
//        UIViewController *popToViewController = nil;
//        if ([_popToClassName length] > 0) {
//            NSArray *viewControllers = [self.navigationController viewControllers];
//            
//            for (UIViewController *viewController in viewControllers) {
//                NSString *className = NSStringFromClass([viewController class]);
//                if ([className isEqualToString:_popToClassName]) {
//                    popToViewController = viewController;
//                    break;
//                }
//            }
//        }
//        
//        if (popToViewController != nil) {
//            [self.navigationController popToViewController:popToViewController animated:YES];
//        }
//        else {
//            [self.navigationController popToRootViewControllerAnimated:YES];
//        }
//    }
//    
//    [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshUserInfoWithLoginActionNotification object:nil];
//}


//- (void)addStatisticsWithPosition:(NSInteger)pos
//{
//    [LTDataCenter addAction:LTDCActionPropertyCategoryLetvLoginPage
//                   position:pos
//                       name:nil
//                        cid:NewCID_UnDefine
//                 currentUrl:nil
//                  isSuccess:YES];
//}
#ifndef LT_IPAD_CLIENT
// 更新红包入口状态
- (void)updateRedpackageFloatViewHiddenState:(BOOL)state
{
    UIView * floatView = (UIView*)[[[[UIApplication sharedApplication]delegate] window] viewWithTag:kAppAllPageSpringRedPackageFloatViewTag];
    if (floatView) {
        floatView.hidden = state;
        if (!state) { // 处理登录成功后跳到H5页面仍需要隐藏红包入口
            UINavigationController *nav = [(UIViewController *)[GlobalMethods getRootViewController] navigationController];
            UIViewController *topViewController = nav.topViewController;
            if ([topViewController isKindOfClass:[LTWebViewController_iPhone class]]) {
                floatView.hidden = YES;
            }
        }
    }
}
#endif

@end
#endif
#endif
