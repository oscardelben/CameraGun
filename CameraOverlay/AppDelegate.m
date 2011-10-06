//
//  AppDelegate.m
//  CameraOverlay
//
//  Created by Oscar Del Ben on 10/5/11.
//  Copyright (c) 2011 Fructivity. All rights reserved.
//

#import "AppDelegate.h"

#import "OverlayView.h"

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    // and now for the custom view!
    OverlayView *overlayView =  [[OverlayView alloc] initWithFrame:imagePickerController.view.frame];
    overlayView.backgroundColor = [UIColor clearColor];
    
    imagePickerController.cameraOverlayView = overlayView;
    imagePickerController.showsCameraControls = NO;
    
    
    self.window.rootViewController = imagePickerController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
