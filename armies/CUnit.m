//
//  CUnit.m
//  armies
//
//  Created by Дмитрий Заборовский on 1/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CUnit.h"


@implementation CUnit

@synthesize box;
@synthesize speed;

-(id)init
{
    self = [super init];
    
    box = [[CAABB alloc] init];
    speed = GLKVector2Make(1.f, 1.f);
    
    return self;
}

-(void)update:(NSTimeInterval)dt
{
    [self setPosition:GLKVector2Add(pos, GLKVector2MultiplyScalar(speed, dt))];
    
    [box setPosX:pos.x posY:pos.y];
}

-(void)setSizeX:(float)sizeX sizeY:(float)sizeY
{
    [super setSizeX:sizeX sizeY:sizeY];
    
    [box setSizeX:sizeX sizeY:sizeY];
}

@end
