//
//  LTCGRect.h
//  SFB
//
//  Created by 龙 on 2023/12/15.
//  Copyright © 2023 yelon. All rights reserved.
//

#ifndef LTCGRect_h
#define LTCGRect_h
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

UIKIT_STATIC_INLINE BOOL LTCGRectEqualToRect(CGRect rect1, CGRect rect2) {
    
    CGFloat unit = 0.001;
    
    if(fabs(rect1.origin.x-rect2.origin.x) >= unit
       ||fabs(rect1.origin.y-rect2.origin.y) >= unit
       ||fabs(rect1.size.width-rect2.size.width) >= unit
       ||fabs(rect1.size.height-rect2.size.height) >= unit){
        return NO;
    }
    return YES;
}

#endif /* LTCGRect_h */
