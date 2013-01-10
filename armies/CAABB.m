//
//  CAABB.m
//  armies
//
//  Created by Дмитрий Заборовский on 1/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CAABB.h"

@implementation CAABB

@synthesize position, sizes;


-(void)setSizeX:(float)sizex sizeY:(float)sizey
{
    sizes = GLKVector2Make(sizex, sizey);
    return;
}

-(void)setPosX:(float)posx posY:(float)posy
{
    position = GLKVector2Make(posx, posy);
    return;
}

-(GLKVector2)test:(CAABB *)obj
{
    return [CAABB test:self with:obj];
}


+(GLKVector2)test:(CAABB *)obj with:(CAABB *)obj2
{
    float xl1,xu1,yl1,yu1;
    float xl2,xu2,yl2,yu2;
    float dx=0, dy=0;
    
    xl1 = obj->position.x - obj->sizes.x/2;
    xu1 = obj->position.x + obj->sizes.x/2;
    yl1 = obj->position.y - obj->sizes.y/2;
    yu1 = obj->position.y + obj->sizes.y/2;
    
    xl2 = obj2->position.x - obj2->sizes.x/2;
    xu2 = obj2->position.x + obj2->sizes.x/2;
    yl2 = obj2->position.y - obj2->sizes.y/2;
    yu2 = obj2->position.y + obj2->sizes.y/2;
    
    
    //x-axis collision
    if (xl1 > xl2 && xl1 < xu2)
    {
        if(xu1 > xl2 && xu1 <= xu2)
        {
            dx = xu2 - xl1;
            if(fabs(dx) > fabs(xl2-xu1)) dx = xl2-xu1;
        }
        else
        {
            dx = xu2 - xl1;
        }
    }
    else if( xu1 > xl2 && xu1 < xu2)
    {
        dx = xl2 - xu1;
    }
    else if( xu1 > xu2 && xl1 < xl2 )
    {
        dx = xu2 - xl1;
        if(fabs(dx) > fabs(xl2-xu1)) dx = xl2-xu1;
    }
    
    //y-axis collision
    if (yl1 > yl2 && yl1 < yu2)
    {
        if(yu1 > yl2 && yu1 <= yu2)
        {
            dy = yu2 - yl1;
            if(fabs(dy) > fabs(yl2-yu1)) dy = yl2-yu1;
        }
        else
        {
            dy = yu2 - yl1;
        }
    }
    else if( yu1 > yl2 && yu1 < yu2)
    {
        dy = yl2 - yu1;
    }
    else if( yu1 > yu2 && yl1 < yl2 )
    {
        dy = yu2 - yl1;
        if(fabs(dy) > fabs(yl2-yu1)) dy = yl2-yu1;
    }
    
    
    if(dx == 0 || dy == 0) return GLKVector2Make(0, 0);
    if(fabs(dx) < fabs(dy) - 0.02f) dy=0;
    else if(fabs(dy) < fabs(dx) - 0.02f) dx = 0;
    
    return GLKVector2Make(dx, dy);
}


@end
