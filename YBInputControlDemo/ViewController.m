//
//  ViewController.m
//  YBInputControlDemo
//
//  Created by 杨少 on 2018/3/13.
//  Copyright © 2018年 杨波. All rights reserved.
//

#import "ViewController.h"
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
    
//* 注意1：如果不是输入描述性文本的情况下，建议把联想输入关闭（联想输入在输入之前无法监听，无法精确控制输入字符）
    textfield.autocorrectionType = UITextAutocorrectionTypeNo;
//* 注意2：如果不用输入中文，请设置键盘让用户无法切换到中文输入状态（由于中文输入状态自带联想）
    textfield.keyboardType = UIKeyboardTypeASCIICapable;
    
    
    //链式语法使用
//    textfield.yb_inputCP = YBInputControlProfile.creat.set_maxLength(10).set_textControlType(YBTextControlType_lettersBig|YBTextControlType_lettersSmall).set_textChanged(^(id obj){
//        NSLog(@"%@", [obj valueForKey:@"text"]);
//    });
    
    
    //常规方法使用
    YBInputControlProfile *profile = [YBInputControlProfile new];
    profile.maxLength = 10;
//    profile.regularStr = @"^[a-z]*$";
    profile.textControlType = YBTextControlType_numbers;
    [profile addTargetOfTextChange:self action:@selector(textChange:)];
    textfield.yb_inputCP = profile;
    

    //取消功能
//    textfield.yb_inputCP = nil;
    
    
    //同样可以设置代理
    textfield.delegate = self;
    //特别注意
    //在给textField或textView设置了非自身的delegate，若实现了如下方法，将覆盖本框架的输入实时限制功能（长度限制功能基本有效）：
//    - (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
//    - (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
    
}

#pragma mark UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
}

#pragma mark event
- (void)textChange:(UITextField *)tf {
    NSLog(@"%@", [tf valueForKey:@"text"]);
}


@end



