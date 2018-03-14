//
//  ViewController.m
//  YBInputControlDemo
//
//  Created by 杨少 on 2018/3/13.
//  Copyright © 2018年 杨波. All rights reserved.
//

#import "ViewController.h"
#import "UIView+YBInputControl.h"

@interface ViewController () <UITextFieldDelegate, UITextViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITextField *textfield = [UITextField new];
    textfield.placeholder = @"请输入内容";
    textfield.frame = CGRectMake(20, 100, 300, 50);
    [self.view addSubview:textfield];
    
    
//* 注意1：如果不是输入描述性文本的情况下，建议把联想输入关闭（联想输入在输入之前无法监听，无法精确控制输入字符）
//    textfield.autocorrectionType = UITextAutocorrectionTypeNo;
//* 注意2：如果不用输入中文，请设置键盘让用户无法切换到中文输入状态（由于中文输入状态自带联想）
//    textfield.keyboardType = UIKeyboardTypeASCIICapable;
    
    
    //链式语法使用
//    textfield.yb_inputCP = YBInputControlProfile.creat.set_maxLength(10).set_textControlType(YBTextControlType_lettersBig|YBTextControlType_lettersSmall).set_textChanged(^(id obj){
//        NSLog(@"%@", [obj valueForKey:@"text"]);
//    });
    

    //常规方法使用
    YBInputControlProfile *profile = [YBInputControlProfile new];
    profile.maxLength = 10;
    //也可以直接使用使用正则表达式
    //profile.regularStr = @"^[a-z]*$";
    profile.textControlType = YBTextControlType_lettersBig;
    [profile addTargetOfTextChange:self action:@selector(textChange:)];
    textfield.yb_inputCP = profile;
    


    
    //取消功能
    //textfield.yb_inputCP = nil;
    
    
    //同样可以按照以往的习惯，设置代理
//    textfield.delegate = self;
    //特别注意
    //在给textField设置了非自身的delegate，若实现了如下方法，将覆盖本框架的输入实时限制功能（长度限制功能基本有效）：
//    - (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;

    
    
    
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(20, 200, 400, 300)];
    [self.view addSubview:textView];
    textView.yb_inputCP = YBInputControlProfile.creat.set_textControlType(YBTextControlType_numbers).set_maxLength(10);
}


#pragma mark UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
}



#pragma mark event
- (void)textChange:(UITextField *)tf {
    NSLog(@"%@", [tf valueForKey:@"text"]);
}


@end



