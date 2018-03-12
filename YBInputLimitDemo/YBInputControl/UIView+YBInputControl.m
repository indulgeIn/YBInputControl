//
//  UIView+YBInputControl.m
//  YBInputLimitDemo
//
//  Created by 杨少 on 2018/3/12.
//  Copyright © 2018年 yangbo. All rights reserved.
//

#import "UIView+YBInputControl.h"
#import <objc/runtime.h>

static NSString *keyOfYBInputControlProfile = @"yb_inputCP";
static const void *key_Profile = &key_Profile;
static const void *key_tempDelegate = &key_tempDelegate;

static BOOL judgeRegular(NSString *contentStr, NSString *regularStr) {
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:regularStr options:0 error:nil];
    NSArray *results = [regex matchesInString:contentStr options:0 range:NSMakeRange(0, contentStr.length)];
    return results.count > 0;
}

static BOOL shouldChangeCharactersIn(id tagert, NSRange range, NSString *string) {
    if (![tagert valueForKey:keyOfYBInputControlProfile]) {
        return YES;
    }
    
    YBInputControlProfile *profile = [tagert valueForKey:keyOfYBInputControlProfile];
    
    NSString *nowStr = [tagert valueForKey:@"text"];
    
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
    
    if (profile.maxLength != NSUIntegerMax) {
        if (resultStr.length > profile.maxLength) {
            return NO;
        }
    }
    
    if (resultStr.length > 0) {
        if (!profile.regularStr || profile.regularStr.length <= 0) {
            return YES;
        }
        if (judgeRegular(resultStr, profile.regularStr)) {
            return YES;
        } else {
            return NO;
        }
    }
    return YES;
}

static void textDidChange(id tagert) {
    if (!tagert) {
        return;
    }
    YBInputControlProfile *profile = [tagert valueForKey:@"yb_inputCP"];
    if (!profile) {
        return;
    }
    if (profile.maxLength != NSUIntegerMax) {
        //这里是为了避免联想输入超出长度限制
        NSString *text = [tagert valueForKey:@"text"];
        if (text.length > profile.maxLength) {
            [tagert setValue:[text substringToIndex:profile.maxLength] forKey:@"text"];
        }
    }
    if (profile.textChangeInvocation) {
        UIView *tagertObj = tagert;
        [profile.textChangeInvocation setArgument:&tagertObj atIndex:2];
        [profile.textChangeInvocation invoke];
    }
    if (profile.textChanged) {
        profile.textChanged(tagert);
    }
}



@interface YBInputControlProfile ()

@property (nonatomic, copy, nullable) void(^textChanged)(id observe);

@end

@implementation YBInputControlProfile

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.maxLength = NSUIntegerMax;
    }
    return self;
}

- (void)addTargetOfTextChange:(id)target action:(SEL)action {
    NSInvocation *invocation = nil;
    if (target && action) {
        invocation = [NSInvocation invocationWithMethodSignature:[target methodSignatureForSelector:action]];
        invocation.target = target;
        invocation.selector = action;
    }
    self.textChangeInvocation = invocation;
}

- (void)setTextControlType:(YBTextControlType)textControlType {
    @synchronized(self) {
        _textControlType = textControlType;
        if (textControlType & YBTextControlType_none || textControlType & YBTextControlType_custom) {
            return;
        }
        NSString *regularStr = @"";
        if (textControlType & YBTextControlType_price) {
            NSString *tempStr = self.maxLength == NSUIntegerMax?@"":[NSString stringWithFormat:@"%ld", self.maxLength];
            regularStr = [NSString stringWithFormat:@"^(([1-9]\\d{0,%@})|0)(\\.\\d{0,2})?$", tempStr];
        } else {
            regularStr = [NSString stringWithFormat:@"^[%@%@%@]*$",
                          (textControlType & YBTextControlType_numbers)?@"0-9":@"",
                          (textControlType & YBTextControlType_lettersSmall)?@"a-z":@"",
                          (textControlType & YBTextControlType_lettersBig)?@"A-Z":@""];
        }
        _regularStr = regularStr;
    }
}

- (void)setRegularStr:(NSString *)regularStr {
    if (!regularStr) {
        return;
    }
    _textControlType = YBTextControlType_custom;
    _regularStr = regularStr;
}

