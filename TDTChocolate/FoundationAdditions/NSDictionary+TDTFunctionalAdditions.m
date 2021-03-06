#import "NSDictionary+TDTFunctionalAdditions.h"

@implementation NSDictionary (TDTFunctionalAdditions)

- (NSDictionary *)tdt_dictionaryByMappingValuesWithBlock:(TDTMapBlock)block {
  NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:self.count];
  [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
    result[key] = block(obj);
  }];
  return result;
}

- (NSArray *)tdt_arrayByMappingEntriesWithBlock:(TDTMapEntryBlock)block {
  NSMutableArray *result = [NSMutableArray arrayWithCapacity:self.count];
  [self enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
    [result addObject:block(key, value)];
  }];
  return result;
}

- (NSDictionary *)tdt_dictionaryByFilteringUsingPredicate:(BOOL (^)(id, id))predicate {
  NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:self.count];
  [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
    if (predicate(key, obj)) {
      result[key] = obj;
    }
  }];
  return result;
}

@end
