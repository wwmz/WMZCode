






//
//  WMZCodeView.m
//  WMZCode
//
//  Created by wmz on 2018/12/14.
//  Copyright © 2018年 wmz. All rights reserved.
//


//间距
#define margin 10

//滑块大小
#define codeSize 50

//贝塞尔曲线偏移
#define offset 9

//背景图片宽度
#define imageHeight 200

//滑块高度
#define sliderHeight 40

//默认需要点击文本的数量
#define codeLabelCount 4

//默认还需要添加的点击文本的数量
#define codeAddLabelCount 3

//字体
#define WMZfont 24

#import "WMZCodeView.h"
@interface WMZCodeView()
{
    dispatch_source_t timer; //定时器
}
@property(nonatomic,copy)NSString *name;                      //文本图片 默认图片“A”

@property(nonatomic,copy)callBack block;                      //回调

@property(nonatomic,assign)CodeType type;                     //类型

@property(nonatomic,strong)UILabel *tipLabel;                 //提示文本

@property(nonatomic,strong)UIImageView *mainImage;            //背景图片

@property(nonatomic,strong)UIImageView *moveImage;            //可移动图片

@property(nonatomic,strong)CAShapeLayer *maskLayer;           //遮罩层layer

@property(nonatomic,strong)UIView *maskView;                  //遮罩层

@property(nonatomic,assign)CGPoint randomPoint;               //随机位置

@property(nonatomic,strong)WMZSlider *WMZSlider;              //自定义滑动

@property(nonatomic,strong)WMZSlider *slider;                 //滑动

@property(nonatomic,strong)UIButton *refresh;                 //刷新按钮

@property(nonatomic,assign)CGFloat width;                     //self的frame的width

@property(nonatomic,assign)CGFloat height;                    //self的frame的height

@property(nonatomic,copy)NSString *allChinese;                //所显示的所有中文

@property(nonatomic,copy)NSString *factChinese;               //实际需要点击的中文

@property(nonatomic,copy)NSString *selectChinese;             //点击的中文

@property(nonatomic,assign)int tapCount;                      //点击数量

@property(nonatomic,strong)NSMutableArray *btnArr;            //按钮数组

@property(nonatomic,assign)CGFloat seconds;                   //秒数

@property(nonatomic,strong)UIView *nineView;                  //九宫格view

@end
@implementation WMZCodeView
/*
 * 初始化
 */
+ (instancetype)shareInstance{
    return [[self alloc]init];
}

/*
 * 调用方法
 *
 * @param  CodeType  类型
 * @param  name      背景图
 * @param  rect      frame
 * @param  block     回调
 *
 */
- (WMZCodeView*)addCodeViewWithType:(CodeType)type withImageName:(NSString*)name witgFrame:(CGRect)rect withBlock:(callBack)block{
    self.frame = rect;
    self.name = [name copy];
    self.type = type;
    self.block = block;
    [self addViewWithType:type];
    return self;
}

//根据type不同进行布局
- (void)addViewWithType:(CodeType)type{
    switch (type) {
        case CodeTypeImage:
        {
            [self CodeTypeImageView];
        }
            break;
        case CodeTypeLabel:
        {
            [self CodeTypeLabelView];
        }
            break;
        case CodeTypeNineLabel:
        {
            [self CodeTypeLabelView];
        }
            break;
        case CodeTypeSlider:
        {
            [self CodeTypeSliderView];
        }
            break;
    }
}

