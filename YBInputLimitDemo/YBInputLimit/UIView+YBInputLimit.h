//
//  UIView+YBInputLimit.h
//  YBToolsDemo
//
//  Created by cqdingwei@163.com on 2017/7/17.
//  Copyright © 2017年 yangbo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YBInputLimitModel.h"
#import "YBInputLimitConst.h"
#import <objc/runtime.h>

@interface UIView (YBInputLimit) <UITextFieldDelegate, UITextViewDelegate>


/**
 调用方法（限制TextField/TextView的输入、长度，获取文本变化回调）

 @param model 描述限制的模型
 */
- (void)setYBInputLimit:(YBInputLimitModel *)model;

@end
