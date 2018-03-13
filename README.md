# YBInputControl
iOS文本输入控制解决方案-框架



具体说明见简书地址：http://www.jianshu.com/p/bd70c24a7021

    //* 注意1：如果不是输入描述性文本的情况下，建议把联想输入关闭（联想输入在输入之前无法监听，无法精确控制输入字符）
    textfield.autocorrectionType = UITextAutocorrectionTypeNo;
    //* 注意2：如果不用输入中文，请设置键盘让用户无法切换到中文输入状态（由于中文输入状态自带联想）
    textfield.keyboardType = UIKeyboardTypeASCIICapable;
    
    
    //链式语法使用
    textfield.yb_inputCP = YBInputControlProfile.creat.set_maxLength(10).set_textControlType(YBTextControlType_lettersBig|YBTextControlType_lettersSmall).set_textChanged(^(id obj){
        NSLog(@"%@", [obj valueForKey:@"text"]);
    });
    
    
    //常规方法使用
    YBInputControlProfile *profile = [YBInputControlProfile new];
    profile.maxLength = 10;
    //也可以直接使用使用正则表达式
    //profile.regularStr = @"^[a-z]*$";
    profile.textControlType = YBTextControlType_numbers;
    [profile addTargetOfTextChange:self action:@selector(textChange:)];
    textfield.yb_inputCP = profile;
    

    //取消功能
    //textfield.yb_inputCP = nil;
    

    //同样可以按照以往的习惯，设置代理
    textfield.delegate = self;
    //特别注意
    //在给textField或textView设置了非自身的delegate，若实现了如下方法，将覆盖本框架的输入实时限制功能（长度限制功能基本有效）：
    //    - (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
    //    - (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