//CodeTypeImage
- (void)CodeTypeImageView{
    [self addSubview:({
        self.tipLabel.text = @"拖动下方滑块完成拼图";
        self.tipLabel.frame = CGRectMake(margin, margin, self.width-margin*2, 30);
        self.tipLabel;
    })];
    
    [self addSubview:({
        self.mainImage.frame = CGRectMake(margin, CGRectGetMaxY(self.tipLabel.frame)+margin, self.width-margin*2, imageHeight);
        self.mainImage.contentMode =  UIViewContentModeScaleAspectFill;
        self.mainImage.clipsToBounds = YES;
        self.mainImage;
    })];
    
    [self addSubview:({
        self.slider.frame = CGRectMake(margin, CGRectGetMaxY(self.mainImage.frame)+margin, self.width-margin*2, 30);
        [self.slider addTarget:self action:@selector(buttonAction:forEvent:) forControlEvents:UIControlEventAllTouchEvents];
        self.slider.layer.masksToBounds = YES;
        self.slider.layer.cornerRadius = 15;
        self.slider;
    })];
    
    [self addSubview:({
        self.refresh.frame = CGRectMake(self.width-margin-50, CGRectGetMaxY(self.slider.frame)+margin, 40, 40);
        [self.refresh setImage:[UIImage imageNamed:@"refresh"] forState:UIControlStateNormal];
        [self.refresh addTarget:self action:@selector(refreshAction) forControlEvents:UIControlEventTouchUpInside];
        self.refresh;
    })];
    
    CGRect rect = self.frame;
    rect.size.height = CGRectGetMaxY(self.refresh.frame)+margin;
    self.frame = rect;
    
    [self refreshAction];

}

//CodeTypeLabel and  CodeTypeNineLabel
- (void)CodeTypeLabelView{
    [self addSubview:({
        [self setMyTipLabetText];
        self.tipLabel.frame = CGRectMake(margin, margin, self.width-margin*2, 30);
        self.tipLabel;
    })];
    
    [self addSubview:({
        self.mainImage.frame = CGRectMake(margin, CGRectGetMaxY(self.tipLabel.frame)+margin, self.width-margin*2, imageHeight);
        self.mainImage.image = [UIImage imageNamed:self.name];
        self.mainImage.contentMode =  UIViewContentModeScaleAspectFill;
        self.mainImage.clipsToBounds = YES;
        self.mainImage.userInteractionEnabled = YES;
        self.mainImage;
    })];
    
    [self addSubview:({
        self.refresh.frame = CGRectMake(self.width-margin-50, CGRectGetMaxY(self.mainImage.frame)+margin, 40, 40);
        [self.refresh setImage:[UIImage imageNamed:@"refresh"] forState:UIControlStateNormal];
        [self.refresh addTarget:self action:@selector(refreshAction) forControlEvents:UIControlEventTouchUpInside];
        self.refresh;
    })];
    
    CGRect rect = self.frame;
    rect.size.height = CGRectGetMaxY(self.refresh.frame)+margin;
    self.frame = rect;
    
    
    [self addLabelImage];
}

//CodeTypeSlider
- (void)CodeTypeSliderView{
    
    if (self.height<40) {
        self.height = 40;
    }

    self.WMZSlider.frame = CGRectMake(margin-3, -3, self.width-2*margin+6,self.height+6);
    self.WMZSlider.minimumTrackTintColor = [UIColor clearColor];
    self.WMZSlider.maximumTrackTintColor = [UIColor clearColor];
    UIImage *tempImage = [UIImage imageNamed:@"SliderBtn"];
    tempImage = [tempImage imageScaleToSize:CGSizeMake(self.height+6, self.height+6)];
    [self.WMZSlider setThumbImage:tempImage forState:UIControlStateNormal];
    [self.WMZSlider setThumbImage:tempImage forState:UIControlStateHighlighted];
   
    
    [self.WMZSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.WMZSlider];
    
    self.WMZSlider.label.frame = CGRectMake(margin, 0, self.width-2*margin, self.height);
    [self addSubview:self.WMZSlider.label];
    
    self.WMZSlider.label.layer.masksToBounds = YES;
    self.WMZSlider.label.layer.cornerRadius = (self.height)/2;
    
    self.WMZSlider.layer.masksToBounds = YES;
    self.WMZSlider.layer.cornerRadius = (self.height+6)/2;
}

