//
//  LTUIEdgeInsets.h
//  LTStudy
//
//  Created by 龙 on 2023/11/2.
//

#ifndef LTUIEdgeInsets_h
#define LTUIEdgeInsets_h

#import <UIKit/UIKitDefines.h>

UIKIT_STATIC_INLINE CGFloat UIEdgeInsetsGetWidth(UIEdgeInsets insets) {
    return insets.left + insets.right;
}

UIKIT_STATIC_INLINE CGFloat UIEdgeInsetsGetHeight(UIEdgeInsets insets) {
    return insets.top + insets.bottom;
}

UIKIT_STATIC_INLINE CGFloat UIEdgeInsetsGetSpaceWidth(UIEdgeInsets padding, UIEdgeInsets margin) {
    return padding.left + padding.right + margin.left + margin.right;
}

UIKIT_STATIC_INLINE CGFloat UIEdgeInsetsGetSpaceHeight(UIEdgeInsets padding, UIEdgeInsets margin) {
    return padding.top + padding.bottom + margin.top + margin.bottom;
}


#endif /* LTUIEdgeInsets_h */
