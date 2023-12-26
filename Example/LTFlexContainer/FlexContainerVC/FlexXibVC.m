//
//  FlexXibVC.m
//  LTFlexContainer_Example
//
//  Created by 龙 on 2023/12/25.
//  Copyright © 2023 yelon21. All rights reserved.
//

#import "FlexXibVC.h"
#import <LTFlexContainer.h>
@interface FlexXibVC ()

@property(nonatomic, weak) IBOutlet LTFlexContainer *container;
@end

@implementation FlexXibVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewDidLayoutSubviews{
    
    [super viewDidLayoutSubviews];
    
    [self resizeContainer];
}

- (void)resizeContainer{
    
    UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        safeAreaInsets = self.view.safeAreaInsets;
    }
    
    CGFloat width = CGRectGetWidth(self.view.bounds)-20-safeAreaInsets.left-safeAreaInsets.right;
    CGFloat height = CGRectGetHeight(self.view.bounds)-20-safeAreaInsets.top-safeAreaInsets.bottom;
    
    self.container.frame = CGRectMake(10+safeAreaInsets.left,safeAreaInsets.top, width, height);
}

@end
