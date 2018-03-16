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
    
    //* 注意1：如果不是输入描述性文本的情况下，建议把联想输入关闭（联想输入在输入之前无法监听，无法精确控制输入字符）
    //    .autocorrectionType = UITextAutocorrectionTypeNo;
    //* 注意2：如果不用输入中文，请设置键盘让用户无法切换到中文输入状态（由于中文输入状态自带联想）
    //    .keyboardType = UIKeyboardTypeASCIICapable;
    
#pragma mark UITextField 的使用
    UITextField *textfield = [UITextField new];
    textfield.backgroundColor = [UIColor orangeColor];
    textfield.textColor = [UIColor whiteColor];
    textfield.frame = CGRectMake(20, 100, [UIScreen mainScreen].bounds.size.width-40, 44);
    [self.view addSubview:textfield];
  
    
    
    //链式语法使用
//    textfield.yb_inputCP = YBInputControlProfile.creat.set_maxLength(10).set_textControlType(YBTextControlType_letter).set_textChanged(^(id obj){
//        NSLog(@"%@", [obj valueForKey:@"text"]);
//    });
    
    //常规方法使用
    YBInputControlProfile *profile = [YBInputControlProfile new];
    profile.maxLength = 10;
    profile.textControlType = YBTextControlType_letter;
    [profile addTargetOfTextChange:self action:@selector(textChange:)];
    textfield.yb_inputCP = profile;
//    profile.regularStr = @"^[a-z]*$";
 
    //取消功能
    //textfield.yb_inputCP = nil;
    
    //同样可以按照以往的习惯，设置代理
    textfield.delegate = self;
    //** 特别注意
    //在给textField或者textView设置了非自身的delegate，若实现了如下方法，将可能覆盖本框架的输入实时限制功能，对应可能会覆盖的函数是：
//    - (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
//    - (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
    
    
#pragma mark UITextView 的使用
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(20, 200, [UIScreen mainScreen].bounds.size.width-40, 300)];
    textView.font = [UIFont systemFontOfSize:14];
    textView.backgroundColor = [UIColor orangeColor];
    textView.textColor = [UIColor whiteColor];
    [self.view addSubview:textView];
    
    textView.yb_inputCP = YBInputControlProfile.creat.set_textControlType(YBTextControlType_none).set_maxLength(20).set_textChanged(^(id obj){
        NSLog(@"%@", [obj valueForKey:@"text"]);
    });
    textView.delegate = self;
}

#pragma mark UITextFieldDelegate
//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//    //如果你仍然想要框架的实时判断输入功能，需要调用一个共有函数
//    return yb_shouldChangeCharactersIn(textField, range, string);
//}
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

#pragma mark UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    return yb_shouldChangeCharactersIn(textView, range, text);
}
- (void)textViewDidChange:(UITextView *)textView {
    yb_textDidChange(textView);
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    return YES;
}


#pragma mark event
- (void)textChange:(id)obj {
    NSLog(@"%@", [obj valueForKey:@"text"]);
}


@end



