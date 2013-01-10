//
//  CAABB.h
//  armies
//
//  Created by Дмитрий Заборовский on 1/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface CAABB : NSObject
{
    GLKVector2 position;
    GLKVector2 sizes;
}
@property (readonly) GLKVector2 position;
@property (readonly) GLKVector2 sizes;

-(void)setSizeX:(float)sizex sizeY:(float)sizey;
-(void)setPosX:(float)posx posY:(float)posy;

-(GLKVector2)test:(CAABB*)obj;

+(GLKVector2)test:(CAABB*)obj with:(CAABB*)obj2;

@end
