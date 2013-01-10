//
//  CUnit.h
//  armies
//
//  Created by Дмитрий Заборовский on 1/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "CAABB.h"
#import "CSprite.h"

@interface CUnit : CSprite
{
    CAABB* box;
    GLKVector2 speed;
    
    BOOL bCollidable;
    BOOL bActive;
}

@property (nonatomic,retain) CAABB* box;
@property (nonatomic) GLKVector2 speed;

-(id)init;
-(void)update:(NSTimeInterval)dt;
-(void)setSizeX:(float)sizeX sizeY:(float)sizeY;

@end
