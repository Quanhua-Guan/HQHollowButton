//
//  HQHollowButton.m
//  HQHollowButton
//
//  Created by 泉华 官 on 15/6/5.
//  Copyright (c) 2015年 CQMH. All rights reserved.
//

#import "HQHollowButton.h"
#import <CoreText/CoreText.h>

@implementation HQHollowButton{
    UIColor *buttonRealBackgroundColor;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

-(void)setup
{
    
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    [self setTitleColor: [UIColor clearColor] forState: UIControlStateNormal];
}

- (UIColor *)getBackgroundColor {
    return buttonRealBackgroundColor;
}

-(void)setBackgroundColor:(UIColor *)backgroundColor {
    super.backgroundColor = [UIColor clearColor];
    buttonRealBackgroundColor = backgroundColor;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(ctx, YES);
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRect:rect];
    
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:self.currentTitle attributes:@{NSForegroundColorAttributeName: self.currentTitleColor, NSFontAttributeName: self.titleLabel.font}];
    
    NSAttributedString *attrString = str;
    CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)attrString);
    CFArrayRef runArray = CTLineGetGlyphRuns(line);
    
    ////////get the cgpath of attributed title////////
    // for each RUN
    CGMutablePathRef lettersPath = CGPathCreateMutable();
    for (CFIndex runIndex = 0; runIndex < CFArrayGetCount(runArray); runIndex++)
    {
        // Get FONT for this run
        CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runArray, runIndex);
        CTFontRef runFont = CFDictionaryGetValue(CTRunGetAttributes(run), kCTFontAttributeName);
        
        // for each GLYPH in run
        for (CFIndex runGlyphIndex = 0; runGlyphIndex < CTRunGetGlyphCount(run); runGlyphIndex++)
        {
            // get Glyph & Glyph-data
            CFRange thisGlyphRange = CFRangeMake(runGlyphIndex, 1);
            CGGlyph glyph;
            CGPoint position;
            CTRunGetGlyphs(run, thisGlyphRange, &glyph);
            CTRunGetPositions(run, thisGlyphRange, &position);
            
            // Get PATH of outline
            {
                CGPathRef letter = CTFontCreatePathForGlyph(runFont, glyph, NULL);
                CGAffineTransform t = CGAffineTransformMakeTranslation(position.x, position.y);
                CGPathAddPath(lettersPath, &t, letter);
                CGPathRelease(letter);
            }
        }
    }
    CFRelease(line);
    CGPathCloseSubpath(lettersPath);
    
    ///////////////
    
    CGRect stringBoundingRect = [attrString boundingRectWithSize:rect.size
                                                         options:(NSStringDrawingUsesLineFragmentOrigin |  NSStringDrawingUsesFontLeading)
                                                         context:nil];// 宽度准确可用
    CGRect pathBoundingBox = CGPathGetBoundingBox(lettersPath);// 高度准确可用
    CGRect stringRect = CGRectMake(0, 0, ceil(stringBoundingRect.size.width), ceil(pathBoundingBox.size.height));
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformTranslate(transform, self.titleLabel.center.x - (stringRect.size.width) / 2.0, self.titleLabel.center.y + stringRect.size.height / 2.0f);
    
    transform = CGAffineTransformScale(transform, 1.0, -1.0);
    CGMutablePathRef stringPath = CGPathCreateMutableCopyByTransformingPath(lettersPath, &transform);
    CFRelease(lettersPath);
    [bezierPath setUsesEvenOddFillRule:YES];
    [bezierPath appendPath:[UIBezierPath bezierPathWithCGPath:stringPath]];
    
    [buttonRealBackgroundColor set];
    [bezierPath addClip];
    
    CGContextAddPath(ctx, bezierPath.CGPath);
    CGContextFillPath(ctx);
    
    CFRelease(stringPath);
}

@end
