//
//  ViewController.m
//  YBInputLimitDemo
//
//  Created by cqdingwei@163.com on 2017/7/18.
//  Copyright © 2017年 yangbo. All rights reserved.
//

#import "ViewController.h"
#import "UIView+YBInputLimit.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITextField *textfield = [UITextField new];
    textfield.placeholder = @"请输入内容";
    textfield.frame = CGRectMake(20, 100, 300, 50);
    [self.view addSubview:textfield];
    
    
    //* 注意1：由于点击联想输入在输入之前无法监听，也就无法精确控制输入字符，所以如果不是输入描述性语言的情况下，建议把联想输入关闭
    textfield.autocorrectionType = UITextAutocorrectionTypeNo;
    //* 注意2：由于中文输入状态自带联想，所以如果不用输入中文，请设置键盘让用户无法切换到中文输入状态
    textfield.keyboardType = UIKeyboardTypeASCIICapable;
    
    
    //* 一句代码实现
    [textfield setYBInputLimit:YBInputLimitModel
     .initialization
     .setInputLimitType(YBInputLimitType_numbers|YBInputLimitType_lettersSmall)
     .setMaxLength(10)
     .setTextChanged(^(UITextField *observe){

        NSLog(@"textchange : %@", observe.text);
    })];
    
//    //* 常规实现
//    YBInputLimitModel *model = [YBInputLimitModel new];
//    model.inputLimitType = YBInputLimitType_numbers|YBInputLimitType_lettersSmall;
//    model.maxLength = 10;
//    [model setTextChanged:^(id observe){
//        
//    }];
//    [textfield setYBInputLimit:model];
//    
//    
//    //* 不使用block
//    [textfield setYBInputLimit:YBInputLimitModel
//     .initialization
//     .setInputLimitType(YBInputLimitType_numbers|YBInputLimitType_lettersSmall)
//     .setMaxLength(10)
//     .addTargetAndAction(self, @selector(sel0:))];
//    
//    
//    //* 不使用block
//    YBInputLimitModel *model = [YBInputLimitModel new];
//    model.inputLimitType = YBInputLimitType_numbers|YBInputLimitType_lettersSmall;
//    model.maxLength = 10;
//    [model addTargetOfTextChange:self action:@selector(sel0:)];
//    [textfield setYBInputLimit:model];
//    
//    
//    //* 直接输入正则
//    [textfield setYBInputLimit:YBInputLimitModel.initialization.setRegularStr(@"^[0-9]+$")];
}

- (void)sel0:(id)target {
    UITextField *tf = (UITextField *)target;
    NSLog(@"sel0 : %@", tf.text);
}


@end
