#import <Foundation/Foundation.h>
#import "TDTFunctionalAdditionsBlockTypedefs.h"

@interface NSDictionary (TDTFunctionalAdditions)

/**
 @return Dictionary obtained by transforming each @p (key, value) pair in
 the receiver with @p (key, block(value)).
 */
- (NSDictionary *)tdt_dictionaryByMappingValuesWithBlock:(TDTMapBlock)block;

@end
