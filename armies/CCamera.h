//
//  CCamera.h
//  armies
//
//  Created by Дмитрий Заборовский on 3/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface CCamera : NSObject

@property (nonatomic) int align;
@property (nonatomic) float scale;
@property (nonatomic) float x;
@property (nonatomic) float y;
@property (nonatomic) GLKVector2 speed;
@property (nonatomic) float realX;
@property (nonatomic) float realY;

-(void)update;

@end
