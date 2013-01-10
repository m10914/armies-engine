//
//  CCamera.m
//  armies
//
//  Created by Дмитрий Заборовский on 3/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCamera.h"

@implementation CCamera

@synthesize align, x, y, scale, speed, realX, realY;

-(id)init
{
    speed = GLKVector2Make(0,0);
    
    x=0;
    y=0;
    realX=0;
    realY=0;
    
    return [super init];
}

-(void)update
{
    realX = x/scale - 240.f;
    realY = y/scale - 160.f;
}

@end
