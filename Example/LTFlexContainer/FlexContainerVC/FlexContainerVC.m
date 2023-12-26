//
//  FlexContainerVC.m
//  LTStudy
//
//  Created by 龙 on 2023/12/7.
//

#import "FlexContainerVC.h"
#import "LTFlexContainer.h"

@interface FlexContainerVC (){
    
    LTFlexContainer *container;
    NSArray *textArray;
}

@end

@implementation FlexContainerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];

    textArray = @[@"撑着油纸伞，独自",@"彷徨在悠长、悠长",@"又寂寥的雨巷，",@"我希望逢着",@"一个丁香一样地",@"结着愁怨的姑娘。",@"她是有",@"丁香一样的颜色，",@"丁香一样的芬芳，",@"丁香一样的忧愁，",@"在雨中哀怨，",@"哀怨又彷徨；",@"她彷徨在这寂寥的雨巷，",@"撑着油纸伞",@"像我一样，",@"像我一样地",@"默默彳亍着",@"冷漠、凄清，又惆怅。",@"她默默地走近，",@"走近，又投出",@"太息一般的眼光",@"她飘过",@"像梦一般地，",@"像梦一般地凄婉迷茫。",@"像梦中飘过",@"一枝丁香地，",@"我身旁飘过这个女郎；",@"她默默地远了，远了，",@"到了颓圮的篱墙，",@"走尽这雨巷。",@"在雨的哀曲里，",@"消了她的颜色，",@"散了她的芬芳，",@"消散了，甚至她的",@"太息般的眼光",@"丁香般的惆怅。",@"撑着油纸伞，独自",@"彷徨在悠长、悠长",@"又寂寥的雨巷，",@"我希望飘过",@"一个丁香一样地",@"结着愁怨的姑娘。"];

    container = [[LTFlexContainer alloc] initWidthHideContainerView:NO];
    
    container.flexDirectionType = LTFlexDirectionTypeRow;
    container.flexWrapType = LTFlexWrapTypeWrap;
    container.flexAlignItemsType = LTFlexAlignItemsTypeStretch;
    container.flexJustifyContentType = LTFlexJustifyContentTypeSpaceBetween;
//    container.flexAlignContentType = LTFlexAlignContentTypeSpaceAround;
    
    container.backgroundColor = [UIColor lightGrayColor];
    [self loadContents];
}

-  (void)loadContents{

    [container lt_removeAllSubviews];
    for (NSUInteger index = 0; index < 16; index ++ ) {
        
        UILabel *label = [self getLabel:index];
        uint32_t random = arc4random()%100+50;
        CGFloat fontSize = 28*random/100;
        label.font = [UIFont systemFontOfSize:fontSize];
        label.numberOfLines = index%2 == 0?0:2;
//        label.lt_flexAttribute.flexGrow = index%2 == 0?1:0;
//        label.marginEdgeInsets = UIEdgeInsetsMake(0, 40, 0, 20);
//        if(index==0){
//            label.lt_flexAttribute.positionType = LTPositionTypeAbsolute;
//            label.lt_marginEdgeInsets = UIEdgeInsetsMake(CGFLOAT_MAX, 0, 0, 0);
//        }
        
        [container addSubview:label];
    }
    if(!container.superview){
        [self.view addSubview:container];
    }
    
    [self resizeContainer];
}

- (void)resizeContainer{
    
    UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        safeAreaInsets = self.view.safeAreaInsets;
    }
    
    CGFloat width = CGRectGetWidth(self.view.bounds)-20-safeAreaInsets.left-safeAreaInsets.right;
    CGFloat height = CGRectGetHeight(self.view.bounds)-20-safeAreaInsets.top-safeAreaInsets.bottom;
    
    container.frame = CGRectMake(10+safeAreaInsets.left,safeAreaInsets.top, width, height);
}

-(void)viewWillLayoutSubviews{
    
    [super viewWillLayoutSubviews];
   
    [self resizeContainer];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    [self loadContents];
}

- (UILabel *)getLabel:(NSUInteger)index{
    
    UILabel *label = [UILabel new];
    label.clipsToBounds = YES;
    label.backgroundColor = [self randomColor];
    label.textColor = [self randomColor];
    label.text = [NSString stringWithFormat:@"%@%@", @(index), [self getText]];
    
//    NSLog(@"num:=%@", [label.text substringToIndex:2]);
    return label;
}

- (NSString *)getText{
    
    int num = arc4random();
    num = num%textArray.count;
    return textArray[num];
}

- (UIColor *)randomColor{
    
    CGColorSpaceRef spaceRef = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    CGFloat components[] = {0.0, 0.0, 0.0, 1.0};
    
    for (int index = 0; index < 3; index++) {
        
        uint32_t random = arc4random()%256;
        components[index] = random/255.0;
    }
    
    CGColorRef colorRef = CGColorCreate(spaceRef, components);
    CGColorSpaceRelease(spaceRef);
    UIColor *color = [UIColor colorWithCGColor:colorRef];
    CGColorRelease(colorRef);
    return color;
}

@end
