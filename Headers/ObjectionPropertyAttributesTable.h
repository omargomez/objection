#import <Foundation/Foundation.h>
#import "ObjectionFunctions.h"

@interface ObjectionPropertyAttributesTable : NSObject 
+ (ObjectionPropertyInfo)lookupProperty:(NSString *)propertyName forClass:(Class)aClass;
@end
