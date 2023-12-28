//
//  LTFlexContainer.m
//  LTStudy
//
//  Created by 龙 on 2023/12/6.
//

#import "LTFlexContainer.h"
#import <objc/message.h>
#define LT_FLEX_MAX_VALUE 1000000

@interface LTFlexContainer (IB)

// only for IB
@property (nonatomic, assign) IBInspectable NSUInteger IB_flexDirectionType;
@property (nonatomic, assign) IBInspectable NSUInteger IB_flexWrapType;
@property (nonatomic, assign) IBInspectable NSUInteger IB_flexJustifyContentType;
@property (nonatomic, assign) IBInspectable NSUInteger IB_flexAlignItemsType;
@property (nonatomic, assign) IBInspectable NSUInteger IB_flexAlignContentType;
@end

@implementation LTFlexContainer (IB)

#pragma mark - for IBInspectable
#define LT_Flex_IB_PROPERTY_ADAPTER(type,property)\
-(void)setIB_##property:(type)property{\
self.property = property;\
}\
-(NSUInteger)IB_##property{\
return self.property;\
}

LT_Flex_IB_PROPERTY_ADAPTER(NSUInteger, flexDirectionType);
LT_Flex_IB_PROPERTY_ADAPTER(NSUInteger, flexWrapType);
LT_Flex_IB_PROPERTY_ADAPTER(NSUInteger, flexJustifyContentType);
LT_Flex_IB_PROPERTY_ADAPTER(NSUInteger, flexAlignItemsType);
LT_Flex_IB_PROPERTY_ADAPTER(NSUInteger, flexAlignContentType);

@end


@interface LTFlexContainerSectionInfo : NSObject

@property(nonatomic, strong) NSArray <UIView *>*sectionViews;
@property(nonatomic, assign) CGFloat sectionHeight;
@property(nonatomic, assign) CGFloat sectionWidth;
@end

@implementation LTFlexContainerSectionInfo

+(instancetype)InfoWidth:(NSArray <UIView *>*)sectionViews
           sectionHeight:(CGFloat)sectionHeight
            sectionWidth:(CGFloat)sectionWidth{
    
    LTFlexContainerSectionInfo *info = [LTFlexContainerSectionInfo new];
    info.sectionViews = sectionViews;
    info.sectionHeight = sectionHeight;
    info.sectionWidth = sectionWidth;
    return info;
}
@end

@interface LTFlexContainer (){
    
    CGRect _containerFrame;
}

@property(nonatomic, strong, readonly) NSMutableOrderedSet <UIView *>*subviewsSet;

// 仅仅是添加view到当前view，用于内部使用
-(void)lt_addSubview:(UIView *)view;

@end

@implementation LTFlexContainer
@synthesize subviewsSet = _subviewsSet;

//-(void)awakeFromNib{
//
//    [super awakeFromNib];
//    if(![self.superview isKindOfClass:[LTFlexContainer class]]){
//
//        CGSize frameSize = self.frame.size;
//
//        CGSize size = [self sizeThatFits:frameSize];
//        size.width = MAX(size.width, frameSize.width);
//        size.height = MAX(size.height, frameSize.height);
//
//        CGRect rect = self.frame;
//        rect.size = size;
//
//        self.frame = rect;
//    }
//}

-(instancetype)initWidthHideContainerView:(BOOL)hideContainerView{
    
    if(self = [super init]){
#ifdef DEBUG
//        hideContainerView = NO;
#endif
        self.hideContainerView = hideContainerView;
    }
    return self;
}

#pragma mark - setter
#define LT_Flex_PROPERTY_CHANGE(type,property,Property)\
-(void)set##Property:(type)property{\
    if(_##property == property){     \
        return;                     \
    }                                   \
    _##property = property;             \
    [self setNeedsLayoutWhileFrameIsNotZero];     \
}

LT_Flex_PROPERTY_CHANGE(LTFlexDirectionType, flexDirectionType, FlexDirectionType);
LT_Flex_PROPERTY_CHANGE(LTFlexWrapType, flexWrapType, FlexWrapType);
LT_Flex_PROPERTY_CHANGE(LTFlexJustifyContentType, flexJustifyContentType, FlexJustifyContentType);
LT_Flex_PROPERTY_CHANGE(LTFlexAlignItemsType, flexAlignItemsType, FlexAlignItemsType);
LT_Flex_PROPERTY_CHANGE(LTFlexAlignContentType, flexAlignContentType, FlexAlignContentType);

- (void)setHideContainerView:(BOOL)hideContainerView{
    
    if(_hideContainerView == hideContainerView){
        return;
    }
    _hideContainerView = hideContainerView;
    
    if(_hideContainerView){
        
        self.lt_cachedHidden = self.hidden;
        [super setHidden:YES];
        self.lt_cachingdHiddenState = YES;
    }else{
        self.lt_cachingdHiddenState = NO;
        [super setHidden:self.lt_cachedHidden];
    }
    [self setNeedsLayoutWhileFrameIsNotZero];
//    CGRect newFrame = _containerFrame;
//    if(_lt_hideContainerView){
//
//        CGFloat width = _containerFrame.size.width+_containerFrame.size.height+_containerFrame.origin.x+_containerFrame.origin.y;
//        newFrame = CGRectMake(LT_FLEX_MAX_VALUE, 0, width, CGFLOAT_MIN);
//    }
//    [super setFrame:newFrame];
}

-(NSMutableOrderedSet<UIView *> *)subviewsSet{
    
    if(!_subviewsSet){
        _subviewsSet = [[NSMutableOrderedSet alloc] init];
    }
    return _subviewsSet;
}

- (NSArray<UIView *> *)visibleSubviews {
    
    NSMutableArray<UIView *> *visibleViews = [[NSMutableArray alloc] init];

    [self.subviewsSet enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        do {
            if([obj isKindOfClass:[LTFlexContainer class]]){
                
                LTFlexContainer *containerr = (LTFlexContainer *)obj;
                if(containerr.hideContainerView&&containerr.lt_cachedHidden == NO){
                    break;
                }
            }
            if(obj.hidden&&!obj.lt_flexAttribute.holdPlaceholder){
                return;
            }
        } while (NO);
        
        [visibleViews addObject:obj];
    }];
    
    NSArray *sortedViews = [visibleViews sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        UIView *view1 = obj1;
        UIView *view2 = obj2;
        if (view1.lt_flexAttribute.flexOrder>view2.lt_flexAttribute.flexOrder){
            return NSOrderedDescending;
        }else{
            return NSOrderedAscending;
        }
    }];
    return sortedViews;
}

