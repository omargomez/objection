#import "ObjectionPropertyAttributesTable.h"
#import <objc/runtime.h>

static NSMutableDictionary *gPropertyAttributesCache = NULL;
static NSString *const kPropertyInfoDelimeter = @",";
static NSString *const kPropertyInfoKeyFormat = @"%@_%@";

static ObjectionPropertyInfo ObjectionPropertyInfoFromString(NSString *string) {
  NSRange range = [string rangeOfString:kPropertyInfoDelimeter];
  NSCAssert(range.location != NSNotFound, @"Invalid Property Info String: '%@'", string);
  NSInteger type = [[string substringFromIndex:range.location + 1] intValue];
  NSString *objectDescription = [string substringWithRange:NSMakeRange(0, range.location)];
  id classOrProtocol = type == ObjectionTypeClass ? (id)NSClassFromString(objectDescription) : (id)NSProtocolFromString(objectDescription);
  NSCAssert(classOrProtocol != nil, @"Could not find class '%@'", classOrProtocol);    
  return (ObjectionPropertyInfo){
    classOrProtocol,
    type
  };
}

static NSString* ObjectionStringFromPropertyInfo(ObjectionPropertyInfo info) {
  NSString *objectDescription = info.type == ObjectionTypeClass ? NSStringFromClass(info.object) : NSStringFromProtocol(info.object);
  return [NSString stringWithFormat:@"%@,%d", objectDescription, info.type];
}

@implementation ObjectionPropertyAttributesTable

+ (void)initialize {
  if (self = [ObjectionPropertyAttributesTable class]) {
    gPropertyAttributesCache = [[NSMutableDictionary alloc] init];
  }
}

+ (ObjectionPropertyInfo)lookupProperty:(NSString *)propertyName forClass:(Class)aClass {
  NSString *propertyKey = [NSString stringWithFormat:kPropertyInfoKeyFormat, propertyName, aClass];
  NSString *propertyInfoString = [gPropertyAttributesCache objectForKey:propertyKey];
  if (propertyInfoString) {
    return ObjectionPropertyInfoFromString(propertyInfoString);
  } 
  objc_property_t property = ObjectionGetProperty(aClass, propertyName);
  ObjectionPropertyInfo info = ObjectionFindClassOrProtocolForProperty(property);
  [gPropertyAttributesCache setObject:ObjectionStringFromPropertyInfo(info) forKey:propertyKey];
  return info;  
}
@end