//滑块滑动事件
- (void)sliderValueChanged:(UISlider *)slider{
    [self.WMZSlider setValue:slider.value animated:NO];
    if (slider.value >0) {
        self.WMZSlider.minimumTrackTintColor = [UIColor redColor];
    }else{
        self.WMZSlider.minimumTrackTintColor = [UIColor clearColor];
    }


    if (!slider.isTracking && slider.value != 1) {
        [self.WMZSlider setValue:0 animated:YES];
        if (slider.value >0) {
            self.WMZSlider.minimumTrackTintColor = [UIColor redColor];
        }else{
            self.WMZSlider.minimumTrackTintColor = [UIColor clearColor];
        }
    }
    if (!slider.isTracking&&slider.value==1) {
        [self.layer addAnimation:successAnimal() forKey:@"successAnimal"];
        [self successShow];
    }
}

//添加可移动的图片
- (void)addMoveImage{
    UIImage *normalImage = [UIImage imageNamed:self.name];
    normalImage = [normalImage dw_RescaleImageToSize:CGSizeMake(self.width-margin*2, imageHeight)];
    self.mainImage.image = normalImage;
    
    [self.mainImage addSubview:({
        self.maskView.frame = CGRectMake(self.randomPoint.x, self.randomPoint.y, codeSize, codeSize);
        self.maskView;
    })];
    
    UIBezierPath *path = getCodePath();
    
    UIImage * thumbImage = [self.mainImage.image dw_SubImageWithRect:self.maskView.frame];
    thumbImage = [thumbImage dw_ClipImageWithPath:path mode:(DWContentModeScaleToFill)];
    [self.mainImage addSubview:({
        self.moveImage.frame = CGRectMake(0, self.randomPoint.y-offset, codeSize+offset, codeSize+offset);
        self.moveImage.image = thumbImage;
        self.moveImage;
    })];
    
    
    [self.maskView.layer addSublayer:({
        self.maskLayer.frame = CGRectMake(0, 0, codeSize, codeSize);
        self.maskLayer.path = path.CGPath;
        self.maskLayer.strokeColor = [UIColor whiteColor].CGColor;
        self.maskLayer;
    })];
   
}

