# YBInputControl

iOS文本输入控制-框架：轻松实现文本输入字符类型控制、字符长度控制，侵入性小。
———— 于 2018-3-14 大规模重构 


# 使用须知


文本输入解决方案和框架原理讲解请看简书：https://www.jianshu.com/p/0e527df5c1ef

首先将`UIView+YBInputControl`的`.h.m`文件拖入工程，在需要使用的地方导入`UIView+YBInputControl.h`



# 具体用法


该框架分别在`UITextField`和`UITextView`的分类中拓展了一个属性:

<pre><code>@property (nonatomic, strong, nullable) YBInputControlProfile *yb_inputCP;
</code></pre>
    
使用方法就是为该属性赋值。这里通过`YBInputControlProfile`类进行文本控制，控制的具体配置都在该类的属性中。


## UITextField 使用

### 常规方法使用：

<pre><code>YBInputControlProfile *profile = [YBInputControlProfile new];
profile.maxLength = 10;
profile.textControlType = YBTextControlType_excludeInvisible;
[profile addTargetOfTextChange:self action:@selector(textChange:)];
textfield.yb_inputCP = profile;
</code></pre>

### 链式语法使用：

<pre><code>textfield.yb_inputCP = YBInputControlProfile.creat.set_maxLength(10).set_textControlType(YBTextControlType_letter).set_textChanged(^(id obj){
    NSLog(@"%@", [obj valueForKey:@"text"]);
});
</code></pre>
   
如你所见，文本变化的回调提供了block闭包形式和添加监听者+SEL的方式。


### 取消功能：

<pre><code>textfield.yb_inputCP = nil;
</code></pre>


### 设置自己的正则表达式：

如果你想使用自己的正则表达式可以使用`YBInputControlProfile`类的这个属性：

<pre><code>profile.regularStr = @"^[a-z]*$";
</code></pre>

若你在设置`textControlType`之后或者唯一设置了`regularStr`，你的正则表达式将会生效，但是你需要注意以下几个问题（当然，若使用`textControlType`配置类型，框架内部会处理下列问题）：

+ 注意1：如果不是输入描述性文本的情况下，建议把联想输入关闭（联想输入在输入之前无法监听，无法精确控制输入字符）`textfield.autocorrectionType = UITextAutocorrectionTypeNo;`
    
+ 注意2：如果不用输入中文，请设置键盘让用户无法切换到中文输入状态（由于中文输入状态自带联想）`textfield.keyboardType = UIKeyboardTypeASCIICapable;`


### 关于侵入性的说明：

你仍然可以监听`UITextField`的`delegate`，框架已经做了特殊处理，你可以在任何地方使用：

<pre><code>textfield.delegate = self;
</code></pre>

注意：若实现了如下方法，将覆盖本框架的输入实时限制功能（其他方法可以像往常一样使用）：

<pre><code>- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    //如果你仍然想要框架的实时判断输入功能，需要调用一个共有函数
    return yb_shouldChangeCharactersIn(textField, range, string);
}
</code></pre>


## UITextView 使用

若不额外设置`UITextView`的`delegate`属性时，使用和`UITextFiled`一样，不需往下看了。

若你配置了`UITextView`的`yb_inputCP`属性过后，仍然想要配置`UITextView`的`delegate`。由于`UITextView`的继承特性等一系列复杂的原因，暂时无法减少对其的侵入性。对于`UITextView`来说，当`delegate`是非自身的情况下，`yb_inputCP`属性和`delegate`属性是互斥的，意味着后配置的会覆盖先配置的，因为配置`yb_inputCP`属性时内部是将`UITextView`的`delegate`设置为自身。

若你先配置了`yb_inputCP`，后配置:`textView.delegate = otherTarget;`那么该框架的功能将会失效，若你仍然想使其有效，必须实现如下操作:

<pre><code>- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
   return yb_shouldChangeCharactersIn(textView, range, text);
}
- (void)textViewDidChange:(UITextView *)textView {
   yb_textDidChange(textView);
}
</code></pre>

若你先配置了`textView.delegate = otherTarget;`，后配置`yb_inputCP`，那`otherTarget`对代理方法的回调将全部失效。
