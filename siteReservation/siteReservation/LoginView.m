//
//  LoginView.m
//  siteReservation
//
//  Created by Nigel Lee on 19/02/2017.
//  Copyright © 2017 Apress. All rights reserved.
//

#import "LoginView.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIControl.h>
#import <UIKit/UIButton.h>
#import <UIKit/UIStringDrawing.h>
#import <UIKit/UIKitDefines.h>
#import "Global.h"

#define USER_ACCOUNT_TAG 101
#define PASSWORD_TAG 102
#define CustomHeight 480

@interface LoginView ()

@property (nonatomic, strong) UIButton *registerButton;
@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) UIButton *forgetButton;

@property (nonatomic, strong) UIButton *qqLoginButton;
@property (nonatomic, strong) UIButton *sinaLoginButton;
@property (nonatomic, strong) UIButton *weixinLoginButton;
@property (nonatomic, strong) UIView *thirdLoginView;
@property (nonatomic, strong) UITableView *loginTableView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UITextField *userTextField;
@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, strong) UIImageView *imageview;
@end

@implementation LoginView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        // Initialization code
        [self loadView];
        [self hostVsView];
    }
    return self;
}

- (void)loadView
{
    self.imageview=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    self.imageview.image=[UIImage imageNamed:@"bg_480"];
    [self addSubview:self.imageview];
    
     NSString *tips = NSLocalizedString(@"立即注册", nil);
    self.registerButton = [[UIButton alloc] initWithFrame:CGRectMake((__MainScreen_Width - 290.0), __MainScreen_Height + 120, 159-15, 40)];
    [self.registerButton addTarget:self
                        action:@selector(registerAction:)
              forControlEvents:UIControlEventEditingChanged];
    [self.registerButton setTitle:tips forState:UIControlStateNormal];//设置button的title
    self.registerButton.titleLabel.font = [UIFont systemFontOfSize:16];//title字体大小
    self.registerButton.titleLabel.textAlignment = NSTextAlignmentCenter;//设置title的字体居中
    [self.registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];//设置title在一般情况下为白色字体
    [self.registerButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];//设置title在button被选中情况下为灰色字体
    
    

//backgroundColor:[UIColor clearColor] text:string textColor:kColorDefaultBlue textAlignment:NSTextAlignmentCenter font:[UIFont systemFontOfSize:15] target:self selector:@selector(registerButton:)];
//    
//    self.registerButton = [UIButtonConstructor createButtonWithFrame:CGRectMake((__MainScreen_Width - 290.0) / 2, CGRectGetMaxY(button.frame) + 2, 159-15, 40) backgroundColor:[UIColor clearColor] text:string textColor:kColorDefaultBlue textAlignment:NSTextAlignmentCenter font:[UIFont systemFontOfSize:15] target:self selector:@selector(registerButton:)];
//    [cell.contentView addSubview:self.registerButton];
    
    
}
- (void)resetFrame:(CGRect)frame isZoomOut:(BOOL)isZoomOut
{
    CGFloat viewheight;
    if (isZoomOut) {
        
        if (iPhone6plus) {
//            viewheight = 48 + 64;
        } else if (iPhone6) {
//            viewheight = 38 + 64;
        } else {
//            viewheight = 18 + 64;
        }
    }
}


- (void)hostVsView
{
    self.view = [[UIView alloc]initWithFrame:CGRectMake((SCRREN_PORTRAIT_WIDTH-148)/2, 18, 148, 50)];
    self.view.backgroundColor=[UIColor clearColor];
    self.lefticon=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 49, 50)];
    
    self.righticon=[[UIImageView alloc]initWithFrame:CGRectMake(99, 0, 49, 50)];
    
    CGSize size = [@"VS" sizeWithFont:[UIFont systemFontOfSize:20]];
    UILabel * centericon=[[UILabel alloc]initWithFrame:CGRectMake(62, 15, size.width, size.height)];
    centericon.backgroundColor=[UIColor clearColor];
    [centericon setFont:[UIFont systemFontOfSize:20]];
    centericon.text=@"VS";
    [self.view addSubview:self.lefticon];
    [self.view addSubview:centericon];
    [self.view addSubview:self.righticon];
    [self addSubview:self.view];
    
    self.lab=[[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.view.frame)+12, SCRREN_PORTRAIT_WIDTH, 12)];
    self.lab.backgroundColor=[UIColor clearColor];
    self.lab.font=[UIFont systemFontOfSize:12.f];
    self.lab.textAlignment=NSTextAlignmentCenter;
    self.lab.textColor=[UIColor whiteColor];
    self.lab.alpha=0.7f;
    
    [self addSubview:self.lab];
    
    self.pricelab=[[OHAttributedLabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.lab.frame)+8, SCRREN_PORTRAIT_WIDTH, 29)];
    self.pricelab.backgroundColor=[UIColor clearColor];
    [self addSubview:self.pricelab];
    
    self.btnview = [[UIView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(self.pricelab.frame), 300, 40)];
    self.btnview.backgroundColor=[UIColor clearColor];
    [self addSubview:self.btnview];
    self.leftbtn =[UIButton buttonWithType:UIButtonTypeCustom];
    //self.leftbtn.frame=CGRectMake(10, CGRectGetMaxY(self.pricelab.frame), 0, 0);
    self.leftbtn.frame=CGRectMake(10, 0, 0, 0);
    [self.leftbtn setTitle:NSLocalizedString(@"已订购请登录", @"已订购请登录") forState:UIControlStateNormal];
    self.leftbtn.titleLabel.font=[UIFont systemFontOfSize:13.f];
    [self.leftbtn setBackgroundImage:[UIImage LeTVMobilePlayerBundleImageName:@"btu-lvse"] forState:UIControlStateNormal];
    [self.btnview addSubview:self.leftbtn];
    
    self.rightbtn=[UIButton buttonWithType:UIButtonTypeCustom];
    //    self.rightbtn.frame=CGRectMake((SCRREN_PORTRAIT_WIDTH-(SCRREN_PORTRAIT_WIDTH-30)/2)-20+10, CGRectGetMaxY(self.pricelab.frame), (SCRREN_PORTRAIT_WIDTH-30)/2, 40);
    self.rightbtn.frame=CGRectMake((SCRREN_PORTRAIT_WIDTH-(SCRREN_PORTRAIT_WIDTH-30)/2)-20+10, 0, (SCRREN_PORTRAIT_WIDTH-30)/2, 40);
    [self.rightbtn setTitle:NSLocalizedString(@"立即订购", @"立即订购") forState:UIControlStateNormal];
    self.rightbtn.titleLabel.font=[UIFont systemFontOfSize:13.f];
    [self.rightbtn setBackgroundImage:[UIImage LeTVCommonBundleName:@"btn_fufei"] forState:UIControlStateNormal];
    [self.btnview addSubview:self.rightbtn];
   
}

- (void)addChangeMoneyTarget:(nullable id)target action:(nullable SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    [_duiHuanButton addTarget:target action:action forControlEvents:controlEvents];
}

- (void)registerAction:(id)sender
{
    
}





@end
