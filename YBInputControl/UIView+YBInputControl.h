//
//  UIView+YBInputControl.h
//  YBInputLimitDemo
//
//  Created by 杨少 on 2018/3/12.
//  Copyright © 2018年 yangbo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, YBTextControlType) {
    YBTextControlType_none = 0,  //无限制
    YBTextControlType_numbers = 1 << 0,  //数字
    YBTextControlType_lettersSmall = 1 << 1, //小写字母
    YBTextControlType_lettersBig = 1 << 2,   //大写字母
    YBTextControlType_price = 1 << 3,    //价格（小数点后最多输入两位）
    YBTextControlType_custom = 1 << 4,    //自定义
};


@interface YBInputControlProfile : NSObject

/**
 限制输入长度，NSUIntegerMax表示不限制（默认不限制）
 */
@property (nonatomic, assign) NSUInteger maxLength;

/**
 限制输入的文本类型（可多选）
 */
@property (nonatomic, assign) YBTextControlType textControlType;

/**
 限制输入的正则表达式字符串
 */
@property (nonatomic, copy, nullable) NSString *regularStr;

/**
 文本变化回调（observer为UITextFiled或UITextView）
 */
- (void)setTextChanged:(void (^)(id observer))textChanged;
- (void (^)(id))textChanged;

/**
 添加文本变化监听
 @param target 方法接收者
 @param action 方法（方法参数为UITextFiled或UITextView）
 */
- (void)addTargetOfTextChange:(id)target action:(SEL)action;
@property (nonatomic, strong, nullable) NSInvocation *textChangeInvocation;


/**
 链式配置方法（对应属性配置）
 */
+ (YBInputControlProfile *)creat;
- (YBInputControlProfile *(^)(YBTextControlType type))set_textControlType;
- (YBInputControlProfile *(^)(NSString *regularStr))set_regularStr;
- (YBInputControlProfile *(^)(NSUInteger maxLength))set_maxLength;
- (YBInputControlProfile *(^)(void (^textChanged)(id observe)))set_textChanged;
- (YBInputControlProfile *(^)(id target, SEL action))set_targetOfTextChange;

@end


@interface UITextField (YBInputControl) <UITextFieldDelegate>

@property (nonatomic, strong, nullable) YBInputControlProfile *yb_inputCP;

@end


@interface UITextView (YBInputControl) <UITextViewDelegate>

@property (nonatomic, strong, nullable) YBInputControlProfile *yb_inputCP;

@end


NS_ASSUME_NONNULL_END


