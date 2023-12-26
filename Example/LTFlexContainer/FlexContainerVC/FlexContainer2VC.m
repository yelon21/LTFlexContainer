//
//  FlexContainer2VC.m
//  LTStudy
//
//  Created by 龙 on 2023/12/9.
//

#import "FlexContainer2VC.h"
#import "LTFlexContainer.h"
#import "LTLabel.h"

@interface FlexContainer2VC ()
@property(nonatomic, strong) LTFlexContainer *containerView;
@end

@implementation FlexContainer2VC

-(LTFlexContainer *)containerView{
    
    if(!_containerView){
        _containerView = [[LTFlexContainer alloc] init];
        NSLog(@"_containerView=%@", _containerView);
        _containerView.flexDirectionType =LTFlexDirectionTypeColumn;
        _containerView.flexAlignItemsType = LTFlexAlignItemsTypeStretch;
        _containerView.flexAlignContentType = LTFlexAlignContentTypeStretch;
        _containerView.flexJustifyContentType = LTFlexJustifyContentTypeSpaceBetween;
        _containerView.lt_paddingEdgeInsets = UIEdgeInsetsMake(15, 15, 15, 10);
        _containerView.backgroundColor = [UIColor colorWithRed:59/255.0 green:128/255.0 blue:221/255.0 alpha:1.0];
        _containerView.layer.cornerRadius = 5;
        
        [_containerView addSubview:[self topContainer]];
        [_containerView addSubview:[self bottomContainer]];
//        [_containerView addSubview:[self buttonsContainer]];
    }
    return _containerView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGSize size = self.view.bounds.size;
    CGSize fitSize = CGSizeMake(size.width-20, size.height);
    CGSize containerSize = [self.containerView sizeThatFits:fitSize];
    self.containerView.frame = CGRectMake(10, 100, fitSize.width, containerSize.height);
    self.containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
//    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
//    gradientLayer.frame = self.containerView.bounds;
//    gradientLayer.colors = @[(__bridge id)[UIColor blueColor].CGColor, (__bridge id)[UIColor redColor].CGColor];
//    gradientLayer.startPoint = CGPointMake(0, 0);
//    gradientLayer.endPoint = CGPointMake(1, 1);
//    [self.containerView.layer addSublayer:gradientLayer];
    
    [self.view addSubview:self.containerView];
}

- (UIView *)bankTextContainer{
    
    LTFlexContainer *containerView = [[LTFlexContainer alloc] initWidthHideContainerView:NO];
    NSLog(@"bankTextContainer=%@", containerView);
    containerView.flexDirectionType = LTFlexDirectionTypeColumn;
    containerView.flexAlignItemsType = LTFlexAlignItemsTypeStretch;
    containerView.flexJustifyContentType = LTFlexJustifyContentTypeSpaceBetween;
    containerView.lt_paddingEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
    containerView.lt_flexAttribute.flexGrow = 1;
    LTLabel *bankNameLabel = [LTLabel new];
    bankNameLabel.text = @"农业银行";
    bankNameLabel.lt_flexAttribute.flexOrder = 0;
    [containerView addSubview:bankNameLabel];
    
    LTLabel *nameLabel = [LTLabel new];
    nameLabel.text = @"张三丰";
    nameLabel.lt_flexAttribute.flexOrder = 0;
    [containerView addSubview:nameLabel];
    
    LTLabel *bankBranchLabel = [LTLabel new];
    bankBranchLabel.text = @"上海市徐汇区徐汇支行";
    bankBranchLabel.lt_flexAttribute.flexOrder = 1;
    [containerView addSubview:bankBranchLabel];
    
    return containerView;
}

