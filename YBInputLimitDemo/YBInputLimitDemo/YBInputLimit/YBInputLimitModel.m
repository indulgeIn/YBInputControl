//
//  YBInputLimitModel.m
//  YBToolsDemo
//
//  Created by cqdingwei@163.com on 2017/7/17.
//  Copyright © 2017年 yangbo. All rights reserved.
//

#import "YBInputLimitModel.h"

@interface YBInputLimitModel ()



@end

@implementation YBInputLimitModel

+ (YBInputLimitModel *)initialization {
    YBInputLimitModel *model = [YBInputLimitModel new];
    return model;
}
- (YBInputLimitModel *(^)(YBInputLimitType))setInputLimitType {
    return ^YBInputLimitModel* (YBInputLimitType type) {
        self.inputLimitType = type;
        return self;
    };
}
- (YBInputLimitModel *(^)(NSString *))setRegularStr {
    return ^YBInputLimitModel* (NSString *regularStr) {
        self.regularStr = regularStr;
        return self;
    };
}
- (YBInputLimitModel *(^)(NSUInteger))setMaxLength {
    return ^YBInputLimitModel* (NSUInteger maxLength) {
        self.maxLength = maxLength;
        return self;
    };
}
- (YBInputLimitModel *(^)(void (^)(id observe)))setTextChanged {
    return ^YBInputLimitModel *(void (^block)(id observe)) {
        if (block) {
            self.textChanged = ^(id observe) {
                block(observe);
            };
        }
        return self;
    };
}
- (YBInputLimitModel *(^)(id, SEL))addTargetAndAction {
    return ^YBInputLimitModel *(id target, SEL action) {
        [self addTargetOfTextChange:target action:action];
        return self;
    };
}


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
    
    if (target && action)
    {
        invocation = [NSInvocation invocationWithMethodSignature:[target methodSignatureForSelector:action]];
        invocation.target = target;
        invocation.selector = action;
    }
    
    self.textChangeInvocation = invocation;
}




#pragma mark *** setter ***
- (void)setInputLimitType:(YBInputLimitType)inputLimitType {
    
    _inputLimitType = inputLimitType;
    if (inputLimitType == YBInputLimitType_none) {
        return;
    }
        
    NSString *regularStr = @"";
    
    if (inputLimitType & YBInputLimitType_price) {
        
        NSString *tempStr = self.maxLength == NSUIntegerMax?@"":[NSString stringWithFormat:@"%ld", self.maxLength];
        regularStr = [NSString stringWithFormat:@"^(([1-9]\\d{0,%@})|0)(\\.\\d{0,2})?$", tempStr];
        
    } else {
        
        regularStr = [NSString stringWithFormat:@"^[%@%@%@]*$",
                      (inputLimitType & YBInputLimitType_numbers)?@"0-9":@"",
                      (inputLimitType & YBInputLimitType_lettersSmall)?@"a-z":@"",
                      (inputLimitType & YBInputLimitType_lettersBig)?@"A-Z":@""];
    }
    
    self.regularStr = regularStr;
}



@end
