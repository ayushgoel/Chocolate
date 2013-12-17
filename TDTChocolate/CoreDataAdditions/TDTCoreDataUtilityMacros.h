
/**
 Macros to ease creation of core data accessors for scalar values. 
 @see "Core Data Programming Guide" > "Non-Standard Persistent Attributes"
 */

#define TDT_COREDATA_CREATE_INT_GETTER(key, type, getter, primitiveAccessor) \
  - (type)getter { \
    [self willAccessValueForKey:key]; \
    NSNumber *tmp = self.primitiveAccessor; \
    [self didAccessValueForKey:key]; \
    return (type)[tmp integerValue]; \
  }

#define TDT_COREDATA_CREATE_INT_SETTER(key, type, setter, primitiveAccessor) \
  - (void)setter : (type)x { \
    NSNumber *tmp = [[NSNumber alloc] initWithInt:x]; \
    [self willChangeValueForKey:key]; \
    self.primitiveAccessor = tmp; \
    [self didChangeValueForKey:key]; \
  }

#define TDT_COREDATA_CREATE_INT_ACCESSOR(key, type, getter, setter, primitiveAccessor) \
  TDT_COREDATA_CREATE_INT_GETTER(key, type, getter, primitiveAccessor) \
  TDT_COREDATA_CREATE_INT_SETTER(key, type, setter, primitiveAccessor)


#define TDT_COREDATA_CREATE_BOOL_GETTER(key, type, getter, primitiveAccessor) \
  - (type)getter { \
    [self willAccessValueForKey:key]; \
    NSNumber *tmp = self.primitiveAccessor; \
    [self didAccessValueForKey:key]; \
    return [tmp boolValue]; \
  }

#define TDT_COREDATA_CREATE_BOOL_SETTER(key, type, setter, primitiveAccessor) \
  - (void)setter : (type)x { \
    NSNumber *tmp = [[NSNumber alloc] initWithBool:x]; \
    [self willChangeValueForKey:key]; \
    self.primitiveAccessor = tmp; \
    [self didChangeValueForKey:key]; \
  }

#define TDT_COREDATA_CREATE_BOOL_ACCESSOR(key, type, getter, setter, primitiveAccessor) \
  TDT_COREDATA_CREATE_BOOL_GETTER(key, type, getter, primitiveAccessor) \
  TDT_COREDATA_CREATE_BOOL_SETTER(key, type, setter, primitiveAccessor)

#define TDT_COREDATA_CREATE_FLOAT_GETTER(key, type, getter, primitiveAccessor) \
  - (type)getter { \
    [self willAccessValueForKey:key]; \
    NSNumber *tmp = self.primitiveAccessor; \
    [self didAccessValueForKey:key]; \
    return (type)[tmp floatValue]; \
  }

#define TDT_COREDATA_CREATE_FLOAT_SETTER(key, type, setter, primitiveAccessor) \
  - (void)setter : (type)x { \
    NSNumber *tmp = [[NSNumber alloc] initWithFloat:x]; \
    [self willChangeValueForKey:key]; \
    self.primitiveAccessor = tmp; \
    [self didChangeValueForKey:key]; \
  }

#define TDT_COREDATA_CREATE_FLOAT_ACCESSOR(key, type, getter, setter, primitiveAccessor) \
  TDT_COREDATA_CREATE_FLOAT_GETTER(key, type, getter, primitiveAccessor) \
  TDT_COREDATA_CREATE_FLOAT_SETTER(key, type, setter, primitiveAccessor)

/**
 Invoking the super (NSManagedObject) setter functionality in an overridden
 setter of a custom NSManagedObject subclass results in an infinite loop.
 So we have to perform the same actions (what the default implementation would
 have done) inline. These macro takes away some of the pain.
 */

#define TDT_COREDATA_INVOKE_SUPER_GETTER(KEY, VARIABLE, PRIMITIVE_PROPERTY) \
  [self willAccessValueForKey:KEY]; \
  VARIABLE = self.PRIMITIVE_PROPERTY; \
  [self didAccessValueForKey:KEY]

#define TDT_COREDATA_INVOKE_SUPER_SETTER(KEY, VALUE, PRIMITIVE_PROPERTY) \
  [self willChangeValueForKey:KEY]; \
  self.PRIMITIVE_PROPERTY = VALUE; \
  [self didChangeValueForKey:KEY]