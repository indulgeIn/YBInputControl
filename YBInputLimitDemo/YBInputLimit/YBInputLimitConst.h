
//
//  YBInputLimitConst.h
//  YBToolsDemo
//
//  Created by cqdingwei@163.com on 2017/7/17.
//  Copyright © 2017年 yangbo. All rights reserved.
//

#ifndef YBInputLimitConst_h
#define YBInputLimitConst_h

//设置文本输入限制的key
static NSString * const keyYBTextInputLimit = @"keyYBTextInputLimit";

//限制类型枚举（可多选）
typedef NS_ENUM(NSInteger, YBInputLimitType) {
    YBInputLimitType_none = 0,  //无限制
    YBInputLimitType_numbers = 1 << 0,  //数字
    YBInputLimitType_lettersSmall = 1 << 1, //小写字母
    YBInputLimitType_lettersBig = 1 << 2,   //大写字母
    YBInputLimitType_price = 1 << 3,    //价格（小数点后最多输入两位）
};

#endif /* YBInputLimitConst_h */