- (UIView *)bankInfoContainer{
    
    LTFlexContainer *containerView = [[LTFlexContainer alloc] initWidthHideContainerView:NO];
    NSLog(@"bankInfoContainer=%@", containerView);
    containerView.flexDirectionType = LTFlexDirectionTypeRow;
    containerView.flexAlignItemsType = LTFlexAlignItemsTypeFlexStart;
    containerView.flexJustifyContentType = LTFlexJustifyContentTypeFlexStart;
    containerView.lt_flexAttribute.flexGrow = 1;
    
    UIImageView *iconImageView = [[UIImageView alloc] init];
    iconImageView.lt_flexAttribute.fixedSize = CGSizeMake(40, 40);
    iconImageView.layer.cornerRadius=20;
    iconImageView.layer.masksToBounds=YES;
    iconImageView.image = [UIImage imageNamed:@"bank_logo"];
//    iconImageView.hidden = YES;
    
//    iconImageView.marginEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    [containerView addSubview:iconImageView];
    
    [containerView addSubview:[self bankTextContainer]];
    
    return containerView;
}

- (UIView *)topContainer{
    
    LTFlexContainer *containerView = [[LTFlexContainer alloc] initWidthHideContainerView:NO];
    NSLog(@"leftContainer=%@", containerView);
    containerView.flexDirectionType = LTFlexDirectionTypeRow;
    containerView.flexAlignItemsType = LTFlexAlignItemsTypeFlexStart;
    containerView.flexJustifyContentType = LTFlexJustifyContentTypeSpaceBetween;
//    containerView.paddingEdgeInsets = UIEdgeInsetsMake(0, 0, 15, 0);
    containerView.lt_flexAttribute.flexGrow = 1;
    [containerView addSubview:[self bankInfoContainer]];
    
    UIButton *setBtn = [self newButton:@"设为结算卡" titleColor:[UIColor whiteColor]];
    [containerView addSubview:setBtn];
    
    return containerView;
}

- (UIView *)buttonsContainer{
    
    LTFlexContainer *containerView = [[LTFlexContainer alloc] initWidthHideContainerView:NO];
    NSLog(@"buttonsContainer=%@", containerView);
    containerView.flexDirectionType = LTFlexDirectionTypeRow;
    containerView.flexAlignItemsType = LTFlexAlignItemsTypeCenter;
    containerView.flexJustifyContentType = LTFlexJustifyContentTypeSpaceBetween;
    
    UIButton *modifyBtn = [self newButton:@"修改" titleColor:[UIColor whiteColor]];
    [containerView addSubview:modifyBtn];
    UIButton *deleteBtn = [self newButton:@"删除" titleColor:[UIColor whiteColor]];
    deleteBtn.lt_marginEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [containerView addSubview:deleteBtn];
    
    return containerView;
}

- (UIView *)bottomContainer{
    
    LTFlexContainer *containerView = [[LTFlexContainer alloc] initWidthHideContainerView:NO];
    NSLog(@"rightContainer=%@", containerView);
    containerView.flexDirectionType = LTFlexDirectionTypeRow;
    containerView.flexAlignItemsType = LTFlexAlignItemsTypeCenter;
    containerView.flexJustifyContentType = LTFlexJustifyContentTypeSpaceBetween;
    containerView.lt_marginEdgeInsets = UIEdgeInsetsMake(10, 0, 0, 0);
    LTLabel *cardNoLabel = [LTLabel new];
    cardNoLabel.text = @"1234567891234";
    [containerView addSubview:cardNoLabel];

    [containerView addSubview:[self buttonsContainer]];
    
    return containerView;
}

- (UIButton *)newButton:(NSString *)title titleColor:(UIColor *)titleColor{
    
    UIButton *btn = [UIButton new];
    btn.titleLabel.font = [UIFont systemFontOfSize:12];
    btn.layer.cornerRadius = 5;
    btn.layer.borderColor = titleColor.CGColor;
    btn.layer.borderWidth = 1;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:titleColor forState:UIControlStateNormal];
    [btn setContentEdgeInsets:UIEdgeInsetsMake(5, 10, 5, 10)];
    [btn addTarget:self
            action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (void)click{
    
    NSLog(@"click");
}

@end