-(void)setDebugInfo:(NSString *)debugInfo{
    
#ifdef DEBUG
    if(_debugInfo == debugInfo){
        return;
    }
    _debugInfo = debugInfo;
#endif
}

-(void)setFrame:(CGRect)frame{
    
    if(LTCGRectEqualToRect(frame, _containerFrame)){
        [self setNeedsLayoutWhileFrameIsNotZero];
        return;
    }
    _containerFrame = frame;
    
//    CGRect newFrame = frame;
//    if(_lt_hideContainerView){
//
//        CGFloat width = frame.size.width+frame.size.height+frame.origin.x+frame.origin.y;
//        newFrame = CGRectMake(width, 0, width, CGFLOAT_MIN);
//    }
//    [super setFrame:newFrame];
    [super setFrame:frame];
}

-(CGRect)frame{

    return _containerFrame;
}

-(void)setHidden:(BOOL)hidden{
    
    if(self.lt_cachingdHiddenState){
        self.lt_cachedHidden = hidden;
    }
    if(!_hideContainerView && self.hidden == hidden){
        return;
    }
    
    [super setHidden:hidden];
    
    if(!_hideContainerView){
        return;
    }
    
    [self.subviewsSet enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if(hidden){
            
            obj.lt_cachedHidden = obj.hidden;
            obj.hidden = hidden;
            obj.lt_cachingdHiddenState = YES;
        }else{
            
            obj.lt_cachingdHiddenState = NO;
            obj.hidden = obj.lt_cachedHidden;
        }
    }];
}

-(NSArray *)lt_subviews{
    
    return self.subviewsSet.array;
}

-(void)addSubview:(UIView *)view{
    
    LTPositionType positionType = view.lt_flexAttribute.positionType;
    if(!_hideContainerView && (positionType==LTPositionTypeStatic
                                  ||positionType==LTPositionTypeRelative)){
        [super addSubview:view];
    }

    if([view isKindOfClass:[UIView class]]){
        
        [self.subviewsSet addObject:view];
        view.lt_flexAttribute.superView = self;
    }
}

-(void)lt_addSubview:(UIView *)view{
    
    [super addSubview:view];
}

-(void)lt_removeSubview:(UIView *)subview{
    
    [self.subviewsSet removeObject:subview];
    [subview removeFromSuperview];
    subview.lt_flexAttribute.superView = nil;
}

-(void)lt_removeAllSubviews{
    
    [self.subviewsSet enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

        [obj removeFromSuperview];
        obj.lt_flexAttribute.superView = nil;
    }];
    [self.subviewsSet removeAllObjects];
}

-(void)removeFromSuperview{
    
    [super removeFromSuperview];
    
    if(_hideContainerView){
        
        [self.subviewsSet enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            [obj removeFromSuperview];
            obj.lt_flexAttribute.superView = nil;
        }];
    }
}

-(void)setNeedsLayoutWhileFrameIsNotZero{
    
    if(CGRectGetWidth(self.frame)<=0.1 || CGRectGetHeight(self.frame)<=0.1){
        return;
    }
    [self setNeedsLayout];
}

-(void)layoutSubviews{
    
    [super layoutSubviews];
    [self sizeThatFits:_containerFrame.size layout:YES];
}

-(CGSize)sizeThatFits:(CGSize)size{
    
    return [self sizeThatFits:size layout:NO];
}

- (CGSize)sizeThatFits:(CGSize)size layout:(BOOL)layout{
    
    switch (self.flexDirectionType) {
        case LTFlexDirectionTypeRow:
        case LTFlexDirectionTypeRowReverse:{
            return [self sizeHorizontalWrapThatFits:size layout:layout];
        }
        case LTFlexDirectionTypeColumn:
        case LTFlexDirectionTypeColumnReverse:
            return [self sizeVerticalThatFits:size layout:layout];
    }
}

