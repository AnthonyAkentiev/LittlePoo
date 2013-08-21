#include "SpriteEx.h"
#include "helpers.h"

@implementation CCSpriteEx

- (void)setWidth:(float)width
{
	// calc approp value for scaleX...
	float newScale = (width * self.scaleX)/self.contentSize.width;
	self.scaleX = newScale; 
}

- (void)setWidthScaled:(float)width
{
    // calc approp value for scaleX...
	float newScale = (width * self.scaleX)/self.contentSize.width;
    
    //newScale*=([[UIScreen mainScreen] scale]);
    
	self.scaleX = newScale;
    self.scaleY = newScale;
}

- (void) setHeightScaled:(float)height
{
    float newScale = (height * self.scaleY)/self.contentSize.height;
    
	self.scaleX = newScale;
    self.scaleY = newScale;
}

- (void)setHeight:(float)height
{
	// calc approp value for scaleY...
	float newScale = (height * self.scaleY)/self.contentSize.height;
	self.scaleY = newScale;
}

-(void)setPositionLowerLeft:(CGPoint)pos
{   
	[super setPosition:pos];
}

- (CGSize) getContentSize
{
    CGSize out = self.contentSize;
    out.width*=self.scaleX;
    out.height*=self.scaleY;
    return out;
}
@end