//添加随机位置的文本
- (void)addLabelImage{
    NSMutableArray *tempArr = [NSMutableArray new];
    for (int i = 0; i< self.allChinese.length; i++) {
        [tempArr addObject:[self.allChinese substringWithRange:NSMakeRange(i, 1)]];
    }
    NSArray* arr = [NSArray arrayWithArray:tempArr];
    arr = [arr sortedArrayUsingComparator:^NSComparisonResult(NSString *str1, NSString *str2) {
        int seed = arc4random_uniform(2);
        if (seed) {
            return [str1 compare:str2];
        } else {
            return [str2 compare:str1];
        }
    }];
    
    NSMutableString *string = [[NSMutableString alloc]initWithString:@""];
    for (int i = 0; i<arr.count; i++) {
        [string appendString:arr[i]];
    }
    self.allChinese = [NSString stringWithFormat:@"%@",string];
    CGFloat btnWidth = (self.width-2*margin-(arr.count-1)*margin)/arr.count;
    

    if (self.type == CodeTypeNineLabel) {
        btnWidth = 40;
        if (!self.nineView) {
            self.nineView = [UIView new];
            self.nineView.userInteractionEnabled = YES;
            self.nineView.backgroundColor = [UIColor clearColor];
            self.nineView.frame = CGRectMake(0, (imageHeight-btnWidth*3-margin*2)/2, btnWidth*3+margin*2, btnWidth*3+margin*2);
            [self.mainImage addSubview:self.nineView];
            self.nineView.center = CGPointMake(self.mainImage.center.x, self.nineView.center.y);
        }
        
    }
    
    if (self.btnArr.count==0) {
        UIButton *tempBtn = nil;
        for (int i = 0; i<arr.count; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.backgroundColor = [UIColor whiteColor];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [btn setTitle:arr[i] forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:20.0];
            btn.layer.masksToBounds = YES;
            btn.layer.cornerRadius = btnWidth/2;
            [btn addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
            CGFloat h = [self getRandomNumber:btnWidth to:imageHeight-margin];
            if (self.type == CodeTypeLabel) {
                if (!tempBtn) {
                    btn.frame = CGRectMake(margin, h, btnWidth, btnWidth);
                }else{
                    btn.frame = CGRectMake(CGRectGetMaxX(tempBtn.frame)+margin, h, btnWidth, btnWidth);
                }
                [self addSubview:btn];
                tempBtn = btn;
            }
            if (self.type == CodeTypeNineLabel) {
                CGFloat X = (i % 3) * (btnWidth + margin);
                CGFloat Y = (i / 3) * (btnWidth + margin);
                btn.frame = CGRectMake(X, Y, btnWidth, btnWidth);
                [self.nineView addSubview:btn];
            }
           
            
            [self.btnArr addObject:btn];
        }
    }else{
         for (int i = 0; i<self.btnArr.count; i++) {
             UIButton *btn = self.btnArr[i];
             [btn setTitle:arr[i] forState:UIControlStateNormal];
               if (self.type == CodeTypeLabel) {
                 CGFloat h = [self getRandomNumber:btnWidth to:imageHeight-margin];
                 btn.frame = CGRectMake(btn.frame.origin.x, h, btnWidth, btnWidth);
               }
         }
    }
    

}

//按钮点击事件
- (void)tapAction:(UIButton*)btn{
    if (self.tapCount==0) {
        dispatch_queue_t global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        self.seconds = 0;
        timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, global);
        dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
        dispatch_source_set_event_handler(timer, ^{
            self.seconds+=0.1;
            NSLog(@"%.1f",self.seconds);
        });
        dispatch_resume(timer);
    }
    self.tapCount+=1;
    self.selectChinese = [NSString stringWithFormat:@"%@%@",self.selectChinese?:@"",btn.titleLabel.text];
    btn.backgroundColor = [UIColor redColor];
    
    if (self.tapCount==self.factChinese.length) {
        if (timer) {
            dispatch_source_cancel(timer);
        }
        
        if ([self.selectChinese isEqualToString:self.factChinese]) {
            [self.layer addAnimation:successAnimal() forKey:@"successAnimal"];
            [self successShow];
            
        }else{
            [self.layer addAnimation:failAnimal() forKey:@"failAnimal"];
            
        }
        [self defaultBtnAndData];
    }
}


//图片验证滑块的所有事件
- (void)buttonAction:(UISlider*)slider forEvent:(UIEvent *)event{
    UITouchPhase phase = event.allTouches.anyObject.phase;
    if (phase == UITouchPhaseBegan) {
        dispatch_queue_t global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        self.seconds = 0;
        timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, global);
        dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
        dispatch_source_set_event_handler(timer, ^{
            self.seconds+=0.1;
            NSLog(@"%.1f",self.seconds);
        });
        dispatch_resume(timer);
    }
    else if(phase == UITouchPhaseEnded){
        if (timer) {
            dispatch_source_cancel(timer);
        }
        
        CGFloat x = self.maskView.frame.origin.x;
        if (fabs(self.moveImage.frame.origin.x-x)<=5.00) {
            [self.layer addAnimation:successAnimal() forKey:@"successAnimal"];
            [self successShow];
        }else{
            [self.layer addAnimation:failAnimal() forKey:@"failAnimal"];
            [self defaultSlider];
        }
    }else if (phase == UITouchPhaseMoved){
        if (slider.value>self.width-margin*2-codeSize) {
            slider.value = self.width-margin*2-codeSize;
            return;
        }
        [self changeSliderWithVlue:slider.value];
        
    }
}

//设置默认的滑动
- (void)defaultSlider{
    self.slider.value = 0.05;
    [self changeSliderWithVlue:self.slider.value];
}

//图片位置随着Slider滑动改变frame
- (void)changeSliderWithVlue:(CGFloat)value{
    CGRect rect = self.moveImage.frame;
    CGFloat x = value * (self.mainImage.frame.size.width)-(value*codeSize);
    rect.origin.x = x;
    self.moveImage.frame = rect;
}

