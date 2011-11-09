//
//  PSFAppDelegate.h
//  PSF Player
//
//  Created by David Green on 10/22/11.
//  Copyright (c) 2011 Digital Worlds Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSFFile.h"
#import "PSFCpu.h"

@class PSFViewController;

@interface PSFAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) PSFViewController *viewController;
@property (strong, nonatomic) PSFFile *currentFile;
@property (strong, nonatomic) PSFCpu *cpu;

@end
