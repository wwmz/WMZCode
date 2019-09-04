# WMZCode

pod 'WMZCode', '~> 1.0.0'

## 在使用cocoapods安装时，请先执行 pod search WMZCode，如果搜索不到，请执行pod setup命令。

效果图

![Untitled.gif](https://upload-images.jianshu.io/upload_images/9163368-02e0387793a05194.gif?imageMogr2/auto-orient/strip)

四个枚举
```
/*
 * CodeType type
 */
typedef NS_ENUM(NSInteger, CodeType) {
    CodeTypeImage = 0,    // DefaultImage
    CodeTypeLabel,            // Label
    CodeTypeNineLabel,    // NineLabel
    CodeTypeSlider             // Slider
};
```

调用
```
WMZCodeView *codeView = [[WMZCodeView shareInstance] addCodeViewWithType:CodeTypeImage withImageName:@"A" witgFrame:CGRectMake(0, 50, 300, 50)  withBlock:^(BOOL success) {
        if (success) {
            NSLog(@"成功");
        } 
}];
[superView  addSubview: codeView] ;
```