// 主轴 column
- (CGSize)sizeVerticalThatFits:(CGSize)size layout:(BOOL)layout{
    
    BOOL isWrap = self.flexWrapType != LTFlexWrapTypeNoWrap;
    
    CGFloat paddingW = UIEdgeInsetsGetWidth(self.lt_paddingEdgeInsets);
    CGFloat paddingH = UIEdgeInsetsGetHeight(self.lt_paddingEdgeInsets);
    
    CGFloat autoAdjustWidth = NO;
    CGFloat autoAdjustHeight = NO;
    
    CGFloat contentW = size.width - paddingW;
    CGFloat contentH = size.height - paddingH;
    CGFloat minValue = 1/[UIScreen mainScreen].scale;
    if(contentW<minValue || contentW > LT_FLEX_MAX_VALUE){
        
        autoAdjustWidth = YES;
        contentW = CGFLOAT_MAX;
    }
    if(contentH<minValue || contentH > LT_FLEX_MAX_VALUE){
        
        autoAdjustHeight = YES;
        contentH = CGFLOAT_MAX;
    }
    
    NSArray *visibleViews = [self visibleSubviews];
    NSUInteger viewsCount = visibleViews.count;
    if(viewsCount == 0){
        return layout?size:CGSizeZero;
    }
    
    CGFloat currentSectionWidth = 0;// cross
    CGFloat currentSectionHeight = 0;// main
    
    CGFloat maxSectionsWidth = 0;
    CGFloat maxSectionsHeight = 0;
    
    CGFloat maxAbsoluteViewWidth = 0;
    CGFloat maxAbsoluteViewHeight = 0;
    // 存储脱标的View
    NSMutableSet *fixedAndAbsoluteViewSet = [[NSMutableSet alloc] init];
    
    NSMutableArray <LTFlexContainerSectionInfo *>*sectionInfos = [[NSMutableArray alloc] init];
    NSMutableArray <UIView *>*sectionViews = [[NSMutableArray alloc] init];
    
    for (UIView *itemView in visibleViews) {
        
        CGSize itemSize = itemView.lt_flexAttribute.fixedSize;
        CGFloat marginWidth = UIEdgeInsetsGetWidth(itemView.lt_marginEdgeInsets);
        
        LTPositionType positionType = itemView.lt_flexAttribute.positionType;
        if(positionType == LTPositionTypeAbsolute
           || positionType == LTPositionTypeFixed){
            
            CGFloat appendWidth = 0;
            if(itemView.lt_marginEdgeInsets.left < LT_FLEX_MAX_VALUE){
                appendWidth = itemView.lt_marginEdgeInsets.left;
            }
            if (itemView.lt_marginEdgeInsets.right < LT_FLEX_MAX_VALUE){
                appendWidth = appendWidth + itemView.lt_marginEdgeInsets.right;
            }
            
            CGFloat appendHeight = 0;
            if(itemView.lt_marginEdgeInsets.top < LT_FLEX_MAX_VALUE){
                
                appendHeight = itemView.lt_marginEdgeInsets.top;
            }
            if (itemView.lt_marginEdgeInsets.bottom < LT_FLEX_MAX_VALUE){
                appendHeight = appendHeight + itemView.lt_marginEdgeInsets.bottom;
            }
            
            if(CGSizeEqualToSize(itemSize, CGSizeZero)){
                itemSize = [itemView sizeThatFits:CGSizeMake(CGFLOAT_MAX, contentH-appendHeight)];
            }
            
            itemView.lt_flexAttribute.cacheSize = itemSize;
            
            if(positionType == LTPositionTypeAbsolute){
                
                maxAbsoluteViewWidth = MAX(maxAbsoluteViewWidth, itemSize.width + appendWidth);
                maxAbsoluteViewHeight = MAX(maxAbsoluteViewHeight, itemSize.height + appendHeight);
            }
            
            [fixedAndAbsoluteViewSet addObject:itemView];
            continue;
        }
        
        if(CGSizeEqualToSize(itemSize, CGSizeZero)){
            itemSize = [itemView sizeThatFits:CGSizeMake(contentW-marginWidth, contentH)];
        }
        itemSize.width += marginWidth;
        itemSize.height += UIEdgeInsetsGetHeight(itemView.lt_marginEdgeInsets);
        itemView.lt_flexAttribute.cacheSize = itemSize;

        if(isWrap && itemSize.height > contentH - currentSectionHeight + 0.0001){// 换下一列
            
            if(currentSectionHeight>0){
                
                LTFlexContainerSectionInfo *info = [LTFlexContainerSectionInfo InfoWidth:[NSArray arrayWithArray:sectionViews]
                                                                           sectionHeight:currentSectionHeight
                                                                            sectionWidth:currentSectionWidth];
                [sectionInfos addObject:info];
                [sectionViews removeAllObjects];
                
                maxSectionsWidth = maxSectionsWidth + currentSectionWidth;
                maxSectionsHeight = MAX(maxSectionsHeight, currentSectionHeight);
                currentSectionWidth = 0;
                currentSectionHeight = 0;
            }
        }
        
        [sectionViews addObject:itemView];
    
        currentSectionWidth = MAX(currentSectionWidth, itemSize.width);
        currentSectionHeight = currentSectionHeight+itemSize.height;
    }
    
    LTFlexContainerSectionInfo *info = [LTFlexContainerSectionInfo InfoWidth:[NSArray arrayWithArray:sectionViews]
                                                               sectionHeight:currentSectionHeight
                                                                sectionWidth:currentSectionWidth];
    [sectionInfos addObject:info];
    [sectionViews removeAllObjects];
    
    maxSectionsWidth = maxSectionsWidth + currentSectionWidth;
    maxSectionsHeight = MAX(maxSectionsHeight, currentSectionHeight);
    
    maxSectionsWidth = MAX(maxSectionsWidth, maxAbsoluteViewWidth);
    maxSectionsHeight = MAX(maxSectionsHeight, maxAbsoluteViewHeight);
    
    CGFloat maxContentWidth = autoAdjustWidth ? maxSectionsWidth : (layout?contentW:MIN(contentW, maxSectionsWidth));
    CGFloat maxContentHeight = autoAdjustHeight ? maxSectionsHeight : (layout?contentH:MIN(contentH, maxSectionsHeight));
    
    CGSize result = CGSizeMake(maxContentWidth+paddingW,
                               maxContentHeight+paddingH);
    
    if(layout){
        
        NSUInteger sectionCount = sectionInfos.count;
        if(sectionCount == 0){
            return result;
        }
        
        CGFloat firstSectionStartValue = 0;
        CGFloat spaceBetweenSections = 0;
        CGFloat spaceGrowPerSection = 0;
        
        CGFloat leftCrossSpace = maxContentWidth - maxSectionsWidth;
        leftCrossSpace = MAX(leftCrossSpace, 0);
        [self getCrossAxisFirstSectionStartValue:&firstSectionStartValue
                            spaceBetweenSections:&spaceBetweenSections
                             spaceGrowPerSection:&spaceGrowPerSection
                                byCrossSpaceLeft:leftCrossSpace
                                      crossSpace:maxContentWidth
                                    sectionCount:sectionCount];
        
        BOOL isWrapReverse = self.flexWrapType == LTFlexWrapTypeWrapReverse;
        
        CGFloat sectionsContentCrossValue = 0;
    
        for (LTFlexContainerSectionInfo *info in sectionInfos) {
            
            CGFloat sectionWidth = info.sectionWidth + spaceGrowPerSection;
            CGFloat sectionHeight = info.sectionHeight;
            
            NSInteger sectionItemsCount = info.sectionViews.count;
            
            CGFloat leftMainSpace = maxContentHeight - sectionHeight;
            
            CGFloat spacePerUnit = 0;// 增长或减小的单位大小
            
            BOOL isForGrow = NO;
            if(leftMainSpace>0){
                
                isForGrow = YES;
                do {
                    NSDecimalNumber *flexGrowNumber = [info.sectionViews valueForKeyPath:@"self.@sum.lt_flexAttribute.flexGrow"];
                    NSUInteger flexGrowValue = flexGrowNumber.unsignedIntegerValue;
                    if(flexGrowValue==0){
                        break;
                    }
                    spacePerUnit = leftMainSpace/flexGrowValue;
                } while (NO);
            }else if(leftMainSpace<0){
                
                isForGrow = NO;
                do {
                    NSDecimalNumber *flexShrinkNumber = [info.sectionViews valueForKeyPath:@"self.@sum.lt_flexAttribute.flexShrink"];
                    NSUInteger flexShrinkValue = flexShrinkNumber.unsignedIntegerValue;
                    if(flexShrinkValue==0){
                        break;
                    }
                    spacePerUnit = leftMainSpace/flexShrinkValue;
                } while (NO);
            }
            
            CGFloat mainFirstItemStartValue = 0;
            BOOL isReverse = self.flexDirectionType == LTFlexDirectionTypeColumnReverse;
            CGFloat spaceBetweenItems = 0;
            
            if(spacePerUnit == 0){
                
                [self getMainAxisFirstItemStartValue:&mainFirstItemStartValue
                                   spaceBetweenItems:&spaceBetweenItems
                                 byMainAxisLeftSpace:leftMainSpace
                                    mainAxisMaxSpace:maxContentHeight
                                          itemsCount:sectionItemsCount
                                             reverse:isReverse];
            }
            
            CGFloat sectionStartValue = 0;
            if(isWrapReverse){
                sectionsContentCrossValue = sectionsContentCrossValue + sectionWidth + spaceBetweenSections;
                sectionStartValue = firstSectionStartValue - sectionsContentCrossValue + spaceBetweenSections;
            }else{
                sectionStartValue = firstSectionStartValue + sectionsContentCrossValue;
                sectionsContentCrossValue = sectionsContentCrossValue + sectionWidth + spaceBetweenSections;
            }
            
            CGFloat itemsMainSpace = 0;
            
            for (UIView *itemView in info.sectionViews) {
                
                [self fixCorrectSuperView:itemView];
                
                LTFlexAttribute *flexAttribute = itemView.lt_flexAttribute;
                
                CGSize itemSize = itemView.lt_flexAttribute.cacheSize;
                
                CGFloat itemCrossStartValue = 0;
                CGFloat itemWidth = itemSize.width;
                
                CGFloat sectionLeftCrossSpace = sectionWidth - itemWidth;
                sectionLeftCrossSpace = MAX(sectionLeftCrossSpace, 0);
                
                [self getCrossAxisItemStartValue:&itemCrossStartValue
                                  itemCrossValue:&itemWidth
                         byItemFlexAlignaSelfTyp:flexAttribute.flexAlignaSelfType
                           sectionCrossLeftSpace:sectionLeftCrossSpace
                            sectionCrossMaxSpace:sectionWidth];
                
                NSUInteger spaceUnitNumber = isForGrow?flexAttribute.flexGrow:flexAttribute.flexShrink;
                CGFloat spaceChangeMainValue = spacePerUnit * spaceUnitNumber;
                CGFloat height = itemSize.height+spaceChangeMainValue;
                height = MAX(height, 0);
                
                UIEdgeInsets viewMargin = itemView.lt_marginEdgeInsets;
                if(height == 0){
                    viewMargin = UIEdgeInsetsZero;
                }
                
                CGFloat y = 0;
                if(isReverse){
                    itemsMainSpace = itemsMainSpace + height + spaceBetweenItems;
                    y = mainFirstItemStartValue - itemsMainSpace + spaceBetweenItems;
                }else{
                    y = mainFirstItemStartValue + itemsMainSpace;
                    itemsMainSpace = itemsMainSpace + height + spaceBetweenItems;
                }
                
                CGPoint offset = CGPointZero;
                if(_hideContainerView){
                    offset = _containerFrame.origin;
                }
                
                CGPoint relativeOffset = CGPointZero;
                if(flexAttribute.positionType == LTPositionTypeRelative){
                    relativeOffset = flexAttribute.relativeOffset;
                }
                offset.x = offset.x + relativeOffset.x;
                offset.y = offset.y + relativeOffset.y;
                
                CGFloat top = self.lt_paddingEdgeInsets.top;
                CGFloat left = self.lt_paddingEdgeInsets.left;
                
                itemView.frame = CGRectMake(sectionStartValue + itemCrossStartValue + left + offset.x + viewMargin.left,
                                            offset.y+top+y+viewMargin.top,
                                            itemWidth-UIEdgeInsetsGetWidth(viewMargin),
                                            height-UIEdgeInsetsGetHeight(viewMargin));
                
            }
            
        }
        // 处理脱标view
        [self layoutfixedAndAbsouteView:fixedAndAbsoluteViewSet
                       withContinerSize:result];
    }
    
    return result;
}

