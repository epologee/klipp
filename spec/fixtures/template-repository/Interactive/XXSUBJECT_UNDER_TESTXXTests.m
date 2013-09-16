#import <SenTestingKit/SenTestingKit.h>

#define HC_SHORTHAND

@interface XXSUBJECT_UNDER_TESTXXTests : SenTestCase
@end

@implementation XXSUBJECT_UNDER_TESTXXTests

- (void)test_...
{
    assertThat(@YES, is(@NO));
}

@end