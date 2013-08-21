#import "SpriteEx.h"
#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum tagButtonState 
{
    kButtonStatePressed,
    kButtonStateNotPressed
} ButtonState;

typedef enum tagButtonStatus 
{
    kButtonStatusEnabled,
    kButtonStatusDisabled
} ButtonStatus;

@interface ButtonControl: CCSpriteEx <CCTargetedTouchDelegate> 
{
@private
    ButtonState  buttonState;
    ButtonStatus buttonStatus;  
    
    CCTexture2D*    buttonNormal;
    CCTexture2D*    buttonLit;
}

@property(nonatomic, readonly) CGRect rect;

+ (id)buttonWithTextures:(CCTexture2D*)normalTexture
              litTexture:(CCTexture2D*)litTexture;

-(id)initWithTexture:(CCTexture2D *)texture 
          litTexture:(CCTexture2D*)litTexture;

-(void)setNormalTexture:(CCTexture2D*)normalTexture;
-(void)setLitTexture:(CCTexture2D*)litTexture;

- (BOOL)isPressed;
- (BOOL)isNotPressed;
- (void)makeDisabled;
- (void)makeEnabled;
- (BOOL)isEnabled;
- (BOOL)isDisabled;
- (void)makeLit;
- (void)makeNormal;
- (void)dealloc;

// Change state 
-(void) togglePressed;
-(void) depress;

@end