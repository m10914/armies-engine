//
//  AppDelegate.h
//  armies
//
//  Created by Дмитрий Заборовский on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "CScene.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate,
GLKViewDelegate, GLKViewControllerDelegate, UIAccelerometerDelegate>
{
    CScene* scene;
}
@property (strong, nonatomic) UIWindow *window;

@end