// 主轴 row wrap
- (CGSize)sizeHorizontalWrapThatFits:(CGSize)size layout:(BOOL)layout{
    
    BOOL isWrap = self.flexWrapType != LTFlexWrapTypeNoWrap;
    
    CGFloat paddingW = UIEdgeInsetsGetWidth(self.lt_paddingEdgeInsets);
    CGFloat paddingH = UIEdgeInsetsGetHeight(self.lt_paddingEdgeInsets);
    
    CGFloat autoAdjustWidth = NO;
    CGFloat autoAdjustHeight = NO;
    
    CGFloat contentW = size.width - paddingW;
    CGFloat contentH = size.height - paddingH;

    CGFloat minValue = 1/[UIScreen mainScreen].scale;
    if(contentW<minValue || contentW == CGFLOAT_MAX){
        
        autoAdjustWidth = YES;
        contentW = CGFLOAT_MAX;
    }
    if(contentH<minValue || contentH == CGFLOAT_MAX){
        
        autoAdjustHeight = YES;
        contentH = CGFLOAT_MAX;
    }
    
    NSArray *visibleViews = [self visibleSubviews];
    NSUInteger viewsCount = visibleViews.count;
    if(viewsCount == 0){
        return layout?size:CGSizeZero;
    }

    CGFloat currentRowContentWidth = 0;
    CGFloat currentRowContentMaxHeight = 0;
    
    CGFloat maxContentRowWidth = 0;
    CGFloat maxContentRowsHeight = 0;

    CGFloat maxAbsoluteViewWidth = 0;
    CGFloat maxAbsoluteViewHeight = 0;
    
    // 存储脱标的View
    NSMutableSet *fixedAndAbsoluteViewSet = [[NSMutableSet alloc] init];
    
    NSMutableArray <LTFlexContainerSectionInfo *>*rowInfos = [[NSMutableArray alloc] init];
    NSMutableArray <UIView *>*rowViews = [[NSMutableArray alloc] init];
    
    for (UIView *itemView in visibleViews) {

        CGSize itemSize = itemView.lt_flexAttribute.fixedSize;
        CGFloat marginWidth = UIEdgeInsetsGetWidth(itemView.lt_marginEdgeInsets);
        
        LTPositionType positionType = itemView.lt_flexAttribute.positionType;
        
        if(positionType == LTPositionTypeAbsolute
           || positionType == LTPositionTypeFixed){
            
            CGFloat appendWidth = 0;
            if(itemView.lt_marginEdgeInsets.left < LT_FLEX_MAX_VALUE){
                appendWidth = itemView.lt_marginEdgeInsets.left;
            }
            if (itemView.lt_marginEdgeInsets.right < LT_FLEX_MAX_VALUE){
                appendWidth = appendWidth + itemView.lt_marginEdgeInsets.right;
            }
            
            CGFloat appendHeight = 0;
            if(itemView.lt_marginEdgeInsets.top < LT_FLEX_MAX_VALUE){
                
                appendHeight = itemView.lt_marginEdgeInsets.top;
            }else if (itemView.lt_marginEdgeInsets.bottom < LT_FLEX_MAX_VALUE){
                appendHeight = appendHeight + itemView.lt_marginEdgeInsets.bottom;
            }
            
            if(CGSizeEqualToSize(itemSize, CGSizeZero)){
                itemSize = [itemView sizeThatFits:CGSizeMake(contentW-appendWidth, CGFLOAT_MAX)];
            }
            
            itemView.lt_flexAttribute.cacheSize = itemSize;
            
            if(positionType == LTPositionTypeAbsolute){
                
                maxAbsoluteViewWidth = MAX(maxAbsoluteViewWidth, itemSize.width + appendWidth);
                maxAbsoluteViewHeight = MAX(maxAbsoluteViewHeight, itemSize.height + appendHeight);
            }
            
            [fixedAndAbsoluteViewSet addObject:itemView];
            continue;
        }
        
        if(CGSizeEqualToSize(itemSize, CGSizeZero)){
            itemSize = [itemView sizeThatFits:CGSizeMake(contentW-marginWidth, CGFLOAT_MAX)];
        }
        itemSize.width += marginWidth;
        itemSize.height += UIEdgeInsetsGetHeight(itemView.lt_marginEdgeInsets);
        
        itemView.lt_flexAttribute.cacheSize = itemSize;
        
        if(isWrap && itemSize.width > contentW-currentRowContentWidth+0.0001){//此处换行

            if(currentRowContentWidth > 0){

                LTFlexContainerSectionInfo *info = [LTFlexContainerSectionInfo InfoWidth:[NSArray arrayWithArray:rowViews]
                                                                           sectionHeight:currentRowContentMaxHeight
                                                                            sectionWidth:currentRowContentWidth];
                [rowInfos addObject:info];
                
                [rowViews removeAllObjects];
                
                maxContentRowsHeight = maxContentRowsHeight + currentRowContentMaxHeight;
                currentRowContentWidth = 0;
                currentRowContentMaxHeight = 0;
            }
        }
        
        [rowViews addObject:itemView];

        currentRowContentMaxHeight = MAX(currentRowContentMaxHeight, itemSize.height);

        currentRowContentWidth = currentRowContentWidth+itemSize.width;
        
        maxContentRowWidth = MAX(maxContentRowWidth, currentRowContentWidth);
    }
    
    LTFlexContainerSectionInfo *info = [LTFlexContainerSectionInfo InfoWidth:[NSArray arrayWithArray:rowViews]
                                                               sectionHeight:currentRowContentMaxHeight
                                                                sectionWidth:currentRowContentWidth];
    [rowInfos addObject:info];
    [rowViews removeAllObjects];
    
    maxContentRowsHeight = maxContentRowsHeight + currentRowContentMaxHeight;
    
    maxContentRowWidth = MAX(maxContentRowWidth, maxAbsoluteViewWidth);
    maxContentRowsHeight = MAX(maxContentRowsHeight, maxAbsoluteViewHeight);
    
    CGFloat maxContentWidth = autoAdjustWidth ? maxContentRowWidth : (layout?contentW:MIN(maxContentRowWidth, contentW));
    CGFloat maxContentHeight = autoAdjustHeight ? maxContentRowsHeight : (layout?contentH:MIN(maxContentRowsHeight, contentH));
    
    CGSize result = CGSizeMake(maxContentWidth+paddingW,
                               maxContentHeight+paddingH);
    
    if(layout){
        
        NSUInteger rowsCount = rowInfos.count;
        if(rowsCount == 0){
            return result;
        }
        
        CGFloat firstSectionStartValue = 0;
        CGFloat spaceBetweenSections = 0;
        CGFloat spaceGrowPerSection = 0;
        
        CGFloat leftH = maxContentHeight - maxContentRowsHeight;
        leftH = MAX(leftH, 0);
        
        // 获取第一个section在cross轴的起始坐标以及每个section平分的剩余空间
        [self getCrossAxisFirstSectionStartValue:&firstSectionStartValue
                            spaceBetweenSections:&spaceBetweenSections
                             spaceGrowPerSection:&spaceGrowPerSection
                                byCrossSpaceLeft:leftH
                                      crossSpace:maxContentHeight
                                    sectionCount:rowsCount];
        
        BOOL isWrapReverse = self.flexWrapType == LTFlexWrapTypeWrapReverse;
        
        CGFloat sectionsContentCrossValue = 0;
        
        for (LTFlexContainerSectionInfo *info in rowInfos) {
            
            CGFloat sectionMaxHeight = info.sectionHeight+spaceGrowPerSection;
            CGFloat rowContentWidth = info.sectionWidth;
            
            NSUInteger rowViewsCount = info.sectionViews.count;

            CGFloat leftWidth = maxContentWidth-rowContentWidth;
            
            CGFloat spacePerUnit = 0;// 增长或减小的单位大小
            BOOL isForGrow = NO;
            if(leftWidth>0){
                
                isForGrow = YES;
                do {
                    NSDecimalNumber *flexGrowNumber = [info.sectionViews valueForKeyPath:@"self.@sum.lt_flexAttribute.flexGrow"];
                    NSUInteger flexGrowValue = flexGrowNumber.unsignedIntegerValue;
                    if(flexGrowValue==0){
                        break;
                    }
                    spacePerUnit = leftWidth/flexGrowValue;
                } while (NO);
            }else if(leftWidth<0){
                
                isForGrow = NO;
                do {
                    NSDecimalNumber *flexShrinkNumber = [info.sectionViews valueForKeyPath:@"self.@sum.lt_flexAttribute.flexShrink"];
                    NSUInteger flexShrinkValue = flexShrinkNumber.unsignedIntegerValue;
                    if(flexShrinkValue==0){
                        break;
                    }
                    spacePerUnit = leftWidth/flexShrinkValue;
                } while (NO);
            }
            
            CGFloat startX = 0;
            BOOL isReverse = self.flexDirectionType == LTFlexDirectionTypeRowReverse;
     
            CGFloat spaceBetweenItems = 0;
            
            if(spacePerUnit == 0){
                
                [self getMainAxisFirstItemStartValue:&startX
                                   spaceBetweenItems:&spaceBetweenItems
                                 byMainAxisLeftSpace:leftWidth
                                    mainAxisMaxSpace:maxContentWidth
                                          itemsCount:rowViewsCount
                                             reverse:isReverse];
            }
            
            CGFloat sectionStartValue = 0;
            if(isWrapReverse){
                sectionsContentCrossValue = sectionsContentCrossValue + sectionMaxHeight + spaceBetweenSections;
                sectionStartValue = firstSectionStartValue - sectionsContentCrossValue + spaceBetweenSections;
            }else{
                sectionStartValue = firstSectionStartValue + sectionsContentCrossValue;
                sectionsContentCrossValue = sectionsContentCrossValue + sectionMaxHeight + spaceBetweenSections;
            }
            
            CGFloat itemsContentWidth = 0;
            
            for (UIView *itemView in info.sectionViews) {
                
                [self fixCorrectSuperView:itemView];
                
                LTFlexAttribute *flexAttribute = itemView.lt_flexAttribute;
                
                CGSize itemSize = itemView.lt_flexAttribute.cacheSize;
                
                CGFloat y = 0;// row所在行的y偏移量
                CGFloat height = itemSize.height;
                
                CGFloat rowLeftH = sectionMaxHeight - height;
                rowLeftH = MAX(rowLeftH, 0);
                
                [self getCrossAxisItemStartValue:&y
                                  itemCrossValue:&height
                         byItemFlexAlignaSelfTyp:flexAttribute.flexAlignaSelfType
                           sectionCrossLeftSpace:rowLeftH
                            sectionCrossMaxSpace:sectionMaxHeight];
                
                NSUInteger spaceUnitNumber = isForGrow?flexAttribute.flexGrow:flexAttribute.flexShrink;
                CGFloat spaceChangeWidth = spacePerUnit * spaceUnitNumber;
                CGFloat width = itemSize.width+spaceChangeWidth;
                width = MAX(width, 0);
                
                UIEdgeInsets viewMargin = itemView.lt_marginEdgeInsets;
                if(width == 0){
                    viewMargin = UIEdgeInsetsZero;
                }
                
                CGFloat x = 0;
                if(isReverse){
                    itemsContentWidth = itemsContentWidth + width + spaceBetweenItems;
                    x = startX - itemsContentWidth + spaceBetweenItems;
                }else{
                    x = startX + itemsContentWidth;
                    itemsContentWidth = itemsContentWidth + width + spaceBetweenItems;
                }
                
                CGPoint offset = CGPointZero;
                if(_hideContainerView){
                    offset = _containerFrame.origin;
                }
                CGPoint relativeOffset = CGPointZero;
                if(flexAttribute.positionType == LTPositionTypeRelative){
                    relativeOffset = flexAttribute.relativeOffset;
                }
                offset.x = offset.x + relativeOffset.x;
                offset.y = offset.y + relativeOffset.y;
                
                CGFloat left = self.lt_paddingEdgeInsets.left;
                CGFloat top = self.lt_paddingEdgeInsets.top;
                
                itemView.frame = CGRectMake(offset.x+x+left+viewMargin.left,
                                            offset.y+top+sectionStartValue+y+viewMargin.top,
                                            width-UIEdgeInsetsGetWidth(viewMargin),
                                            height-UIEdgeInsetsGetHeight(viewMargin));
            }
        }
        
        // 处理脱标view
        [self layoutfixedAndAbsouteView:fixedAndAbsoluteViewSet
                       withContinerSize:result];
    }
    
    return result;
}

