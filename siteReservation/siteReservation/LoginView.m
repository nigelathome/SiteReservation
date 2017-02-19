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

@property (nonatomic, strong) UITableView *relatedTableView;

@end

@implementation LoginView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/



@end
