#include "cocos2d.h"
#import "MovingObject.h"


@interface NPC: MovingObject
{
    
}
- (void)dealloc;
- (void)step:(ccTime)delta;
@end


@interface Navalny : NPC 
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

@interface Sobchak : NPC 
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

@interface Timoty : NPC 
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
