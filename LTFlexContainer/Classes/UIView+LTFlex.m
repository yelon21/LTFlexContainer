//
//  UIView+LTFlex.m
//  LTStudy
//
//  Created by 龙 on 2023/12/6.
//

#import "UIView+LTFlex.h"
#import <objc/runtime.h>
#import "LTFlexContainer.h"

@interface UIView (IB)

@property (nonatomic, assign) IBInspectable CGPoint PaddingLeftTop;
@property (nonatomic, assign) IBInspectable CGPoint PaddingRightBottom;
@property (nonatomic, assign) IBInspectable CGPoint MarginLeftTop;
@property (nonatomic, assign) IBInspectable CGPoint MarginRightBottom;

// flex attr
@property(nonatomic, assign) IBInspectable NSUInteger flexAlignaSelfType;
@property(nonatomic, assign) IBInspectable NSInteger flexOrder;
@property(nonatomic, assign) IBInspectable NSUInteger flexGrow;
@property(nonatomic, assign) IBInspectable NSUInteger flexShrink;

@property(nonatomic, assign) IBInspectable BOOL holdPlaceholder;
@property(nonatomic, assign) IBInspectable NSUInteger positionType;
@property(nonatomic, assign) IBInspectable CGPoint relativeOffset;

@property(nonatomic, assign) IBInspectable CGSize fixedSize;
@property(nonatomic, assign) IBInspectable CGFloat minHeight;
@property(nonatomic, assign) IBInspectable CGFloat maxHeight;
@property(nonatomic, assign) IBInspectable CGFloat minWidth;
@property(nonatomic, assign) IBInspectable CGFloat maxWidth;
@end

@implementation UIView (IB)
@dynamic PaddingLeftTop;
@dynamic PaddingRightBottom;
@dynamic MarginLeftTop;
@dynamic MarginRightBottom;

#pragma mark - for IBInspectable
#define LT_Flex_IB_PROPERTY_INSETS_ADAPTER(adapterProperty,property,e1, e2)\
-(void)set##property:(CGPoint)property{\
NSLog(@"%@,%@", NSStringFromSelector(_cmd), NSStringFromCGPoint(property));\
UIEdgeInsets insets = self.adapterProperty;\
insets.e1 = property.x;\
insets.e2 = property.y;\
self.adapterProperty = insets;\
}\
-(CGPoint)property{\
return CGPointMake(self.adapterProperty.e1, self.adapterProperty.e2);\
}

LT_Flex_IB_PROPERTY_INSETS_ADAPTER(lt_paddingEdgeInsets,PaddingLeftTop, left, top);
LT_Flex_IB_PROPERTY_INSETS_ADAPTER(lt_paddingEdgeInsets,PaddingRightBottom, right, bottom);

LT_Flex_IB_PROPERTY_INSETS_ADAPTER(lt_marginEdgeInsets,MarginLeftTop, left, top);
LT_Flex_IB_PROPERTY_INSETS_ADAPTER(lt_marginEdgeInsets,MarginRightBottom, right, bottom);


#define LT_Flex_IB_PROPERTY_ATTRIBUTE(property,Property,type, default)\
-(void)set##Property:(type)property{\
    if(![self.superview isKindOfClass:[LTFlexContainer class]]){\
        return;\
    }\
self.lt_flexAttribute.property = property;\
}\
-(type)property{\
    if(![self.superview isKindOfClass:[LTFlexContainer class]]){\
        return default;\
    }\
    return self.lt_flexAttribute.property;\
}

LT_Flex_IB_PROPERTY_ATTRIBUTE(flexAlignaSelfType, FlexAlignaSelfType, NSUInteger, 0);
LT_Flex_IB_PROPERTY_ATTRIBUTE(flexOrder, FlexOrder, NSInteger, 0);
LT_Flex_IB_PROPERTY_ATTRIBUTE(flexGrow, FlexGrow, NSUInteger, 0);
LT_Flex_IB_PROPERTY_ATTRIBUTE(flexShrink, FlexShrink, NSUInteger, 0);

