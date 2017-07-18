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
    textfield.frame = CGRectMake(20, 100, 200, 50);
    [self.view addSubview:textfield];
    
    
    //* 一句代码实现
    [textfield setYBInputLimit:YBInputLimitModel
     .initialization
     .setInputLimitType(YBInputLimitType_numbers|YBInputLimitType_lettersSmall)
     .setMaxLength(10)
     .setTextChanged(^(id observe){
        
    })];
    
    //* 不使用block
//    [textfield setYBInputLimit:YBInputLimitModel
//     .initialization
//     .setInputLimitType(YBInputLimitType_numbers|YBInputLimitType_lettersSmall)
//     .setMaxLength(10)
//     .addTargetAndAction(self, @selector(sel0:))];
    
    
    
    
    //* 常规实现
//    YBInputLimitModel *model = [YBInputLimitModel new];
//    model.inputLimitType = YBInputLimitType_numbers|YBInputLimitType_lettersSmall;
//    model.maxLength = 10;
//    [model setTextChanged:^(id observe){
//        
//    }];
//    [textfield setYBInputLimit:model];
    
    //* 不使用block
//    YBInputLimitModel *model = [YBInputLimitModel new];
//    model.inputLimitType = YBInputLimitType_numbers|YBInputLimitType_lettersSmall;
//    model.maxLength = 10;
//    [model addTargetOfTextChange:self action:@selector(sel0:)];
//    [textfield setYBInputLimit:model];
}

- (void)sel0:(id)target {
    UITextField *tf = (UITextField *)target;
    NSLog(@"sel0 : %@", tf.text);
}


@end