//恢复默认数据（CodeTypeLabel,CodeTypeNineLabel ）
- (void)defaultBtnAndData{
    self.selectChinese = @"";
    self.tapCount = 0;
    for (int i = 0; i<self.btnArr.count; i++) {
        UIButton *btn = self.btnArr[i];
        btn.backgroundColor = [UIColor whiteColor];
    }
}

//刷新按钮事件
- (void)refreshAction{
    self.seconds = 0;
    if (timer) {
        dispatch_source_cancel(timer);
    }
    
    self.name = [self getRandomNumber:0 to:1]==1?@"A":@"B";
    if (self.type==CodeTypeImage){
        
        [self getRandomPoint];
        [self addMoveImage];
        [self defaultSlider];
    }
    if (self.type == CodeTypeSlider) {
         [self.WMZSlider setValue:0 animated:YES];
    }
    
    if (self.type == CodeTypeLabel||self.type ==CodeTypeNineLabel) {
         self.mainImage.image = [UIImage imageNamed:self.name];
         self.factChinese = nil;
         self.allChinese = nil;
        [self setMyTipLabetText];
        [self defaultBtnAndData];
        [self addLabelImage];
    }
   
}


//设置提示文本
- (void)setMyTipLabetText{
    NSString *str = [NSString stringWithFormat:@"按顺序点击‘%@’完成验证",self.factChinese];
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:str];
    [attStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:WMZfont+2] range:[str rangeOfString:self.factChinese]];
    [attStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:[str rangeOfString:self.factChinese]];
    self.tipLabel.attributedText = attStr;
}



//成功动画
static inline CABasicAnimation *successAnimal(){
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.duration = 0.2;
    animation.autoreverses = YES;
    animation.fromValue = @1;
    animation.toValue = @0;
    animation.removedOnCompletion = YES;
    return animation;
}

//失败动画
static inline CABasicAnimation *failAnimal(){
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    [animation setDuration:0.08];
    animation.fromValue = @(-M_1_PI/16);
    animation.toValue = @(M_1_PI/16);
    animation.repeatCount = 2;
    animation.autoreverses = YES;
    return animation;
}

//成功的操作
- (void)successShow{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __weak WMZCodeView *codeView = self;
        NSString *tip = @"";
        if (self.seconds>0) {
            tip = [NSString stringWithFormat:@"耗时%.1fs",self.seconds];
        }
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"验证成功" message:tip preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (codeView.block) {
                codeView.block(YES);
            }
            [codeView refreshAction];
        }];
        [alert addAction:action];
        [[self getCurrentVC] presentViewController:alert animated:YES completion:nil];
    });
   
}

//获取当前VC
- (UIViewController *)getCurrentVC
{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    UIViewController *currentVC = [self getCurrentVCFrom:rootViewController];
    
    return currentVC;
}

- (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC
{
    UIViewController *currentVC;
    
    if ([rootVC presentedViewController]) {
        // 视图是被presented出来的
        rootVC = [rootVC presentedViewController];
    }
    
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        // 根视图为UITabBarController
        currentVC = [self getCurrentVCFrom:[(UITabBarController *)rootVC selectedViewController]];
        
    } else if ([rootVC isKindOfClass:[UINavigationController class]]){
        // 根视图为UINavigationController
        currentVC = [self getCurrentVCFrom:[(UINavigationController *)rootVC visibleViewController]];
        
    } else {
        // 根视图为非导航类
        currentVC = rootVC;
    }
    return currentVC;
}

/**
 配置滑块贝塞尔曲线
 */
