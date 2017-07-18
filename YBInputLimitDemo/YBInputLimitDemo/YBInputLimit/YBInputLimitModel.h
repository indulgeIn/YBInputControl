//
//  YBInputLimitModel.h
//  YBToolsDemo
//
//  Created by cqdingwei@163.com on 2017/7/17.
//  Copyright © 2017年 yangbo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YBInputLimitConst.h"

@interface YBInputLimitModel : NSObject

//***  注意：本类方法属性都为可选（包括链式语法）

/**
 限制的长度（NSUIntegerMax表示不限制）
 */
@property (nonatomic, assign) NSUInteger maxLength;

/**
 限制的类型（可多选）
 */
@property (nonatomic, assign) YBInputLimitType inputLimitType;

/**
 限制的正则表达式字符串
 */
@property (nonatomic, copy) NSString *regularStr;

/**
 text值变化的block
 */
@property (nonatomic, copy) void(^textChanged)(id observe);

/**
 添加文本变化监听
 
 @param target 方法接收者
 @param action 方法
 */
- (void)addTargetOfTextChange:(id)target action:(SEL)action;




/**
 链式配置方法（对应属性配置）

 @return -
 */
+ (YBInputLimitModel *)initialization;
- (YBInputLimitModel *(^)(YBInputLimitType inputLimitType))setInputLimitType;
- (YBInputLimitModel *(^)(NSString *regularStr))setRegularStr;
- (YBInputLimitModel *(^)(NSUInteger maxLength))setMaxLength;
- (YBInputLimitModel *(^)(void(^textChanged)(id observe)))setTextChanged;
- (YBInputLimitModel *(^)(id target, SEL action))addTargetAndAction;






/**
 存储方法操作（建议不要直接赋值）
 */
@property (nonatomic, strong) NSInvocation *textChangeInvocation;



@end