- (void)layoutfixedAndAbsouteView:(NSMutableSet <UIView *>*)viewSet withContinerSize:(CGSize)size{
    
    [viewSet enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, BOOL * _Nonnull stop) {
        
        LTPositionType type = obj.lt_flexAttribute.positionType;
        
        switch (type) {
            case LTPositionTypeAbsolute:
                [self layoutAbsouteView:obj withContinerSize:size];
                break;
            case LTPositionTypeFixed:
                [self layoutFixedView:obj];
                break;
            default:
                NSLog(@"未处理view PositionType(%@):%@", @(type), obj);
                break;
        }

    }];
}

- (void)fixCorrectSuperView:(UIView *)view{
    
    if(_hideContainerView){
        
        LTFlexContainer *superview = (LTFlexContainer *)self.superview;
        
        //                    while ([superview isKindOfClass:[LTFlexContainer class]] && superview.hideContainerView) {
        //                        superview = (LTFlexContainer *)superview.superview;
        //                    }
        if(superview&&view.superview != superview){
            
            if([superview isKindOfClass:[LTFlexContainer class]]){
                [superview lt_addSubview:view];
            }else{
                [superview addSubview:view];
            }
        }
    }else{
        
        if(view.superview != self){
            
            [super addSubview:view];
        }
    }
}

