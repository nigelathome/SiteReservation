//
//  LoginViewController_iPhone.h
//  LetvIphoneClient
//
//  Created by 鹏飞 季 on 12-8-21.
//  Copyright (c) 2012年 乐视网. All rights reserved.
//

#import <LeTVMobileFoundation/LeTVMobileFoundation.h>
#import <LetvMobileUserCenter/LetvMobileUserCenter.h>
#ifndef LT_MERGE_FROM_IPAD_CLIENT
#import <UIKit/UIKit.h>
//#import "CommonViewController_iPhone.h"
#import "LTThirdPartyLoginViewController_iPhone.h"
//#import <LeTVMobileShare/LeTVMobileShare.h>
#import <LetvMobileInterfaces/LetvMobileInterfaces.h>


@interface LoginViewController_iPhone : CommonViewController_iPhone
<
LTThirdPartyLoginDelegate,
LTUserCenterEngineDelegate,
LTShareEngineInterfaceDelegate
>
{
    LTThirdPartyLoginViewController_iPhone *thirdPartyviewController;
}

- (id)initWithEntranceType:(LoginEntranceType)_entranceType;

- (instancetype)initWithLoginFinishBlock:(LTLoginFinishBlock)finishBlock;

@property (nonatomic, weak) id<LoginViewControllerDelegate> deleage;
@property (nonatomic, copy) LTLoginFinishBlock finishBlock;
@property (nonatomic, assign) LoginEntranceType loginEntranceType;
@end
#else
//
//  LoginViewController_iPhone.h
//  LetvIphoneClient
//
//  Created by 鹏飞 季 on 12-8-21.
//  Copyright (c) 2012年 乐视网. All rights reserved.
//

#import <LeTVMobileFoundation/LeTVMobileFoundation.h>
#import <LetvMobileUserCenter/LetvMobileUserCenter.h>
#ifndef LT_MERGE_FROM_IPAD_CLIENT
#import <UIKit/UIKit.h>
//#import "CommonViewController_iPhone.h"
#import "LTThirdPartyLoginViewController_iPhone.h"
#import "LTLetvLoginViewController_iphone.h"
#import <LeTVMobileShare/LeTVMobileShare.h>

typedef enum LoginEntranceType {
    eLoginEntranceTypeSetting = 1,   // 从设置页进入
    eLoginEntranceTypeMyself = 2,    // 从个人页面进入
    eLoginEntranceTypePayForVip = 3, // 从会员支付界面进入
    eLoginEntranceTypeLivingPlayer = 4, // 从直播播放页进入
    eLoginEntranceTypeMovieDownload = 5, // 从添加下载页进入
    eLoginEntranceTypeHotMovie = 6,  //  从热点界面进入
    eLoginEntranceTypeCheckin  = 7, //从签到抽奖进入的h5界面进入。
    eLoginEntranceTypeWoOrder  = 8, //从联通流量包订购页面进入。
    eLoginEntranceTypeWebView  = 9,  //从webview页面进入到登录
    eLoginEntranceTypePlayHistory = 10, // 从播放记录进入
    eLoginEntranceTypeFav = 11 ,//superZ
    eLoginEntranceTypeConcern = 12,   //从我的关注页
    eLoginEntranceTypeMyMessage = 13, //从我的消息页
    eLoginEntranceTypeStar = 14, //明星页进入
    eLoginEntranceTypeMyVoucher = 15, //从我的观影券进入
    eLoginEntranceTypeRedPacket = 16    // 从红包弹出视图进入
}LoginEntranceType;


typedef BOOL(^LTLoginFinishBlock)(BOOL isSuccess);

@protocol LoginViewControllerDelegate <NSObject>

- (void)loginSuccess;

@optional
- (BOOL)isNeedCallJsLogin;

@end

@interface LoginViewController_iPhone : CommonViewController_iPhone
<
LTThirdPartyLoginDelegate,
LTUserCenterEngineDelegate,
LTShareEngineDelegate
>
{
    LTThirdPartyLoginViewController_iPhone *thirdPartyviewController;
}

- (id)initWithEntranceType:(LoginEntranceType)_entranceType;

- (instancetype)initWithLoginFinishBlock:(LTLoginFinishBlock)finishBlock;

@property (nonatomic, weak) id<LoginViewControllerDelegate> deleage;
@property (nonatomic, copy) LTLoginFinishBlock finishBlock;
@property (nonatomic, assign) LoginEntranceType loginEntranceType;
@end
#endif
#endif
