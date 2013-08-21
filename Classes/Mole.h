#import "cocos2d.h"
#import "SpriteEx.h"
#import "StageBase.h"
#import "MovingObject.h"

@interface Mole : MovingObject 
{
@private
    
}

- (id)initWithWorld:(StageBase<IStage>*)stageBase 
               name:(NSString*)name
                pos:(CGPoint)pos
              props:(NSMutableDictionary*)props;
- (void)dealloc;
- (void)step:(ccTime)delta;

@end


