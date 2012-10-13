//
//  OCONFactory.m
//  OCONFactory
//
//  Created by David on 10/4/12.
//  Copyright (c) 2012 Numenor Labs, Incorporated. All rights reserved.
//

#import "OCONFactory.h"
#import <objc/runtime.h>


@interface NSObject (OCON)

- (Class)classForArrayProperty:(NSString *)propertyName;

@end


@implementation NSObject (OCON)

- (Class)classForArrayProperty:(NSString *)propertyName {
    return nil;
}

@end


@interface OCONFactory ()

- (id)transform:(id)rawValue withClass:(Class)class;
- (BOOL)property:(NSString *)key ofObject:(id)object isClass:(Class)class;

@end


@implementation OCONFactory

- (void)applyProperties:(NSDictionary *)values toObject:(id)object {
    [values enumerateKeysAndObjectsUsingBlock:^(id propertyName, id rawValue, BOOL *stop) {
        id value = rawValue;
        if ([rawValue isKindOfClass:[NSArray class]]) {
            value = [NSMutableArray array];
            for (id rawElement in rawValue) {
                Class elementClass = [object classForArrayProperty:propertyName];
                [value addObject: [self transform:rawElement withClass:elementClass]];
            }
        }
        else {
            if ([self property:propertyName ofObject:object isClass:[NSURL class]]) {
                value = [self transform:rawValue withClass:[NSURL class]];
            }
        }
        [object setValue:value forKey:propertyName];
    }];
}

- (id)transform:(id)rawValue withClass:(Class)class {
    if ([rawValue isKindOfClass:class]) { return rawValue; }

    if (class == [NSURL class]) {
        return [NSURL URLWithString:rawValue];
    }

    // Get instance from object

    return rawValue;
}

- (BOOL)property:(NSString *)key ofObject:(id)object isClass:(Class)class {
    objc_property_t propertyInfo = class_getProperty([object class], [key UTF8String]);
    const char *propertyAttrs = property_getAttributes(propertyInfo);

    return ([[NSString stringWithCString:propertyAttrs encoding:NSUTF8StringEncoding]
        rangeOfString:NSStringFromClass(class)]).location != NSNotFound;
}

@end