+ (YBInputControlProfile *)creat {
    YBInputControlProfile *profile = [YBInputControlProfile new];
    return profile;
}
- (YBInputControlProfile * _Nonnull (^)(YBTextControlType))set_textControlType {
    return ^YBInputControlProfile* (YBTextControlType type) {
        self.textControlType = type;
        return self;
    };
}
- (YBInputControlProfile * _Nonnull (^)(NSString * _Nonnull))set_regularStr {
    return ^YBInputControlProfile* (NSString *regularStr) {
        self.regularStr = regularStr;
        return self;
    };
}
- (YBInputControlProfile * _Nonnull (^)(NSUInteger))set_maxLength {
    return ^YBInputControlProfile* (NSUInteger maxLength) {
        self.maxLength = maxLength;
        return self;
    };
}
- (YBInputControlProfile * _Nonnull (^)(void (^ _Nonnull)(id _Nonnull)))set_textChanged {
    return ^YBInputControlProfile *(void (^block)(id observe)) {
        if (block) {
            self.textChanged = ^(id observe) {
                block(observe);
            };
        }
        return self;
    };
}
- (YBInputControlProfile * _Nonnull (^)(id _Nonnull, SEL _Nonnull))set_targetOfTextChange {
    return ^YBInputControlProfile *(id target, SEL action) {
        [self addTargetOfTextChange:target action:action];
        return self;
    };
}

@end


@implementation UIView (YBInputControl)



@end


@implementation UITextField (YBInputControl)

+ (void)load {
    Method m1 = class_getInstanceMethod(self, @selector(setDelegate:));
    Method m2 = class_getInstanceMethod(self, @selector(text_customSetDelegate:));
    if (m1 && m2) {
        method_exchangeImplementations(m1, m2);
    }
}

- (void)text_customSetDelegate:(id)delegate {
    if ([self valueForKey:@"delegate"] == self) {
        if (delegate != self) {
            objc_setAssociatedObject(self, key_tempDelegate, delegate, OBJC_ASSOCIATION_ASSIGN);
        }
    } else {
        [self text_customSetDelegate:delegate];
    }
}

#pragma mark getter setter
- (void)setYb_inputCP:(YBInputControlProfile *)yb_inputCP {
    @synchronized(self) {
        if (yb_inputCP && [yb_inputCP isKindOfClass:YBInputControlProfile.self]) {
            objc_setAssociatedObject(self, key_Profile, yb_inputCP, OBJC_ASSOCIATION_RETAIN);
            
            UITextField *tf = (UITextField *)self;
            tf.delegate = self;
            YBInputControlProfile *profile = yb_inputCP;
            profile.textChangeInvocation || profile.textChanged ? [tf addTarget:self action:@selector(textFieldDidChange:) forControlEvents : UIControlEventEditingChanged]:nil;
        } else {
            objc_setAssociatedObject(self, key_Profile, nil, OBJC_ASSOCIATION_RETAIN);
        }
    }
}
- (YBInputControlProfile *)yb_inputCP {
    return objc_getAssociatedObject(self, key_Profile);
}

#pragma mark UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return shouldChangeCharactersIn(textField, range, string);
}
- (void)textFieldDidChange:(UITextField *)textField {
    textDidChange(textField);
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    NSLog(@"vc: %@", NSStringFromSelector(_cmd));
    id tempDelegate = objc_getAssociatedObject(self, key_tempDelegate);
    if (tempDelegate) {
        return [tempDelegate textFieldShouldBeginEditing:textField];
    }
    return YES;
}

@end


@implementation UITextView (YBInputControl)

#pragma mark getter setter
- (void)setYb_inputCP:(YBInputControlProfile *)yb_inputCP {
    @synchronized(self) {
        if (yb_inputCP && [yb_inputCP isKindOfClass:YBInputControlProfile.self]) {
            objc_setAssociatedObject(self, key_Profile, yb_inputCP, OBJC_ASSOCIATION_RETAIN);
            
            UITextView *tv = (UITextView *)self;
            tv.delegate = self;
        } else {
            objc_setAssociatedObject(self, key_Profile, nil, OBJC_ASSOCIATION_RETAIN);
        }
    }
}
- (YBInputControlProfile *)yb_inputCP {
    return objc_getAssociatedObject(self, key_Profile);
}

#pragma mark UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    return shouldChangeCharactersIn(textView, range, text);
}
- (void)textViewDidChange:(UITextView *)textView {
    textDidChange(textView);
}

@end