LT_Flex_IB_PROPERTY_ATTRIBUTE(holdPlaceholder, HoldPlaceholder, BOOL, NO);
LT_Flex_IB_PROPERTY_ATTRIBUTE(positionType, PositionType, NSUInteger, 0);
LT_Flex_IB_PROPERTY_ATTRIBUTE(relativeOffset, RelativeOffset, CGPoint, CGPointZero);

LT_Flex_IB_PROPERTY_ATTRIBUTE(fixedSize, FixedSize, CGSize, CGSizeZero);

LT_Flex_IB_PROPERTY_ATTRIBUTE(minHeight, MinHeight, CGFloat, 0);
LT_Flex_IB_PROPERTY_ATTRIBUTE(maxHeight, MaxHeight, CGFloat, 0);
LT_Flex_IB_PROPERTY_ATTRIBUTE(minWidth, MinWidth, CGFloat, 0);
LT_Flex_IB_PROPERTY_ATTRIBUTE(maxWidth, MaxWidth, CGFloat, 0);

@end


NSString const *lt_flex_attribute_key = @"lt_flex_attribute_key";
NSString const *lt_cachedHidden_key = @"lt_cachedHidden_key";
NSString const *lt_cachingdHiddenState_key = @"lt_cachingdHiddenState_key";
@implementation UIView (LTFlex)
@dynamic lt_flexAttribute;
@dynamic lt_cachedHidden;
@dynamic lt_cachingdHiddenState;

