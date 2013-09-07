//
//  XXPROJECT_TITLEXX
//
//  Copyright (c) XXYEARXX XXORGANIZATION_NAMEXX. All rights reserved.
//

#import "XXCLASS_PREFIXXXRootViewController.h"

@interface XXCLASS_PREFIXXXRootViewController ()

@property (nonatomic, strong) UILabel *label;

@end

@implementation XXCLASS_PREFIXXXRootViewController

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.label = [[UILabel alloc] initWithFrame:CGRectInset(self.view.bounds, 30, 30)];
    self.label.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.label.text = NSLocalizedString(@"CONGRATULATIONS", nil);
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.lineBreakMode = NSLineBreakByWordWrapping;
    self.label.numberOfLines = 0;
    [self.view addSubview:self.label];
}

@end