static inline UIBezierPath* getCodePath(){
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(codeSize*0.5-offset,0)];
    [path addQuadCurveToPoint:CGPointMake(codeSize*0.5+offset, 0) controlPoint:CGPointMake(codeSize*0.5, -offset*2)];
    [path addLineToPoint:CGPointMake(codeSize, 0)];
    
    
    [path addLineToPoint:CGPointMake(codeSize,codeSize*0.5-offset)];
    [path addQuadCurveToPoint:CGPointMake(codeSize, codeSize*0.5+offset) controlPoint:CGPointMake(codeSize+offset*2, codeSize*0.5)];
    [path addLineToPoint:CGPointMake(codeSize, codeSize)];
    
    [path addLineToPoint:CGPointMake(codeSize*0.5+offset,codeSize)];
    [path addQuadCurveToPoint:CGPointMake(codeSize*0.5-offset, codeSize) controlPoint:CGPointMake(codeSize*0.5, codeSize-offset*2)];
    [path addLineToPoint:CGPointMake(0, codeSize)];
    
    [path addLineToPoint:CGPointMake(0,codeSize*0.5+offset)];
    [path addQuadCurveToPoint:CGPointMake(0, codeSize*0.5-offset) controlPoint:CGPointMake(0+offset*2, codeSize*0.5)];
    [path addLineToPoint:CGPointMake(0, 0)];
    
    [path stroke];
    return path;
}

//获取随机位置
- (void)getRandomPoint{
    CGFloat widthMax =  self.mainImage.frame.size.width-margin-codeSize;
    CGFloat heightMax = self.mainImage.frame.size.height-codeSize*2;
    
    self.randomPoint = CGPointMake([self getRandomNumber:margin+codeSize*2 to:widthMax], [self getRandomNumber:offset*2 to:heightMax]);
    NSLog(@"%f %f",self.randomPoint.x,self.randomPoint.y);
}

//获取一个随机整数，范围在[from, to]，包括from，包括to
- (int)getRandomNumber:(int)from to:(int)to {
    return (int)(from + (arc4random() % (to - from + 1)));
}


//获取随机数量中文
- (NSString*)getRandomChineseWithCount:(NSInteger)count{
    
     NSMutableString *mString = [[NSMutableString alloc]initWithString:@""];
     NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    for (int i = 0; i<count; i++) {
        NSInteger randomH = 0xA1+arc4random()%(0xFE - 0xA1+1);
        NSInteger randomL = 0xB0+arc4random()%(0xF7 - 0xB0+1);
        NSInteger number = (randomH<<8)+randomL;
        NSData *data = [NSData dataWithBytes:&number length:2];
        NSString *string = [[NSString alloc] initWithData:data encoding:gbkEncoding];
        if (string) {
            [mString appendString:string];
        }
    }
    return [NSString stringWithFormat:@"%@",mString];
}

- (NSString *)name{
    if (!_name) {
        _name = @"A";
    }
    return _name;
}

- (UILabel *)tipLabel{
    if (!_tipLabel) {
        _tipLabel = [UILabel new];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.font = [UIFont systemFontOfSize:WMZfont];
    }
    return _tipLabel;
}

- (UIImageView *)mainImage{
    if (!_mainImage) {
        _mainImage = [UIImageView new];
    }
    return _mainImage;
}

- (UIView *)maskView{
    if (!_maskView) {
        _maskView = [UIView new];
        _maskView.alpha = 0.5;
    }
    return _maskView;
}

- (UIImageView *)moveImage{
    if (!_moveImage) {
        _moveImage = [UIImageView new];
    }
    return _moveImage;
}

- (WMZSlider *)slider{
    if (!_slider) {
        _slider = [WMZSlider new];
        _slider.thumbTintColor = [UIColor greenColor];
    }
    return _slider;
}


-(UIButton *)refresh{
    if (!_refresh) {
        _refresh = [UIButton buttonWithType:UIButtonTypeCustom];
        [_refresh setAdjustsImageWhenHighlighted:NO];
    }
    return _refresh;
}

- (CGFloat)width{
    if (!_width) {
        _width = self.frame.size.width;
    }
    return _width;
}


- (CGFloat)height{
    if (!_height) {
        _height = self.frame.size.height;
    }
    return _height;
}


- (CAShapeLayer *)maskLayer{
    if (!_maskLayer) {
        _maskLayer = [CAShapeLayer layer];
    }
    return _maskLayer;
}

- (WMZSlider *)WMZSlider{
    if (!_WMZSlider) {
        _WMZSlider = [WMZSlider new];
    }
    return _WMZSlider;
}

