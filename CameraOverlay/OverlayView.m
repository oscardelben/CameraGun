//
//  OverlayView.m
//  CameraOverlay
//
//  Created by Oscar Del Ben on 10/5/11.
//  Copyright (c) 2011 Fructivity. All rights reserved.
//

#import "OverlayView.h"

#define BOTTOM_BAR_HEIGHT 60

#define VIEW_FINDER_RADIUS 60

#define CGRectMidPoint(rect) CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect))

@implementation OverlayView

- (AVAudioPlayer *)soundNamed:(NSString *)name {
    NSString * path;
    AVAudioPlayer *sound;
    NSError * err;
    
    path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:name];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSURL *url = [NSURL fileURLWithPath:path];
        sound = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&err];
        if (!sound) {
            NSLog(@"Sound named '%@' had error %@", name, [err localizedDescription]);
        } else {
            [sound prepareToPlay];
        }
    } else {
        NSLog(@"Sound file '%@' doesn't exist at '%@'", name, path);
    }
    
    return sound;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        player = [self soundNamed:@"gun.caf"];
    }
    return self;
}

- (void)drawViewFinder
{
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    
    CGPoint center = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - BOTTOM_BAR_HEIGHT);
    
    // Draw the circle
    [bezierPath addArcWithCenter:center radius:VIEW_FINDER_RADIUS startAngle:0 endAngle:360 clockwise:YES];
    
    // Draw the lines
    [bezierPath moveToPoint:CGPointMake(center.x - VIEW_FINDER_RADIUS + 20, center.y)];
    [bezierPath addLineToPoint:CGPointMake(center.x + VIEW_FINDER_RADIUS - 20, center.y)];
    
    [bezierPath moveToPoint:CGPointMake(center.x, center.y - VIEW_FINDER_RADIUS + 20)];
    [bezierPath addLineToPoint:CGPointMake(center.x, center.y + VIEW_FINDER_RADIUS - 20)];
    
    // Stroke path
    [bezierPath setLineWidth:2];
    [[UIColor blackColor] setStroke];
    [bezierPath stroke];

}

- (void)drawBottomBar
{
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGRect bottomBar = CGRectMake(0, self.frame.size.height - BOTTOM_BAR_HEIGHT, self.frame.size.width, BOTTOM_BAR_HEIGHT);
    [[UIColor blackColor] setFill];
    
    CGContextFillRect(context, bottomBar);
    
    // Add a fire button
    UIButton *fireButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [fireButton setTitle:@"Fire!" forState:UIControlStateNormal];
    [fireButton addTarget:self action:@selector(fire) forControlEvents:UIControlEventTouchUpInside];
    
    float buttonWidth = 150;
    float buttonHeight = 40;
    
    fireButton.frame = CGRectMake(self.frame.size.width / 2 - buttonWidth / 2, self.frame.size.height - BOTTOM_BAR_HEIGHT + 10, buttonWidth, buttonHeight);
    
    [self addSubview:fireButton];
}

- (void)drawGun
{
    UIImage *gun = [UIImage imageNamed:@"gun.png"];
    [gun drawAtPoint:CGPointMake(0, self.frame.size.height - 130)];
}

- (void)drawRect:(CGRect)rect
{
    [self drawBottomBar];
    [self drawViewFinder];
    [self drawGun];
}

#pragma mark Fire utility methods

- (void)showSplashAnimationAtPoint:(CGPoint)aPoint
{
    UIImage *splashImage = [UIImage imageNamed:@"splash.png"];
    UIImageView *splash = [[UIImageView alloc] initWithFrame:CGRectMake(aPoint.x, aPoint.y, splashImage.size.width, splashImage.size.height)];
    splash.image = splashImage;
    
    [self addSubview:splash];
    
    [UIView animateWithDuration:1 animations:^{
        [splash setAlpha:0];
    } completion:^(BOOL finished) {
        [splash removeFromSuperview];
    }];
}

- (void)fire
{
    [player play];
    
    UIImage *bulletImage = [UIImage imageNamed:@"bullet.png"];

    UIImageView *bullet = [[UIImageView alloc] initWithFrame:CGRectMake(60, self.frame.size.height - 140, bulletImage.size.width, bulletImage.size.height)];
    bullet.image = bulletImage;
    
    [self addSubview:bullet];
    
    // animate the bullet
    [UIView animateWithDuration:0.5 animations:^{
        // generate a random point near the center

        float x = (arc4random() % VIEW_FINDER_RADIUS) + CGRectGetMidX(self.frame) - (VIEW_FINDER_RADIUS / 2);
        float y = (arc4random() % VIEW_FINDER_RADIUS) + CGRectGetMidY(self.frame) - BOTTOM_BAR_HEIGHT - (VIEW_FINDER_RADIUS / 2);
        
        bullet.frame = CGRectMake(x, y, bulletImage.size.width / 2, bulletImage.size.height / 2);
    } completion:^(BOOL finished) {
        // Show a red splash
        [self showSplashAnimationAtPoint:CGPointMake(bullet.frame.origin.x, bullet.frame.origin.y)];
        [bullet removeFromSuperview]; 
    }];
}

@end
