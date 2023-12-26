//
//  LTLabel.m
//  LTStudy
//
//  Created by 龙 on 2023/11/14.
//

#import "LTLabel.h"

@implementation LTLabel

- (instancetype)initWithFrame:(CGRect)frame{
    
    if(self = [super initWithFrame:frame]){
        
        [self initial];
    }
    return self;
}

- (void)initial{
    
    self.font = [UIFont systemFontOfSize:14];
}

-(CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines{
    
    CGRect textRect = [super textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
    
    CGRect contentRect = CGRectMake(textRect.origin.x-self.lt_paddingEdgeInsets.left,
                                    textRect.origin.y-self.lt_paddingEdgeInsets.top,
                                    textRect.size.width+UIEdgeInsetsGetWidth(self.lt_paddingEdgeInsets),
                                    textRect.size.height+UIEdgeInsetsGetHeight(self.lt_paddingEdgeInsets));
    return contentRect;
}

-(void)drawTextInRect:(CGRect)rect{
    
    CGRect contentRect = UIEdgeInsetsInsetRect(rect, self.lt_paddingEdgeInsets);
    [super drawTextInRect:contentRect];
}

@end
