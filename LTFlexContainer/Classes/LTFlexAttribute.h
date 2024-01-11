//
//  LTFlexAttribute.h
//  LTStudy
//
//  Created by 龙 on 2023/12/20.
//  Copyright © 2023 yelon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class LTFlexContainer;

typedef enum : NSUInteger {
    LTFlexAlignSelfTypeAuto,
    LTFlexAlignSelfTypeFlexStart,
    LTFlexAlignSelfTypeFlexEnd,
    LTFlexAlignSelfTypeFlexCenter,
    LTFlexAlignSelfTypeFlexStretch,
} LTFlexAlignSelfType;

typedef enum : NSUInteger {
    LTPositionTypeStatic,
    LTPositionTypeRelative,// 占位，相对于原始位置偏移，lt_relativeOffsetPoint
    LTPositionTypeAbsolute,// 不占位，在父视图中定位，根据margin参数进行确定,优先top、left，若想使用bottom或right ，需要将top或left设为CGFLOAT_MAX
    LTPositionTypeFixed,// 不占位，在window中定位，根据margin参数进行确定
} LTPositionType;

@interface LTFlexAttribute : NSObject

@property(nonatomic, assign) LTFlexAlignSelfType flexAlignaSelfType;

// 属性用来定义项目的排列顺序。数值越小，排列越靠前，默认为 0 。使用形式如下:
@property(nonatomic, assign) CGFloat flexOrder;
// 定义项目的放大比例，默认为 0 ，即如果存在剩余空间，也不放大
// 如果所有项目的flexGrow属性都为 1，则它们将等分剩余空间（如果有的话）。
// 如果一个项目的flexGrow属性为2，其他项目都为1，则前者占据的剩余空间将比其他项多一倍。
@property(nonatomic, assign) NSUInteger flexGrow;
// 如果空间不足，该项目将缩小, 如果所有项目的flexShrink属性都为1，当空间不足时，都将等比例缩小。
// 如果一个项目的flexShrink属性为 0，其他项目都为 1，则空间不足时，前者不缩小。
// 默认为 0
@property(nonatomic, assign) NSUInteger flexShrink;

// 当视图隐藏时候是否占位
@property(nonatomic, assign) BOOL holdPlaceholder;

@property(nonatomic, assign) LTPositionType positionType;
@property(nonatomic, assign) CGPoint relativeOffset;

// 固定的size，若不为CGSizeZero则根据内容计算，否则不计算。注意包含padding但不包含margin。
@property(nonatomic, assign) CGSize fixedSize; // 优先级小于flexGrow、flexShrink

@property(nonatomic, assign) CGFloat minHeight; // 优先级小于flexGrow、flexShrink
@property(nonatomic, assign) CGFloat maxHeight; // 优先级小于flexGrow、flexShrink
@property(nonatomic, assign) CGFloat minWidth; // 优先级小于flexGrow、flexShrink
@property(nonatomic, assign) CGFloat maxWidth; // 优先级小于flexGrow、flexShrink
// private
// 布局计算出的size
@property(nonatomic, assign) CGSize cacheSize;
@property(nonatomic, weak) LTFlexContainer *superView;

+ (instancetype)createWidthView:(UIView *)view;
@end
