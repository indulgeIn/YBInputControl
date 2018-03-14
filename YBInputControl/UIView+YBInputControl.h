//
//  UIView+YBInputControl.h
//  YBInputLimitDemo
//
//  Created by 杨少 on 2018/3/12.
//  Copyright © 2018年 yangbo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

BOOL yb_shouldChangeCharactersIn(id _Nullable target, NSRange range, NSString * _Nullable string);
void yb_textDidChange(id _Nullable target);

typedef NS_ENUM(NSInteger, YBTextControlType) {
    YBTextControlType_none, //无限制
    
    YBTextControlType_number,   //数字
    YBTextControlType_letter,   //字母（包含大小写）
    YBTextControlType_letterSmall,  //小写字母
    YBTextControlType_letterBig,    //大写字母
    YBTextControlType_number_letterSmall,   //数字+小写字母
    YBTextControlType_number_letterBig, //数字+大写字母
    YBTextControlType_number_letter,    //数字+字母
    
    YBTextControlType_excludeInvisible, //去除不可见字符（包括空格、制表符、换页符等）
    YBTextControlType_price,    //价格（小数点后最多输入两位）
};


@interface YBInputControlProfile : NSObject

/**
 限制输入长度，NSUIntegerMax表示不限制（默认不限制）
 */
@property (nonatomic, assign) NSUInteger maxLength;

/**
 限制输入的文本类型（单选，在内部其实是配置了regularStr属性）
 */
@property (nonatomic, assign) YBTextControlType textControlType;

/**
 限制输入的正则表达式字符串
 */
@property (nonatomic, copy, nullable) NSString *regularStr;

/**
 文本变化回调（observer为UITextFiled或UITextView）
 */
@property (nonatomic, copy, nullable) void(^textChanged)(id observe);

/**
 添加文本变化监听
 @param target 方法接收者
 @param action 方法（方法参数为UITextFiled或UITextView）
 */
- (void)addTargetOfTextChange:(id)target action:(SEL)action;



/**
 链式配置方法（对应属性配置）
 */
+ (YBInputControlProfile *)creat;
- (YBInputControlProfile *(^)(YBTextControlType type))set_textControlType;
- (YBInputControlProfile *(^)(NSString *regularStr))set_regularStr;
- (YBInputControlProfile *(^)(NSUInteger maxLength))set_maxLength;
- (YBInputControlProfile *(^)(void (^textChanged)(id observe)))set_textChanged;
- (YBInputControlProfile *(^)(id target, SEL action))set_targetOfTextChange;



//键盘索引和键盘类型，当设置了 textControlType 内部会自动配置，当然你也可以自己配置
@property(nonatomic) UITextAutocorrectionType autocorrectionType;
@property(nonatomic) UIKeyboardType keyboardType;

//取消输入前回调的长度判断
@property (nonatomic, assign, readonly) BOOL cancelTextLengthControlBefore;
//文本变化方法体
@property (nonatomic, strong, nullable, readonly) NSInvocation *textChangeInvocation;

@end


@interface UITextField (YBInputControl) <UITextFieldDelegate>

@property (nonatomic, strong, nullable) YBInputControlProfile *yb_inputCP;

@end


@interface UITextView (YBInputControl) <UITextViewDelegate>

@property (nonatomic, strong, nullable) YBInputControlProfile *yb_inputCP;

@end


NS_ASSUME_NONNULL_END


