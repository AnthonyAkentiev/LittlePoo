#import "cocos2d.h"

@interface CCSpriteEx: CCSprite {}

- (void)setWidth:(float)width;
- (void)setHeight:(float)height;

- (void)setWidthScaled:(float)width;
- (void)setHeightScaled:(float)height;

- (void)setPositionLowerLeft:(CGPoint)pos;

// scaled size!
- (CGSize) getContentSize;

@end