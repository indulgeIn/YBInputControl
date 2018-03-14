//
//  UIView+YBInputControl.m
//  YBInputLimitDemo
//
//  Created by 杨少 on 2018/3/12.
//  Copyright © 2018年 yangbo. All rights reserved.
//

#import "UIView+YBInputControl.h"
#import <objc/runtime.h>

#define tempDelegateIsRespondsSel _tempDelegateIsRespondsSel(self, _cmd)

static const void *key_Profile = &key_Profile;
static const void *key_tempDelegate = &key_tempDelegate;

static id _tempDelegateIsRespondsSel(id target, SEL sel) {
    id tempDelegate = objc_getAssociatedObject(target, key_tempDelegate);
    return (tempDelegate && [tempDelegate respondsToSelector:sel]) ? tempDelegate : nil;
}

static BOOL judgeRegular(NSString *contentStr, NSString *regularStr) {
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:regularStr options:0 error:nil];
    NSArray *results = [regex matchesInString:contentStr options:0 range:NSMakeRange(0, contentStr.length)];
    return results.count > 0;
}

static BOOL shouldChangeCharactersIn(id target, NSRange range, NSString *string) {
    if (!objc_getAssociatedObject(target, key_Profile)) {
        return YES;
    }
    
    YBInputControlProfile *profile = objc_getAssociatedObject(target, key_Profile);
    
    NSString *nowStr = [target valueForKey:@"text"];
    
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
        if (!profile.cancelTextControlBefore && resultStr.length > profile.maxLength) {
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
    if (profile.maxLength != NSUIntegerMax && [tagert valueForKey:@"markedTextRange"] == nil) {
        //这里是为了避免联想输入超出长度限制
        NSString *text = [tagert valueForKey:@"text"];
        if (text.length > profile.maxLength) {
            [tagert setValue:[text substringToIndex:profile.maxLength] forKey:@"text"];
        }
    }
    if (profile.textChangeInvocation) {
        [profile.textChangeInvocation setArgument:&tagert atIndex:2];
        [profile.textChangeInvocation invoke];
    }
    if (profile.textChanged) {
        profile.textChanged(tagert);
    }
}



@interface YBInputControlProfile ()

@property (nonatomic, assign) BOOL cancelTextControlBefore;
@property (nonatomic, strong, nullable) NSInvocation *textChangeInvocation;

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
        if (textControlType == YBTextControlType_none) {
            self.regularStr = @"";
            return;
        }
        if (textControlType & YBTextControlType_custom) {
            return;
        }
        NSString *regularStr = @"";
        if (textControlType & YBTextControlType_price) {
            NSString *tempStr = self.maxLength == NSUIntegerMax?@"":[NSString stringWithFormat:@"%ld", (unsigned long)self.maxLength];
            regularStr = [NSString stringWithFormat:@"^(([1-9]\\d{0,%@})|0)(\\.\\d{0,2})?$", tempStr];
        } else {
            regularStr = [NSString stringWithFormat:@"^[%@%@%@]*$",
                          (textControlType & YBTextControlType_numbers)?@"0-9":@"",
                          (textControlType & YBTextControlType_lettersSmall)?@"a-z":@"",
                          (textControlType & YBTextControlType_lettersBig)?@"A-Z":@""];
        }
        self.regularStr = regularStr;
    }
}