- (void)getMainAxisFirstItemStartValue:(CGFloat *)startValue
                     spaceBetweenItems:(CGFloat *)spaceBetweenItems
                   byMainAxisLeftSpace:(CGFloat)leftSpace
                      mainAxisMaxSpace:(CGFloat)mainAxisMaxSpace
                            itemsCount:(NSUInteger)itemsCount
                               reverse:(BOOL)reverse{
    
    CGFloat validLeftSpace = MAX(leftSpace, 0);
    
    switch (self.flexJustifyContentType) {
        case LTFlexJustifyContentTypeFlexStart:{
            if(reverse){
                *startValue = mainAxisMaxSpace;
            }else{
                *startValue = 0;
            }
            break;
        }
        case LTFlexJustifyContentTypeFlexEnd:{
            if(reverse){
                *startValue = mainAxisMaxSpace-validLeftSpace;
            }else{
                *startValue = validLeftSpace;
            }
            break;
        }
        case LTFlexJustifyContentTypeCenter:{
            if(reverse){
                *startValue = mainAxisMaxSpace - validLeftSpace/2;
            }else{
                *startValue = validLeftSpace/2;
            }
            break;
        }
        case LTFlexJustifyContentTypeSpaceBetween:{
            if(validLeftSpace>0 && itemsCount>1){
                *spaceBetweenItems = validLeftSpace/(itemsCount-1);
            }
            if(reverse){
                *startValue = mainAxisMaxSpace;
            }else{
                *startValue = 0;
            }
            break;
        }
        case LTFlexJustifyContentTypeSpaceAround:{
            
            CGFloat space = 0;
            if(validLeftSpace>0){
                space = validLeftSpace/(2*itemsCount);;
                *spaceBetweenItems = 2*space;
            }
            if(reverse){
                *startValue = mainAxisMaxSpace - space;
            }else{
                *startValue = space;
            }
            break;
        }
    }
}