-(LTFlexAttribute *)lt_flexAttribute{
    LTFlexAttribute *attr = objc_getAssociatedObject(self, &lt_flex_attribute_key);
    if(attr == nil){
        attr = [LTFlexAttribute createWidthView:self];
        objc_setAssociatedObject(self, &lt_flex_attribute_key,
                                 attr, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return attr;
}

+(void)load{
    
    Method setHiddenMethod = class_getInstanceMethod([self class], @selector(setHidden:));
    Method lt_setHiddenMethod = class_getInstanceMethod([self class], @selector(lt_setHidden:));
    method_exchangeImplementations(setHiddenMethod, lt_setHiddenMethod);
    
    Method removeFromSuperviewMethod = class_getInstanceMethod([self class], @selector(removeFromSuperview));
    Method lt_removeFromSuperviewMethod = class_getInstanceMethod([self class], @selector(lt_removeFromSuperview));
    method_exchangeImplementations(removeFromSuperviewMethod, lt_removeFromSuperviewMethod);
}

-(void)lt_removeFromSuperview{
    
    LTFlexContainer *superView = self.lt_flexAttribute.superView;
    if(superView){
        
        [superView lt_deleteSubview:self];
    }
    [self lt_removeFromSuperview];
}

- (void)lt_setHidden:(BOOL)hidden{
    
    if(self.lt_cachingdHiddenState){
        self.lt_cachedHidden = hidden;
    }
    [self lt_setHidden:hidden];
    UIView *superView = self.superview;
    if([superView isKindOfClass:[LTFlexContainer class]]){
        
        [superView setNeedsLayout];
    }
}

-(void)setLt_cachedHidden:(BOOL)lt_cachedHidden{
    
    objc_setAssociatedObject(self, &lt_cachedHidden_key,
                             [NSNumber numberWithBool:lt_cachedHidden],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(BOOL)lt_cachedHidden{
    
    NSNumber *value = [self getValueByKey:&lt_cachedHidden_key];
    return [value boolValue];
}

-(void)setLt_cachingdHiddenState:(BOOL)lt_cachingdHiddenState{
    
    objc_setAssociatedObject(self, &lt_cachingdHiddenState_key,
                             [NSNumber numberWithBool:lt_cachingdHiddenState],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(BOOL)lt_cachingdHiddenState{
    
    NSNumber *value = [self getValueByKey:&lt_cachingdHiddenState_key];
    return [value boolValue];
}

-(id)getValueByKey:(const void * _Nonnull)key{
    
    return objc_getAssociatedObject(self, key);
}

#ifdef DEBUG
#pragma mark - for lookin

- (NSDictionary<NSString *, id> *)lookin_customDebugInfos{
    
    NSDictionary<NSString *, id> *ret = @{
        @"properties": [self flex_makeCustomProperties],
    };

    return ret;
}

- (NSArray *)flex_makeCustomProperties{
   
    LTFlexAttribute *flexAttribute = self.lt_flexAttribute;
    
    NSMutableArray *properties = [NSMutableArray array];
    
    // insets property
    [properties addObject:@{
        @"section": @"Layout PM",
        @"title": @"Padding",
        @"value": [NSValue valueWithUIEdgeInsets:self.lt_paddingEdgeInsets],
        @"valueType": @"insets",
        @"retainedSetter": ^(UIEdgeInsets newInsets) {
        self.lt_paddingEdgeInsets = newInsets;
        }
    }];
    [properties addObject:@{
        @"section": @"Layout PM",
        @"title": @"Margin",
        @"value": [NSValue valueWithUIEdgeInsets:self.lt_marginEdgeInsets],
        @"valueType": @"insets",
        @"retainedSetter": ^(UIEdgeInsets newInsets) {
        self.lt_marginEdgeInsets = newInsets;
        }
    }];
    
    {
        NSDictionary *enumInfo = @{@"LTFlexAlignSelfTypeAuto":@(LTFlexAlignSelfTypeAuto),
                                   @"LTFlexAlignSelfTypeFlexStart":@(LTFlexAlignSelfTypeFlexStart),
                                   @"LTFlexAlignSelfTypeFlexEnd":@(LTFlexAlignSelfTypeFlexEnd),
                                   @"LTFlexAlignSelfTypeFlexCenter":@(LTFlexAlignSelfTypeFlexCenter),
                                   @"LTFlexAlignSelfTypeFlexStretch":@(LTFlexAlignSelfTypeFlexStretch)};
        
        NSString *defaultString = [[enumInfo allKeysForObject:@(flexAttribute.flexAlignaSelfType)] firstObject];
        
        [properties addObject:@{
            @"section": @"Flex Item",
            @"title": @"Aligna Self",
            @"value": defaultString,
            @"valueType": @"enum",
            @"allEnumCases": [enumInfo allKeys],
            @"retainedSetter": ^(NSString *newValue) {
            
            flexAttribute.flexAlignaSelfType = [enumInfo[newValue] integerValue];
        }
        }];
    }
    
    // bool property
    [properties addObject:@{
        @"section": @"Flex Item",
        @"title": @"Hold Placeholder",
        @"value": [NSNumber numberWithBool:flexAttribute.holdPlaceholder],
        @"valueType": @"bool",
        @"retainedSetter": ^(BOOL newBool) {
        flexAttribute.holdPlaceholder = newBool;
        }
    }];

    // number property
    [properties addObject:@{
        @"section": @"Flex Item",
        @"title": @"flexOrder",
        @"value": [NSNumber numberWithFloat:flexAttribute.flexOrder],
        @"valueType": @"number",
        @"retainedSetter": ^(NSNumber *newNumber) {
        flexAttribute.flexOrder = [newNumber floatValue];
        }
    }];
    
    // number property
    [properties addObject:@{
        @"section": @"Flex Item",
        @"title": @"flexGrow",
        @"value": [NSNumber numberWithUnsignedInteger:flexAttribute.flexGrow],
        @"valueType": @"number",
        @"retainedSetter": ^(NSNumber *newNumber) {
        flexAttribute.flexGrow = [newNumber unsignedIntegerValue];
        }
    }];
    
    // number property
    [properties addObject:@{
        @"section": @"Flex Item",
        @"title": @"flexShrink",
        @"value": [NSNumber numberWithUnsignedInteger:flexAttribute.flexShrink],
        @"valueType": @"number",
        @"retainedSetter": ^(NSNumber *newNumber) {
        flexAttribute.flexShrink = [newNumber unsignedIntegerValue];
        }
    }];

    {
        NSDictionary *enumInfo = @{@"LTPositionTypeStatic":@(LTPositionTypeStatic),
                                   @"LTPositionTypeRelative":@(LTPositionTypeRelative),
                                   @"LTPositionTypeAbsolute":@(LTPositionTypeAbsolute),
                                   @"LTPositionTypeFixed":@(LTPositionTypeFixed)};
        
        NSString *defaultString = [[enumInfo allKeysForObject:@(flexAttribute.positionType)] firstObject];
        
        [properties addObject:@{
            @"section": @"Flex Item",
            @"title": @"Position",
            @"value": defaultString,
            @"valueType": @"enum",
            @"allEnumCases": [enumInfo allKeys],
            @"retainedSetter": ^(NSString *newValue) {
            
            flexAttribute.positionType = [enumInfo[newValue] integerValue];
        }
        }];
    }
    
    // point property
    [properties addObject:@{
        @"section": @"Flex Item",
        @"title": @"Relative Offset",
        @"value": [NSValue valueWithCGPoint:flexAttribute.relativeOffset],
        @"valueType": @"point",
        @"retainedSetter": ^(CGPoint newPoint) {
        flexAttribute.relativeOffset = newPoint;
        }
    }];
    
    // size property
    [properties addObject:@{
        @"section": @"Flex Item",
        @"title": @"Fixed Size",
        @"value": [NSValue valueWithCGSize:flexAttribute.fixedSize],
        @"valueType": @"size",
        @"retainedSetter": ^(CGSize newSize) {
        flexAttribute.fixedSize = newSize;
        }
    }];
    
    // number property
    [properties addObject:@{
        @"section": @"Flex Item",
        @"title": @"Min Height",
        @"value": [NSNumber numberWithDouble:flexAttribute.minHeight],
        @"valueType": @"number",
        @"retainedSetter": ^(NSNumber *newNumber) {
        flexAttribute.minHeight = [newNumber floatValue];
        }
    }];
    // number property
    [properties addObject:@{
        @"section": @"Flex Item",
        @"title": @"Min Height",
        @"value": [NSNumber numberWithDouble:flexAttribute.maxHeight],
        @"valueType": @"number",
        @"retainedSetter": ^(NSNumber *newNumber) {
        flexAttribute.maxHeight = [newNumber floatValue];
        }
    }];
    // number property
    [properties addObject:@{
        @"section": @"Flex Item",
        @"title": @"Min Width",
        @"value": [NSNumber numberWithDouble:flexAttribute.minWidth],
        @"valueType": @"number",
        @"retainedSetter": ^(NSNumber *newNumber) {
        flexAttribute.minWidth = [newNumber floatValue];
        }
    }];
    // number property
    [properties addObject:@{
        @"section": @"Flex Item",
        @"title": @"Max Width",
        @"value": [NSNumber numberWithDouble:flexAttribute.maxWidth],
        @"valueType": @"number",
        @"retainedSetter": ^(NSNumber *newNumber) {
        flexAttribute.maxWidth = [newNumber floatValue];
        }
    }];
    
    return [properties copy];
}
#endif

@end


NSString const *lt_paddingEdgeInsetsKey = @"lt_paddingEdgeInsets_key";
NSString const *lt_marginEdgeInsetsKey = @"lt_marginEdgeInsets_key";

@implementation UIView (LTLayout)
@dynamic lt_paddingEdgeInsets;
@dynamic lt_marginEdgeInsets;

-(void)setLt_paddingEdgeInsets:(UIEdgeInsets)lt_paddingEdgeInsets{
    
    objc_setAssociatedObject(self, &lt_paddingEdgeInsetsKey,
                             [NSValue valueWithUIEdgeInsets:lt_paddingEdgeInsets], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.lt_flexAttribute.superView setNeedsLayout];
}

-(UIEdgeInsets)lt_paddingEdgeInsets{
    
    NSValue *value = objc_getAssociatedObject(self, &lt_paddingEdgeInsetsKey);
    return [value UIEdgeInsetsValue];
}

-(void)setLt_marginEdgeInsets:(UIEdgeInsets)lt_marginEdgeInsets{
    
    objc_setAssociatedObject(self, &lt_marginEdgeInsetsKey,
                             [NSValue valueWithUIEdgeInsets:lt_marginEdgeInsets], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.lt_flexAttribute.superView setNeedsLayout];
}

- (UIEdgeInsets)lt_marginEdgeInsets{
    
    NSValue *value = objc_getAssociatedObject(self, &lt_marginEdgeInsetsKey);
    return [value UIEdgeInsetsValue];
}

//-(CGSize)sizeThatFits:(CGSize)size layout:(BOOL)layout{
//    NSLog(@"子类未实现：%@", NSStringFromSelector(_cmd));
//    return [self sizeThatFits:size];
//}

@end
