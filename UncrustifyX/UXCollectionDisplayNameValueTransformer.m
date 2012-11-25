//
//  UXCollectionDisplayNameValueTransformer.m
//  UncrustifyX
//
//  Created by Ryan Maxwell on 14/10/12.
//  Copyright (c) 2012 Ryan Maxwell. All rights reserved.
//

#import "UXCollectionDisplayNameValueTransformer.h"

@implementation UXCollectionDisplayNameValueTransformer

+ (Class)transformedValueClass {
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (id)transformedValue:(id)value {
    if ([value isKindOfClass:NSSet.class]) {
        NSMutableArray *objectNames = NSMutableArray.array;
        
        for (id object in value) {
            [objectNames addObject:[object displayName]];
        }
        
        return [objectNames componentsJoinedByString:@", "];
    }
    return nil;
}

@end
