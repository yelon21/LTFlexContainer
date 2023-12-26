//
//  UIView+LTFlex.h
//  LTStudy
//
//  Created by 龙 on 2023/12/6.
//

#import <UIKit/UIKit.h>
#import "LTUIEdgeInsets.h"
#import "LTFlexAttribute.h"

@interface UIView (LTFlex)

@property(nonatomic, strong) LTFlexAttribute *lt_flexAttribute;
// private
@property(nonatomic, assign) BOOL lt_cachedHidden;
@property(nonatomic, assign) BOOL lt_cachingdHiddenState;
@end

@interface UIView (LTLayout)

@property (nonatomic, assign) IBInspectable UIEdgeInsets lt_paddingEdgeInsets;
@property (nonatomic, assign) IBInspectable UIEdgeInsets lt_marginEdgeInsets;

-(CGSize)sizeThatFits:(CGSize)size layout:(BOOL)layout;
@end