- (void)getCrossAxisFirstSectionStartValue:(CGFloat *)sectionStartValue
                      spaceBetweenSections:(CGFloat *)spaceBetweenSections
                       spaceGrowPerSection:(CGFloat *)spaceGrowPerSection
                          byCrossSpaceLeft:(CGFloat)crossSpaceLeft
                                crossSpace:(CGFloat)crossSpace
                              sectionCount:(NSUInteger)sectionCount{
    
    CGFloat validCrossSpaceLeft = MAX(0, crossSpaceLeft);
    
    BOOL isWrapReverse = self.flexWrapType == LTFlexWrapTypeWrapReverse;
    
    switch (self.flexAlignContentType) {
        case LTFlexAlignContentTypeFlexStart:{
            if(isWrapReverse){
                *sectionStartValue = crossSpace;
            }else{
                *sectionStartValue = 0;
            }
            break;
        }
        case LTFlexAlignContentTypeFlexEnd:{
            if(isWrapReverse){
                *sectionStartValue = crossSpace-validCrossSpaceLeft;
            }else{
                *sectionStartValue = validCrossSpaceLeft;
            }
            break;
        }
        case LTFlexAlignContentTypeCenter:{
            if(isWrapReverse){
                *sectionStartValue = crossSpace-validCrossSpaceLeft/2;
            }else{
                *sectionStartValue = validCrossSpaceLeft/2;
            }
            break;
        }
        case LTFlexAlignContentTypeSpaceBetween:{
            if(sectionCount>1){
                *spaceBetweenSections = validCrossSpaceLeft/(sectionCount-1);
            }
            if(isWrapReverse){
                *sectionStartValue = crossSpace;
            }else{
                *sectionStartValue = 0;
            }
            break;
        }
        case LTFlexAlignContentTypeSpaceAround:{
            CGFloat space = validCrossSpaceLeft/(2*sectionCount);
            *spaceBetweenSections = 2*space;
            if(isWrapReverse){
                *sectionStartValue = crossSpace-space;
            }else{
                *sectionStartValue = space;
            }
            break;
        }
        case LTFlexAlignContentTypeStretch:{
            
            do {
                if(validCrossSpaceLeft == 0 || sectionCount < 1){
                    break;
                }
                *spaceGrowPerSection = validCrossSpaceLeft/sectionCount;
            } while (NO);
            if(isWrapReverse){
                *sectionStartValue = crossSpace;
            }else{
                *sectionStartValue = 0;
            }
            break;
        }
    }
}

- (void)getCrossAxisItemStartValue:(CGFloat *)startValue
                    itemCrossValue:(CGFloat *)itemCrossValue
           byItemFlexAlignaSelfTyp:(LTFlexAlignaSelfType)type
             sectionCrossLeftSpace:(CGFloat)leftSpacce
              sectionCrossMaxSpace:(CGFloat)sectionCrossMaxSpace{
    
    switch (type) {
        case LTFlexAlignaSelfTypeFlexStart:{
            break;
        }
        case LTFlexAlignaSelfTypeFlexEnd:{
            *startValue = leftSpacce;
            break;
        }
        case LTFlexAlignaSelfTypeFlexCenter:{
            *startValue = leftSpacce/2;
            break;
        }
        case LTFlexAlignaSelfTypeFlexStretch:{
            *itemCrossValue = sectionCrossMaxSpace;
            break;
        }
        case LTFlexAlignaSelfTypeAuto:{
            
            switch (self.flexAlignItemsType) {
                case LTFlexAlignItemsTypeFlexStart:{
                    break;
                }
                case LTFlexAlignItemsTypeFlexEnd:{
                    *startValue = leftSpacce;
                    break;
                }
                case LTFlexAlignItemsTypeCenter:{
                    *startValue = leftSpacce/2;
                    break;
                }
                case LTFlexAlignItemsTypeStretch:{
                    *itemCrossValue = sectionCrossMaxSpace;
                    break;
                }
            }
            break;
        }
    }
}

- (void)layoutAbsouteView:(UIView *)view withContinerSize:(CGSize)size{
    
    [self fixCorrectSuperView:view];
    
    CGRect frame = [self getFrame:view inSize:size];
    
    if(_hideContainerView){
        CGPoint offset = _containerFrame.origin;
        frame.origin.x += offset.x;
        frame.origin.y += offset.y;
    }
    
    view.frame = frame;
}

- (void)layoutFixedView:(UIView *)view{
    
    UIView *superview = self.window;
    if(!superview){
        return;
    }
    if(view.superview != superview){
        
        [superview addSubview:view];
    }
    
    CGSize size = superview.bounds.size;
    
    CGRect frame = [self getFrame:view inSize:size];
    
    view.frame = frame;
}

- (CGRect)getFrame:(UIView *)view inSize:(CGSize)size{
    
    CGRect frame;
    
    BOOL ltValid = NO;
    if (view.lt_marginEdgeInsets.left < LT_FLEX_MAX_VALUE) {
        ltValid = YES;
        frame.origin.x = view.lt_marginEdgeInsets.left;
    }
    if (view.lt_marginEdgeInsets.right < LT_FLEX_MAX_VALUE){

        if(ltValid){
            frame.size.width = size.width-view.lt_marginEdgeInsets.left-view.lt_marginEdgeInsets.right;
        }else{
            frame.origin.x = size.width-view.lt_marginEdgeInsets.right-view.lt_flexAttribute.cacheSize.width;
            frame.size.width = view.lt_flexAttribute.cacheSize.width;
        }
    }else{
        
        frame.size.width = view.lt_flexAttribute.cacheSize.width;
        
        if(!ltValid){
            frame.origin.x = 0;
        }
    }
    
    ltValid = NO;
    if (view.lt_marginEdgeInsets.top < LT_FLEX_MAX_VALUE) {
        ltValid = YES;
        frame.origin.y = view.lt_marginEdgeInsets.top;
    }
    if (view.lt_marginEdgeInsets.bottom < LT_FLEX_MAX_VALUE){
        
        if(ltValid){
            frame.size.height = size.height-view.lt_marginEdgeInsets.top-view.lt_marginEdgeInsets.bottom;
        }else{
            frame.origin.y = size.height-view.lt_marginEdgeInsets.bottom-view.lt_flexAttribute.cacheSize.height;
            frame.size.height = view.lt_flexAttribute.cacheSize.height;
        }
    }else{
        
        frame.size.height = view.lt_flexAttribute.cacheSize.height;
        
        if(!ltValid){
            frame.origin.y = 0;
        }
    }
    
    return frame;
}

#ifdef DEBUG
#pragma mark - for lookin

- (NSDictionary<NSString *, id> *)lookin_customDebugInfos_3{
    NSDictionary<NSString *, id> *ret = @{
        @"properties": [self flex_makeCustomProperties_3],
    };
    return ret;
}

