#import <XCTest/XCTest.h>
#import <TDTHotChocolate/FoundationAdditions/NSSet+TDTFunctionalAdditions.h>

@interface NSSet_FunctionalUtils_Tests : XCTestCase

@end

@implementation NSSet_FunctionalUtils_Tests

- (void)testNothingSatisfiesPredicateInEmptySet {
  NSSet *emptySet = [NSSet set];
  TDTPredicateBlock tautology = ^(id obj) { return YES; };
  XCTAssertFalse([emptySet anyWithBlock:tautology]);
}

- (void)testItReturnsTrueIfAnyElementSatisfiesPredicate {
  NSSet *set = [NSSet setWithArray:@[@34, @3, @4]];
  TDTPredicateBlock predicateMatchingOneElement = ^BOOL (id obj) {
    return ([obj integerValue] == 3);
  };
  TDTPredicateBlock predicateMatchingMultipleElements = ^BOOL (id obj) {
    return ([obj integerValue] > 3);
  };
  TDTPredicateBlock predicateMatchingAllElements = ^BOOL (id obj) {
    return ([obj integerValue] >= 3);
  };
  XCTAssertTrue([set anyWithBlock:predicateMatchingOneElement]);
  XCTAssertTrue([set anyWithBlock:predicateMatchingMultipleElements]);
  XCTAssertTrue([set anyWithBlock:predicateMatchingAllElements]);
}

- (void)testItReturnsFalseIfNoElementSatisfiesPredicate {
  NSSet *set = [NSSet setWithArray:@[@34, @3, @4]];
  TDTPredicateBlock predicateMatchingNoElement = ^BOOL (id obj) {
    return ([obj integerValue] == 44);
  };
  XCTAssertFalse([set anyWithBlock:predicateMatchingNoElement]);
}

@end