- (void)setRegularStr:(NSString *)regularStr {
    self.cancelTextControlBefore = regularStr.length <= 0;
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


@implementation UITextField (YBInputControl)

+ (void)load {
    if ([NSStringFromClass(self) isEqualToString:@"UITextField"]) {
        Method m1 = class_getInstanceMethod(self, @selector(setDelegate:));
        Method m2 = class_getInstanceMethod(self, @selector(customSetDelegate:));
        if (m1 && m2) {
            method_exchangeImplementations(m1, m2);
        }
    }
}
- (void)customSetDelegate:(id)delegate {
    @synchronized(self) {
        if (objc_getAssociatedObject(self, key_Profile)) {
            if (!delegate) {
                [self customSetDelegate:nil];
                objc_setAssociatedObject(self, key_Profile, nil, OBJC_ASSOCIATION_RETAIN);
            } else if (delegate != self) {
                [self customSetDelegate:self];
                objc_setAssociatedObject(self, key_tempDelegate, delegate, OBJC_ASSOCIATION_ASSIGN);
            } else if (delegate == self) {
                if (self.delegate && self.delegate != self) {
                    objc_setAssociatedObject(self, key_tempDelegate, self.delegate, OBJC_ASSOCIATION_ASSIGN);
                }
                [self customSetDelegate:self];
            }
        } else {
            [self customSetDelegate:delegate];
        }
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
    id temp_d = tempDelegateIsRespondsSel;
    if (temp_d) {
        return [temp_d textField:textField shouldChangeCharactersInRange:range replacementString:string];
    }
    return shouldChangeCharactersIn(textField, range, string);
}
- (void)textFieldDidChange:(UITextField *)textField {
    textDidChange(textField);
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    id temp_d = tempDelegateIsRespondsSel;
    if (temp_d) {
        return [temp_d textFieldShouldBeginEditing:textField];
    }
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    id temp_d = tempDelegateIsRespondsSel;
    if (temp_d) {
        [temp_d textFieldDidBeginEditing:textField];
    }
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    id temp_d = tempDelegateIsRespondsSel;
    if (temp_d) {
        [temp_d textFieldShouldEndEditing:textField];
    }
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    id temp_d = tempDelegateIsRespondsSel;
    if (temp_d) {
        [temp_d textFieldDidEndEditing:textField];
    }
}
- (void)textFieldDidEndEditing:(UITextField *)textField reason:(UITextFieldDidEndEditingReason)reason {
    id temp_d = tempDelegateIsRespondsSel;
    if (temp_d) {
        if (@available(iOS 10.0, *)) {
            [temp_d textFieldDidEndEditing:textField reason:reason];
        } else {
            // Fallback on earlier versions
        }
    }
}
- (BOOL)textFieldShouldClear:(UITextField *)textField {
    id temp_d = tempDelegateIsRespondsSel;
    if (temp_d) {
        return [temp_d textFieldShouldClear:textField];
    }
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    id temp_d = tempDelegateIsRespondsSel;
    if (temp_d) {
        return [temp_d textFieldShouldReturn:textField];
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
    id temp_d = tempDelegateIsRespondsSel;
    if (temp_d) {
        return [temp_d textView:textView shouldChangeTextInRange:range replacementText:text];
    }
    return shouldChangeCharactersIn(textView, range, text);
}
- (void)textViewDidChange:(UITextView *)textView {
    id temp_d = tempDelegateIsRespondsSel;
    if (temp_d) {
        [temp_d textViewDidChange:textView];
    }
    textDidChange(textView);
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    id temp_d = tempDelegateIsRespondsSel;
    if (temp_d) {
        return [temp_d textViewShouldBeginEditing:textView];
    }
    return YES;
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    id temp_d = tempDelegateIsRespondsSel;
    if (temp_d) {
        return [temp_d textViewShouldEndEditing:textView];
    }
    return YES;
}
- (void)textViewDidBeginEditing:(UITextView *)textView {
    id temp_d = tempDelegateIsRespondsSel;
    if (temp_d) {
        [temp_d textViewDidBeginEditing:textView];
    }
}
- (void)textViewDidEndEditing:(UITextView *)textView {
    id temp_d = tempDelegateIsRespondsSel;
    if (temp_d) {
        [temp_d textViewDidEndEditing:textView];
    }
}
- (void)textViewDidChangeSelection:(UITextView *)textView {
    id temp_d = tempDelegateIsRespondsSel;
    if (temp_d) {
        [temp_d textViewDidChangeSelection:textView];
    }
}
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction {
    id temp_d = tempDelegateIsRespondsSel;
    if (temp_d) {
        if (@available(iOS 10.0, *)) {
            return [temp_d textView:textView shouldInteractWithURL:URL inRange:characterRange interaction:interaction];
        } else {
            // Fallback on earlier versions
        }
    }
    return YES;
}
- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction {
    id temp_d = tempDelegateIsRespondsSel;
    if (temp_d) {
        if (@available(iOS 10.0, *)) {
            return [temp_d textView:textView shouldInteractWithTextAttachment:textAttachment inRange:characterRange interaction:interaction];
        } else {
            // Fallback on earlier versions
        }
    }
    return YES;
}

@end