- (NSString *)factChinese{
    if (!_factChinese) {
        _factChinese = [self getRandomChineseWithCount:codeLabelCount];
    }
    return _factChinese;
}

- (NSString *)allChinese{
    if (!_allChinese) {
        _allChinese = [NSString stringWithFormat:@"%@%@",self.factChinese,[self getRandomChineseWithCount: self.type == CodeTypeNineLabel?9-codeLabelCount:codeAddLabelCount]];
    }
    return _allChinese;
}

- (NSMutableArray *)btnArr{
    if (!_btnArr) {
        _btnArr = [NSMutableArray new];
    }
    return _btnArr;
}

@end

@implementation WMZSlider
//改变滑动条高度
- (CGRect)trackRectForBounds:(CGRect)bounds{
    return CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}


- (UILabel *)label{
    if (!_label) {
        _label = [UILabel new];
        _label.center = self.center;
        _label.text = @"按住滑块拖动到最右边";
        _label.font = [UIFont systemFontOfSize:WMZfont];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.textColor = [UIColor colorWithRed:193/255.0 green:193/255.0 blue:193/255.0 alpha:1];
        _label.layer.masksToBounds = YES;
        _label.layer.borderWidth = 1;
        _label.layer.borderColor = [UIColor colorWithRed:193/255.0 green:193/255.0 blue:193/255.0 alpha:1].CGColor;
    }
    return _label;
}


@end


@implementation UIImage (Expand)

///截取当前image对象rect区域内的图像
-(UIImage *)dw_SubImageWithRect:(CGRect)rect{
    CGFloat scale = self.scale;
    
    CGRect scaleRect = CGRectMake(rect.origin.x * scale, rect.origin.y * scale, rect.size.width * scale, rect.size.height * scale);
    CGImageRef newImageRef = CGImageCreateWithImageInRect(self.CGImage, scaleRect);
    UIImage *newImage = [[UIImage imageWithCGImage:newImageRef] dw_RescaleImageToSize:rect.size];
    CGImageRelease(newImageRef);
    return newImage;
}

///压缩图片至指定尺寸
-(UIImage *)dw_RescaleImageToSize:(CGSize)size{
    CGRect rect = (CGRect){CGPointZero, size};
    
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    
    [self drawInRect:rect];
    
    UIImage *resImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resImage;
}

///按给定path剪裁图片
/**
 path:路径，剪裁区域。
 mode:填充模式
 */
-(UIImage *)dw_ClipImageWithPath:(UIBezierPath *)path mode:(DWContentMode)mode{
    CGFloat originScale = self.size.width * 1.0 / self.size.height;
    CGRect boxBounds = path.bounds;
    CGFloat width = boxBounds.size.width;
    CGFloat height = width / originScale;
    switch (mode) {
        case DWContentModeScaleAspectFit:
        {
            if (height > boxBounds.size.height) {
                height = boxBounds.size.height;
                width = height * originScale;
            }
        }
            break;
        case DWContentModeScaleAspectFill:
        {
            if (height < boxBounds.size.height) {
                height = boxBounds.size.height;
                width = height * originScale;
            }
        }
            break;
        default:
            if (height != boxBounds.size.height) {
                height = boxBounds.size.height;
            }
            break;
    }
    
    ///开启上下文
    UIGraphicsBeginImageContextWithOptions(boxBounds.size, NO, [UIScreen mainScreen].scale);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    ///归零path
    UIBezierPath * newPath = [path copy];
    [newPath applyTransform:CGAffineTransformMakeTranslation(-path.bounds.origin.x, -path.bounds.origin.y)];
    [newPath addClip];
    
    ///移动原点至图片中心
    CGContextTranslateCTM(bitmap, boxBounds.size.width / 2.0, boxBounds.size.height / 2.0);
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-width / 2, -height / 2, width, height), self.CGImage);
    
    ///生成图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

//裁剪图片
- (UIImage*)imageScaleToSize:(CGSize)size{
    UIGraphicsBeginImageContext(size);//size为CGSize类型，即你所需要的图片尺寸
    [self drawInRect:CGRectMake(0,0, size.width, size.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

@end