- (NSArray *)flex_makeCustomProperties_3{

    NSMutableArray *properties = [[NSMutableArray alloc] init];
    
//    SEL sel = NSSelectorFromString(@"flex_makeCustomProperties");
//    if([[self superclass] instancesRespondToSelector:sel]){
//        
//        Class superCls = class_getSuperclass([self class]);
//        struct objc_super obj_super_class = {
//            .receiver = self,
//            .super_class = superCls
//        };
//        NSArray * (*getProperties)(void *, SEL) = (void *)objc_msgSendSuper;
//        NSArray *viewProperties = getProperties(&obj_super_class, sel);
//    
//        if(viewProperties.count > 0){
//            
//            [properties addObjectsFromArray:viewProperties];
//        }
//    }
    
    // bool property
    [properties addObject:@{
        @"section": @"Flex",
        @"title": @"Hide ContainerView",
        @"value": [NSNumber numberWithBool:self.hideContainerView],
        @"valueType": @"bool",
        @"retainedSetter": ^(BOOL newBool) {
        self.hideContainerView = newBool;
    }
    }];
    
    // bool property
    [properties addObject:@{
        @"section": @"Flex",
        @"title": @"Hidden",
        @"value": [NSNumber numberWithBool:self.hidden],
        @"valueType": @"bool",
        @"retainedSetter": ^(BOOL newBool) {
        self.hidden = newBool;
    }
    }];
    
    {
        NSDictionary *enumInfo = @{@"LTFlexDirectionTypeRow":@(LTFlexDirectionTypeRow),
                                   @"LTFlexDirectionTypeColumn":@(LTFlexDirectionTypeColumn),
                                   @"LTFlexDirectionTypeRowReverse":@(LTFlexDirectionTypeRowReverse),
                                   @"LTFlexDirectionTypeColumnReverse":@(LTFlexDirectionTypeColumnReverse)
        };
        NSString *defaultString = [[enumInfo allKeysForObject:@(self.flexDirectionType)] firstObject];
        
        [properties addObject:@{
            @"section": @"Flex",
            @"title": @"Direction",
            @"value": defaultString,
            @"valueType": @"enum",
            @"allEnumCases": [enumInfo allKeys],
            @"retainedSetter": ^(NSString *newValue) {
            
            self.flexDirectionType = [enumInfo[newValue] integerValue];
        }
        }];
    }
    {
        NSDictionary *enumInfo = @{@"LTFlexWrapTypeWrap":@(LTFlexWrapTypeWrap),
                                   @"LTFlexWrapTypeNoWrap":@(LTFlexWrapTypeNoWrap),
                                   @"LTFlexWrapTypeWrapReverse":@(LTFlexWrapTypeWrapReverse)
        };
        
        NSString *defaultString = [[enumInfo allKeysForObject:@(self.flexWrapType)] firstObject];
        
        [properties addObject:@{
            @"section": @"Flex",
            @"title": @"Wrap",
            @"value": defaultString,
            @"valueType": @"enum",
            @"allEnumCases": [enumInfo allKeys],
            @"retainedSetter": ^(NSString *newValue) {
            
            self.flexWrapType = [enumInfo[newValue] integerValue];
        }
        }];
    }
    {
        NSDictionary *enumInfo = @{@"LTFlexJustifyContentTypeFlexStart":@(LTFlexJustifyContentTypeFlexStart),
                                   @"LTFlexJustifyContentTypeCenter":@(LTFlexJustifyContentTypeCenter),
                                   @"LTFlexJustifyContentTypeFlexEnd":@(LTFlexJustifyContentTypeFlexEnd),
                                   @"LTFlexJustifyContentTypeSpaceBetween":@(LTFlexJustifyContentTypeSpaceBetween),
                                   @"LTFlexJustifyContentTypeSpaceAround":@(LTFlexJustifyContentTypeSpaceAround)};
        
        NSString *defaultString = [[enumInfo allKeysForObject:@(self.flexJustifyContentType)] firstObject];
        
        [properties addObject:@{
            @"section": @"Flex",
            @"title": @"Justify Content",
            @"value": defaultString,
            @"valueType": @"enum",
            @"allEnumCases": [enumInfo allKeys],
            @"retainedSetter": ^(NSString *newValue) {
            
            self.flexJustifyContentType = [enumInfo[newValue] integerValue];
        }
        }];
    }
    {
        NSDictionary *enumInfo = @{@"LTFlexAlignItemsTypeFlexStart":@(LTFlexAlignItemsTypeFlexStart),
                                   @"LTFlexAlignItemsTypeFlexEnd":@(LTFlexAlignItemsTypeFlexEnd),
                                   @"LTFlexAlignItemsTypeCenter":@(LTFlexAlignItemsTypeCenter),
                                   @"LTFlexAlignItemsTypeStretch":@(LTFlexAlignItemsTypeStretch)};
        
        NSString *defaultString = [[enumInfo allKeysForObject:@(self.flexAlignItemsType)] firstObject];
        
        [properties addObject:@{
            @"section": @"Flex",
            @"title": @"Align Items",
            @"value": defaultString,
            @"valueType": @"enum",
            @"allEnumCases": [enumInfo allKeys],
            @"retainedSetter": ^(NSString *newValue) {
            
            self.flexAlignItemsType = [enumInfo[newValue] integerValue];
        }
        }];
    }
    {
        NSDictionary *enumInfo = @{@"LTFlexAlignContentTypeFlexStart":@(LTFlexAlignContentTypeFlexStart),
                                   @"LTFlexAlignContentTypeCenter":@(LTFlexAlignContentTypeCenter),
                                   @"LTFlexAlignContentTypeFlexEnd":@(LTFlexAlignContentTypeFlexEnd),
                                   @"LTFlexAlignContentTypeSpaceBetween":@(LTFlexAlignContentTypeSpaceBetween),
                                   @"LTFlexAlignContentTypeSpaceAround":@(LTFlexAlignContentTypeSpaceAround),
                                   @"LTFlexAlignContentTypeStretch":@(LTFlexAlignContentTypeStretch)};
        
        NSString *defaultString = [[enumInfo allKeysForObject:@(self.flexAlignContentType)] firstObject];
        
        [properties addObject:@{
            @"section": @"Flex",
            @"title": @"Align Content",
            @"value": defaultString,
            @"valueType": @"enum",
            @"allEnumCases": [enumInfo allKeys],
            @"retainedSetter": ^(NSString *newValue) {
            
            self.flexAlignContentType = [enumInfo[newValue] integerValue];
        }
        }];
    }
    
    return [properties copy];;
}
#endif

@end
