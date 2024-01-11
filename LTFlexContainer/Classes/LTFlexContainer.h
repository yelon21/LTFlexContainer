//
//  LTFlexContainer.h
//  LTStudy
//
//  Created by 龙 on 2023/12/6.
//

#import <UIKit/UIKit.h>
#import "UIView+LTFlex.h"
#import "LTCGRect.h"
#import "LTUIEdgeInsets.h"
// 方向
typedef enum : NSUInteger {
    LTFlexDirectionTypeRow,
    LTFlexDirectionTypeRowReverse,
    LTFlexDirectionTypeColumn,
    LTFlexDirectionTypeColumnReverse,
} LTFlexDirectionType;

// 换行
typedef enum : NSUInteger {
    LTFlexWrapTypeNoWrap,
    LTFlexWrapTypeWrap,
    LTFlexWrapTypeWrapReverse,
} LTFlexWrapType;

// 主轴
typedef enum : NSUInteger {
    LTFlexJustifyContentTypeFlexStart,
    LTFlexJustifyContentTypeCenter,
    LTFlexJustifyContentTypeFlexEnd,
    LTFlexJustifyContentTypeSpaceBetween,
    LTFlexJustifyContentTypeSpaceAround,
} LTFlexJustifyContentType;
// 交叉轴
typedef enum : NSUInteger {
    LTFlexAlignItemsTypeFlexStart,
    LTFlexAlignItemsTypeCenter,
    LTFlexAlignItemsTypeFlexEnd,
    LTFlexAlignItemsTypeStretch,
} LTFlexAlignItemsType;

// 多根轴线的对齐方
typedef enum : NSUInteger {
    LTFlexAlignContentTypeStretch,
    LTFlexAlignContentTypeFlexStart,
    LTFlexAlignContentTypeCenter,
    LTFlexAlignContentTypeFlexEnd,
    LTFlexAlignContentTypeSpaceBetween,
    LTFlexAlignContentTypeSpaceAround,
} LTFlexAlignContentType;

IB_DESIGNABLE

@interface LTFlexContainer : UIView

@property (nonatomic, assign) LTFlexDirectionType flexDirectionType;
@property (nonatomic, assign) LTFlexWrapType flexWrapType;
@property (nonatomic, assign) LTFlexJustifyContentType flexJustifyContentType;
@property (nonatomic, assign) LTFlexAlignItemsType flexAlignItemsType;
@property (nonatomic, assign) LTFlexAlignContentType flexAlignContentType;

// 隐藏container view,subviews直接添加到container view父视图
@property (nonatomic, assign) IBInspectable BOOL hideContainerView;

-(instancetype)initWidthHideContainerView:(BOOL)hideContainerView;
-(NSArray *)lt_subviews;
@end

@interface LTFlexContainer ()

@property (nonatomic, strong) IBInspectable NSString *debugInfo;

-(void)lt_deleteSubview:(UIView *)subview;
-(void)lt_removeAllSubviews;

@end
