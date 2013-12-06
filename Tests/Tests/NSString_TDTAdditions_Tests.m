#import <XCTest/XCTest.h>
#import <TDTHotChocolate/FoundationAdditions/NSString+TDTAdditions.h>

@interface NSString_TDTAdditions_Tests : XCTestCase

@end

@implementation NSString_TDTAdditions_Tests

- (void)testRandomUUIDIsNotEmpty {
  NSString *uuid = [NSString randomUUID];
  XCTAssertTrue(uuid.length > 0);
}

- (void)testNewUUIDIsGeneratedForEachCall {
  XCTAssertNotEqualObjects([NSString randomUUID], [NSString randomUUID]);
}

- (void)testSha1SumIsCorrectlyCalculated {
  NSString *testString = @"interesting";
  // $ shasum <(echo -n "interesting")
  NSString *sha1Digest = @"68f55551796668375c528bd96b0d0fbc847bd123";
  XCTAssertEqualObjects([testString sha1Digest], sha1Digest);
}

- (void)testStringByTrimmingNonAlphaNumericCharacters {
  XCTAssertEqualObjects(@"HOME",
                        [@"#@HOME#@" stringByTrimmingNonAlphaNumericCharacters]);
  XCTAssertEqualObjects(@"iPhone",
                        [@"--iPhone--" stringByTrimmingNonAlphaNumericCharacters]);
  XCTAssertEqualObjects(@"WORK",
                        [@"+__WORK!!__" stringByTrimmingNonAlphaNumericCharacters]);
}

- (void)testBlanksShouldBeNilled {
  XCTAssertNil([@"" stringByNillingBlanks]);
}

- (void)testNonBlanksShouldBePassedUnchanged {
  NSString *nonBlankString = @"Foo";
  XCTAssertEqualObjects([nonBlankString stringByNillingBlanks], nonBlankString);
}

- (void)testStringFromUIntegerConstruction {
  XCTAssertEqualObjects([NSString stringWithUnsignedInteger:0], @"0");
  XCTAssertEqualObjects([NSString stringWithUnsignedInteger:42], @"42");
  XCTAssertEqualObjects([NSString stringWithUnsignedInteger:100000], @"100000",
                        @"UInt -> String is using localized formatting?");
}

@end