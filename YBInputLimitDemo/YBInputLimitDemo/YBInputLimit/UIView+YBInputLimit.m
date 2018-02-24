//
//  UIView+YBInputLimit.m
//  YBToolsDemo
//
//  Created by cqdingwei@163.com on 2017/7/17.
//  Copyright © 2017年 yangbo. All rights reserved.
//

#import "UIView+YBInputLimit.h"

@implementation UIView (YBInputLimit)

- (void)setYBInputLimit:(YBInputLimitModel *)model {
    if (model&&[model isKindOfClass:[YBInputLimitModel class]]) {
        [self setValue:model forKey:keyYBTextInputLimit];
    }
}

-(id)valueForUndefinedKey:(NSString *)key {
    BOOL judgeType = [key isEqualToString:keyYBTextInputLimit] && ([self isKindOfClass:[UITextField class]] || [self isKindOfClass:[UITextView class]]);
    if (judgeType) {
        return objc_getAssociatedObject(self, key.UTF8String);
    }
    return nil;
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:keyYBTextInputLimit]) {
        
        if ([self isKindOfClass:[UITextField class]]) {
            UITextField *tf = (UITextField *)self;
            tf.delegate = self;
            YBInputLimitModel *limitModel = value;
            limitModel.textChangeInvocation||limitModel.textChanged?[tf addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged]:nil;
        } else if ([self isKindOfClass:[UITextView class]]) {
            UITextView *tv = (UITextView *)self;
            tv.delegate = self;
        }
        
        objc_setAssociatedObject(self, key.UTF8String, value, OBJC_ASSOCIATION_RETAIN);
    }
}


#pragma mark *** for textview ***

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    return [self logic_context:textView range:range string:text];
}
- (void)textViewDidChange:(UITextView *)textView {
    [self logic_textChangeWithObserve:textView];
}

#pragma mark *** for textfield ***

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return [self logic_context:textField range:range string:string];
}
- (void)textFieldDidChange:(UITextField *)textField {
    [self logic_textChangeWithObserve:textField];
}

#pragma mark *** 工具方法 ***

- (void)logic_textChangeWithObserve:(id)observe {
    
    if (!observe) {
        return;
    }
    
    YBInputLimitModel *limitModel = [observe valueForKey:keyYBTextInputLimit];
    if (limitModel.maxLength != NSUIntegerMax) {
        NSString *text = [observe valueForKey:@"text"];
        if (text.length > limitModel.maxLength) {
            [observe setValue:[text substringToIndex:limitModel.maxLength] forKey:@"text"];
        }
    }
    if (limitModel.textChangeInvocation) {
        UIView *selfObject = self;
        [limitModel.textChangeInvocation setArgument:&selfObject atIndex:2];
        [limitModel.textChangeInvocation invoke];
    }
    if (limitModel.textChanged) {
        limitModel.textChanged(observe);
    }
}

- (BOOL)logic_context:(id)context range:(NSRange)range string:(NSString *)string {
    
    //找不到配置的model
    if (![context valueForKey:keyYBTextInputLimit]) {
        return YES;
    }
    
    //获取配置的model
    YBInputLimitModel *limitModel = [context valueForKey:keyYBTextInputLimit];
    
    //判断上下文类型
    NSString *nowStr = @"";
    if ([context isKindOfClass:[UITextField class]]) {
        UITextField *tf = (UITextField *)context;
        nowStr = tf.text;
    } else if ([context isKindOfClass:[UITextView class]]) {
        UITextView *tv = (UITextView *)context;
        nowStr = tv.text;
    } else {
        return YES;
    }
    
    //计算结果字符串
    NSMutableString *resultStr = [NSMutableString stringWithString:nowStr];
    if (string.length == 0) {
        [resultStr deleteCharactersInRange:range];
    } else {
        if (range.length == 0) {
            [resultStr insertString:string atIndex:range.location];
        } else {
            [resultStr replaceCharactersInRange:range withString:string];
        }
    }
    
    //长度限制
    if (limitModel.maxLength != NSUIntegerMax) {
        if (resultStr.length > limitModel.maxLength) {
            return NO;
        }
    }
    
    //输入限制
    if (resultStr.length > 0) {
        if (!limitModel.regularStr || limitModel.regularStr.length <= 0) {
            return YES;
        }
        if ([self satisfyStr:resultStr regularStr:limitModel.regularStr]) {
            return YES;
        } else {
            return NO;
        }
    }
    return YES;
}

- (BOOL)satisfyStr:(NSString *)str regularStr:(NSString *)regularStr {
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:regularStr options:0 error:nil];
    NSArray *results = [regex matchesInString:str options:0 range:NSMakeRange(0, str.length)];
    return results.count > 0;
}


@end
