//
//  XXPROJECT_TITLEXX
//
//  Copyright (c) XXYEARXX XXORGANIZATION_NAMEXX. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "XXCLASS_PREFIXXXRootViewController.h"

@interface XXPROJECT_TITLEXXTests : SenTestCase
@end

@implementation XXPROJECT_TITLEXXTests

- (void)testExample
{
    NSString *runtimeIdentifier = [[NSBundle bundleForClass:[XXCLASS_PREFIXXXRootViewController class]] bundleIdentifier];
    NSString *klippInsertedIdentifier = @"XXBUNDLE_IDXX.develop";
    STAssertTrue([runtimeIdentifier isEqualToString:klippInsertedIdentifier], @"Even test code is processed by Klipp");
}

@end
