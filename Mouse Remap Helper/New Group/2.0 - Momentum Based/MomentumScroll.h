//
//  AppDelegate.h
//  ScrollFix Playground in OBJC weil Swift STINKT
//
//  Created by Noah Nübling on 06.11.18.
//  Copyright © 2018 Noah Nuebling Enterprises Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MomentumScroll : NSObject

+ (void)setHorizontalScroll: (BOOL)B;

+ (void)configureWithPxPerStep:(int)px
                 msPerStep:(int)ms
                  friction:(float)f;
+ (void)start;
+ (void)stop;

+ (BOOL)isEnabled;
+ (void)setIsEnabled:(BOOL)B;

+ (BOOL)isRunning;

@end
