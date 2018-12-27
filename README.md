# WMZCode
//调用方法
[[WMZCodeView shareInstance] addCodeViewWithType:type withImageName:@"A" witgFrame:CGRectMake(0, 50, 300, 50)  withBlock:^(BOOL success) {
        if (success) {
            NSLog(@"成功");
        }
  }];
