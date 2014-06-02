#import <XCTest/XCTest.h>
#import <TDTChocolate/TDTFoundationAdditions.h>

@interface NSCalendar_TDTComponents_Tests : XCTestCase

@end

@implementation NSCalendar_TDTComponents_Tests

- (void)testHoursSinceNow {
  NSCalendar *calendar = [NSCalendar currentCalendar];
  NSDate *now = [NSDate date];
  XCTAssertEqual([calendar tdt_hoursSinceDate:now], (NSInteger)0);
}

- (void)testHoursSincePast {
  NSCalendar *calendar = [NSCalendar currentCalendar];
  NSDate *now = [NSDate date];
  NSDate *twoHoursEarlier = [now dateByAddingTimeInterval:-60*60*2];
  XCTAssertEqual([calendar tdt_hoursSinceDate:twoHoursEarlier], (NSInteger)2);
}

- (void)testHoursDoNotWrapWhenGreaterThan24 {
  NSCalendar *calendar = [NSCalendar currentCalendar];
  NSDate *now = [NSDate date];
  NSInteger hours = 360;
  NSDate *greaterThan24HoursEarlier = [now dateByAddingTimeInterval:-60*60*hours];
  XCTAssertEqual([calendar tdt_hoursSinceDate:greaterThan24HoursEarlier], hours);
}

- (void)testDaysSinceNow {
  NSCalendar *calendar = [NSCalendar currentCalendar];
  NSDate *now = [NSDate date];
  XCTAssertEqual([calendar tdt_daysSinceDate:now], (NSInteger)0);
}

- (void)testDaysSince5MinutesPast {
  NSCalendar *calendar = [NSCalendar currentCalendar];
  NSDate *now = [NSDate date];
  NSDate *date5MinutesPast = [now dateByAddingTimeInterval:-60*5];
  XCTAssertEqual([calendar tdt_daysSinceDate:date5MinutesPast], (NSInteger)0);
}

- (void)testDaysSincePast {
  NSCalendar *calendar = [NSCalendar currentCalendar];
  NSDate *now = [NSDate date];
  NSDate *twoDaysEarlier = [now dateByAddingTimeInterval:-60*60*2*24];
  XCTAssertEqual([calendar tdt_daysSinceDate:twoDaysEarlier], (NSInteger)2);
}

- (void)testDaysDoNotWrapWhenGreaterThan30 {
  NSCalendar *calendar = [NSCalendar currentCalendar];
  NSDate *now = [NSDate date];
  NSInteger days = 35;
  NSDate *greaterThan30DaysEarlier = [now dateByAddingTimeInterval:-60*60*24*days];
  XCTAssertEqual([calendar tdt_daysSinceDate:greaterThan30DaysEarlier], days);
}

- (void)testDaysFromFuture {
  NSCalendar *calendar = [NSCalendar currentCalendar];
  NSDate *now = [NSDate date];
  NSInteger days = 2;
  NSDate *twoDaysFutureDate = [now dateByAddingTimeInterval:60*60*24*days];
  XCTAssertEqual([calendar tdt_daysSinceDate:twoDaysFutureDate], -(days - 1));
}

@end
