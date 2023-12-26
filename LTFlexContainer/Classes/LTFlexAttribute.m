//
//  LTFlexAttribute.m
//  LTStudy
//
//  Created by 龙 on 2023/12/20.
//  Copyright © 2023 yelon. All rights reserved.
//

#import "LTFlexAttribute.h"
#import "LTFlexContainer.h"

#define LT_Flex_Attribute_PROPERTY_CHANGE(type,property,Property)\
-(void)set##Property:(type)property{\
    if(_##property == property){     \
        return;                     \
    }                                   \
    _##property = property;             \
    [self setNeedsLayoutSuperView];     \
}

@interface LTFlexAttribute()

@property(nonatomic, weak) UIView *ownedView;
@end

@implementation LTFlexAttribute

- (instancetype)initWidthView:(UIView *)view{
    
    if(self = [super init]){
        self.ownedView = view;
    }
    return self;
}

+ (instancetype)createWidthView:(UIView *)view{
    
    LTFlexAttribute *attr = [[LTFlexAttribute alloc] initWidthView:view];
    return attr;
}

-(instancetype)init{
    return nil;
}

LT_Flex_Attribute_PROPERTY_CHANGE(LTFlexAlignaSelfType, flexAlignaSelfType, FlexAlignaSelfType);
LT_Flex_Attribute_PROPERTY_CHANGE(CGFloat, flexOrder, FlexOrder);
LT_Flex_Attribute_PROPERTY_CHANGE(NSUInteger, flexGrow, FlexGrow);
LT_Flex_Attribute_PROPERTY_CHANGE(NSUInteger, flexShrink, FlexShrink);
LT_Flex_Attribute_PROPERTY_CHANGE(BOOL, holdPlaceholder, HoldPlaceholder);
LT_Flex_Attribute_PROPERTY_CHANGE(LTPositionType, positionType, PositionType);
LT_Flex_Attribute_PROPERTY_CHANGE(CGFloat, minHeight, MinHeight);
LT_Flex_Attribute_PROPERTY_CHANGE(CGFloat, maxHeight, MaxHeight);
LT_Flex_Attribute_PROPERTY_CHANGE(CGFloat, minWidth, MinWidth);
LT_Flex_Attribute_PROPERTY_CHANGE(CGFloat, maxWidth, MaxWidth);

-(void)setRelativeOffset:(CGPoint)relativeOffset{
    
    if(CGPointEqualToPoint(_relativeOffset, relativeOffset)){
        return;
    }
    _relativeOffset = relativeOffset;
    [self setNeedsLayoutSuperView];
}

-(void)setFixedSize:(CGSize)fixedSize{
    
    if(CGSizeEqualToSize(_fixedSize, fixedSize)){
        return;
    }
    _fixedSize = fixedSize;
    [self setNeedsLayoutSuperView];
}

- (void)setNeedsLayoutSuperView{
    
    if(_superView){
        
        [_superView setNeedsLayout];
    }
}

@end
