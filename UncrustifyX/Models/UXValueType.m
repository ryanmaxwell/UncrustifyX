//
//  UXValueType.m
//  UncrustifyX
//
//  Created by Ryan Maxwell on 11/10/12.
//  Copyright (c) 2012 Ryan Maxwell. All rights reserved.
//

#import "UXValueType.h"
#import "UXValue.h"

static NSString * const BooleanYesString    = @"true";
static NSString * const BooleanNoString     = @"false";

@implementation UXValueType

static NSNumberFormatter *nf;

+ (BOOL)isValidNumber:(NSString *)value {
    if (!nf) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            nf = [[NSNumberFormatter alloc] init];
        });
    }
    return ([nf numberFromString:value] != nil);
}

+ (BOOL)_isTruthy:(NSString *)value {
    return (value != nil
            && (([value caseInsensitiveCompare:@"true"] == NSOrderedSame)
            || ([value caseInsensitiveCompare:@"t"] == NSOrderedSame)
            || ([value caseInsensitiveCompare:@"yes"] == NSOrderedSame)
            || ([value caseInsensitiveCompare:@"y"] == NSOrderedSame)
            || [value isEqualToString:@"1"]));
}

+ (BOOL)_isFalsy:(NSString *)value {
    return (value != nil
            && (([value caseInsensitiveCompare:@"false"] == NSOrderedSame)
            || ([value caseInsensitiveCompare:@"f"] == NSOrderedSame)
            || ([value caseInsensitiveCompare:@"no"] == NSOrderedSame)
            || ([value caseInsensitiveCompare:@"n"] == NSOrderedSame)
            || [value isEqualToString:@"0"]));
}

+ (BOOL)isValidBoolean:(NSString *)value {
    return ([self _isTruthy:value] || [self _isFalsy:value]);
}

+ (NSString *)booleanStringForBooleanValue:(NSString *)value {
    if ([self _isTruthy:value]) {
        return BooleanYesString;
    } else if ([self _isFalsy:value]) {
        return BooleanNoString;
    } else {
        return nil;
    }
}

- (BOOL)isValidValue:(NSString *)value {
    if (value == nil) return YES;
    
    /* validate if it's in the values first */
    if (self.values.count > 0) {
        for (UXValue *v in self.values) {
            if ([value caseInsensitiveCompare:v.value] == NSOrderedSame) {
                return YES;
            }
        }
    }
    
    if (([self.type.lowercaseString caseInsensitiveCompare:@"Number"] == NSOrderedSame) && [self.class isValidNumber:value]) {
        return YES;
    }
    
    if (([self.type.lowercaseString caseInsensitiveCompare:@"Boolean"] == NSOrderedSame) && [self.class isValidBoolean:value]) {
        return YES;
    }
    
    /* freeform string - least restrictive */
    if ([self.type.lowercaseString caseInsensitiveCompare:@"String"] == NSOrderedSame) {
        return YES;
    }
    
    return NO;
}



@end
