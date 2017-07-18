# YBInputLimit
一句代码实现文本输入（UITextView/UITextfield）的输入字符限制、长度限制、文本变化回调

具体说明见简书地址：http://www.jianshu.com/p/bd70c24a7021


    //* 一句代码实现
    [textfield setYBInputLimit:YBInputLimitModel
     .initialization
     .setInputLimitType(YBInputLimitType_numbers|YBInputLimitType_lettersSmall)
     .setMaxLength(10)
     .setTextChanged(^(id observe){
        
    })];

    
    //* 常规实现
    YBInputLimitModel *model = [YBInputLimitModel new];
    model.inputLimitType = YBInputLimitType_numbers|YBInputLimitType_lettersSmall;
    model.maxLength = 10;
    [model setTextChanged:^(id observe){
        
    }];
    [textfield setYBInputLimit:model];
    
    
    //* 不使用block
    [textfield setYBInputLimit:YBInputLimitModel
     .initialization
     .setInputLimitType(YBInputLimitType_numbers|YBInputLimitType_lettersSmall)
     .setMaxLength(10)
     .addTargetAndAction(self, @selector(sel0:))];
    
    
    //* 不使用block
    YBInputLimitModel *model = [YBInputLimitModel new];
    model.inputLimitType = YBInputLimitType_numbers|YBInputLimitType_lettersSmall;
    model.maxLength = 10;
    [model addTargetOfTextChange:self action:@selector(sel0:)];
    [textfield setYBInputLimit:model];
    
    
    //* 直接输入正则
    [textfield setYBInputLimit:YBInputLimitModel.initialization.setRegularStr(@"^[0-9]+$")];
