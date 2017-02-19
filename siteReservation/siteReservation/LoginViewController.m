//
//  Created by Nigel Lee on 19/02/2017.
//  Copyright © 2017 Apress. All rights reserved.
//

#import "LoginViewController.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIControl.h>
#import <UIKit/UIButton.h>
#import <UIKit/UIStringDrawing.h>
#import <UIKit/UIKitDefines.h>

#define USER_ACCOUNT_TAG 101
#define PASSWORD_TAG 102
#define CustomHeight 480
@interface LoginViewController ()




@end

@implementation LoginViewController


- (void)loadView {
    [super loadView];
    
    //    [self.navigationItem setCustomTitle:NSLocalizedString(@"登录", nil)];
    
    // [self addDefaultLeftBarButtonItem:@"" isNeedBack:YES];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    
}

- (void)viewDidLoad
{
    NSString *string = NSLocalizedString(@"立即注册", nil);
    
    self.registerButton = [UIButtonConstructor createButtonWithFrame:CGRectMake((__MainScreen_Width - 290.0) / 2, CGRectGetMaxY(button.frame) + 2, 159-15, 40) backgroundColor:[UIColor clearColor] text:string textColor:kColorDefaultBlue textAlignment:NSTextAlignmentCenter font:[UIFont systemFontOfSize:15] target:self selector:@selector(registerButton:)];
    [self contentView addSubview:self.registerButton];
}


- (void)viewDidAppear:(BOOL)animated
{
    
}



- (void)viewWillAppear:(BOOL)animated
{
    
}

@end

