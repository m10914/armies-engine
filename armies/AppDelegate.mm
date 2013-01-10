//
//  AppDelegate.m
//  armies
//
//  Created by Дмитрий Заборовский on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "CScene.h"


@implementation AppDelegate

@synthesize window = _window;



//-------------------------
// A C C E L

-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
    UIAccelerationValue x,y,z;
    x = acceleration.x;
    y = acceleration.y;
    z = acceleration.z;
    
    float angle = atan2(y, x);
    
    //angle = (angle+1.5f)*20.f;
    
    [scene tilt:angle];
}


//-------------------------
// T O U C H


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.window.rootViewController.view];
    
    [scene fingerDown:GLKVector2Make(location.x, location.y)];
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.window.rootViewController.view];
    
    [scene fingerUp:GLKVector2Make(location.x, location.y)];
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.window.rootViewController.view];
    CGPoint prevlocation = [touch previousLocationInView:self.window.rootViewController.view];
    
    [scene fingerMove:GLKVector2Make(prevlocation.x, prevlocation.y) to:GLKVector2Make(location.x, location.y)];
}



//----------------------

-(void)glkViewControllerUpdate:(GLKViewController *)controller
{
    [scene update:controller.timeSinceLastUpdate];
}

-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{

    [scene render];
}

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    EAGLContext* context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:context];
    
    GLKView *view = [[GLKView alloc] initWithFrame:[[UIScreen mainScreen] bounds] context:context];
    view.delegate = self;
    
    GLKViewController *controller = [[GLKViewController alloc] initWithNibName:nil bundle:nil];
    controller.delegate = self;
    controller.view = view;
    
    
    [[UIAccelerometer sharedAccelerometer] setUpdateInterval: 1.f/30.f];
    [[UIAccelerometer sharedAccelerometer] setDelegate:self];
    
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = controller;
    [self.window makeKeyAndVisible];
    
    
    scene = [[CScene alloc] init];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
