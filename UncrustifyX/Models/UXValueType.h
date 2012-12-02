//
//  UXValueType.h
//  UncrustifyX
//
//  Created by Ryan Maxwell on 11/10/12.
//  Copyright (c) 2012 Ryan Maxwell. All rights reserved.
//

#import "_UXValueType.h"

@interface UXValueType : _UXValueType

/* Validation Methods */
+ (BOOL)isValidNumber:(NSString *)value;
+ (BOOL)isValidBoolean:(NSString *)value;

/* Returns the boolean string constant after parsing the *valid* boolean string 
 * @warning returns nil if invalid boolean string
 */
+ (NSString *)booleanStringForBooleanValue:(NSString *)value;

/* Checks if the passed in value is a valid value for this valuetype */
- (BOOL)isValidValue:(NSString *)value;

@end
