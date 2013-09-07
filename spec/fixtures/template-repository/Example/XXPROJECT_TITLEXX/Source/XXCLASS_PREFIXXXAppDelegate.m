//
//  XXPROJECT_TITLEXX
//
//  Copyright (c) XXYEARXX XXORGANIZATION_NAMEXX. All rights reserved.
//

#import "XXCLASS_PREFIXXXAppDelegate.h"
#import "XXCLASS_PREFIXXXRootViewController.h"

@interface  XXCLASS_PREFIXXXAppDelegate ()

@property (nonatomic, strong) XXCLASS_PREFIXXXRootViewController *rootViewController;

@end

@implementation XXCLASS_PREFIXXXAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    self.rootViewController = [[XXCLASS_PREFIXXXRootViewController alloc] init];
    self.window.rootViewController = self.rootViewController;
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
