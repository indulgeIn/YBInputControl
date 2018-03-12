//
//  ViewController.m
//  YBInputLimitDemo
//
//  Created by cqdingwei@163.com on 2017/7/18.
//  Copyright © 2017年 yangbo. All rights reserved.
//

#import "ViewController.h"
#import "UIView+YBInputLimit.h"
#import "UIView+YBInputControl.h"


@interface ViewController () <UITextFieldDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITextField *textfield = [UITextField new];
    textfield.placeholder = @"请输入内容";
    textfield.frame = CGRectMake(20, 100, 300, 50);
    [self.view addSubview:textfield];
    
    //* 注意1：由于点击联想输入在输入之前无法监听，也就无法精确控制输入字符，所以如果不是输入描述性语言的情况下，建议把联想输入关闭
//    textfield.autocorrectionType = UITextAutocorrectionTypeNo;
    //* 注意2：由于中文输入状态自带联想，所以如果不用输入中文，请设置键盘让用户无法切换到中文输入状态
//    textfield.keyboardType = UIKeyboardTypeASCIICapable;
    
    
//    YBInputControlProfile *profile = [YBInputControlProfile new];
//    [profile setTextChanged:^(id  _Nonnull observer) {
//        NSLog(@"%@", [observer valueForKey:@"text"]);
//    }];
//    [profile addTargetOfTextChange:self action:@selector(sel0:)];
    
//    textfield.yb_inputCP = YBInputControlProfile.creat.set_maxLength(4).set_textControlType(YBTextControlType_numbers).set_textChanged(^(id obj){
//        NSLog(@"%@", [obj valueForKey:@"text"]);
//    });
    
    textfield.yb_inputCP = YBInputControlProfile.creat.set_maxLength(10).set_textControlType(YBTextControlType_lettersBig).set_targetOfTextChange(self, @selector(sel0:));
    textfield.delegate = self;
    
    

}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    NSLog(@"vc: %@", NSStringFromSelector(_cmd));
    return YES;
}



- (void)sel0:(id)sender {
    NSLog(@"sel0 : %@", [sender valueForKey:@"text"]);
}


@end
