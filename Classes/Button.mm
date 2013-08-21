#include "Button.h"

@implementation ButtonControl

- (CGRect)rect 
{
    CGSize s = [self.texture contentSize];
    return CGRectMake(-s.width / 2, -s.height / 2, s.width, s.height);
}

+ (id)buttonWithTextures:(CCTexture2D*)normalTexture 
              litTexture:(CCTexture2D*)litTexture
{
    ButtonControl* btn = [[self alloc]initWithTexture:normalTexture litTexture:litTexture];
    return btn;
}

-(id)initWithTexture:(CCTexture2D *)texture litTexture:(CCTexture2D*)litTexture
{
    if(self=[super initWithTexture:texture])
    {
        [self setNormalTexture:texture];
        [self setLitTexture:litTexture];
    }
    return self;
}

-(void)setNormalTexture:(CCTexture2D*)normalTexture
{
    buttonNormal = normalTexture;
}

-(void)setLitTexture:(CCTexture2D*)litTexture
{
    buttonLit = litTexture;
}

-(void) togglePressed
{
    buttonState = (buttonState==kButtonStateNotPressed)?kButtonStatePressed:kButtonStateNotPressed;
}

-(void) depress
{
    buttonState = kButtonStateNotPressed;
}

- (BOOL)isPressed 
{
    if (buttonState== kButtonStateNotPressed) 
        return NO;
    if (buttonState== kButtonStatePressed) 
        return YES;
    return NO;
}

- (BOOL)isNotPressed 
{
    if (buttonState== kButtonStateNotPressed) 
        return YES;
    if (buttonState== kButtonStatePressed) 
        return NO;
    return YES;
}

- (void)makeDisabled
{
    buttonStatus = kButtonStatusDisabled;
    buttonState= kButtonStateNotPressed;
    [self makeNormal];
}

- (void)makeEnabled 
{
    buttonStatus = kButtonStatusEnabled;
    buttonState  = kButtonStateNotPressed;
    [self makeNormal];
}

- (BOOL)isEnabled 
{
    if (buttonStatus== kButtonStatusDisabled) 
        return NO;
    if (buttonStatus== kButtonStatusEnabled) 
        return YES;
    return NO;
}

- (BOOL)isDisabled 
{
    if (buttonStatus== kButtonStatusEnabled) 
        return NO;
    if (buttonStatus== kButtonStatusDisabled) 
        return YES;
    return YES;
}

- (void)makeLit 
{
    [self setTexture:buttonLit];
}

- (void)makeNormal 
{
    [self setTexture:buttonNormal];
}

- (void)onEnter 
{
    if (buttonStatus == kButtonStatusDisabled) 
        return;
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:NO];
    [super onEnter];
}

- (void)onExit 
{
    if (buttonStatus == kButtonStatusDisabled) 
        return;
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    [super onExit];
}   

- (BOOL)containsTouchLocation:(UITouch *)touch 
{
    return CGRectContainsPoint(self.rect, [self convertTouchToNodeSpaceAR:touch]);
}

- (BOOL)ccTouchBegan:(UITouch *)touch 
           withEvent:(UIEvent *)event 
{
    if (buttonStatus == kButtonStatusDisabled) return NO;
    if (buttonState== kButtonStatePressed) return NO;
    if ( ![self containsTouchLocation:touch] ) return NO;
    
    buttonState= kButtonStatePressed;
    [self makeLit];
    
    return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event 
{
    // If it weren't for the TouchDispatcher, you would need to keep a reference
    // to the touch from touchBegan and check that the current touch is the same
    // as that one.
    // Actually, it would be even more complicated since in the Cocos dispatcher
    // you get NSSets instead of 1 UITouch, so you'd need to loop through the set
    // in each touchXXX method.
    
    if (buttonStatus == kButtonStatusDisabled) return;
    if ([self containsTouchLocation:touch]) return;
    
    buttonState= kButtonStateNotPressed;
    [self makeNormal];
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event 
{
    if (buttonStatus == kButtonStatusDisabled) return;
    
    buttonState= kButtonStateNotPressed;
    [self makeNormal];
}

- (void)dealloc 
{
    [buttonNormal release];
    [buttonLit release];
    [super dealloc];
}

@end
