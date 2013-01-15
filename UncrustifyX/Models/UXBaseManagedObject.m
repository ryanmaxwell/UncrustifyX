//
//  UXBaseManagedObject.m
//  UncrustifyX
//
//  Created by Ryan Maxwell on 11/10/12.
//  Copyright (c) 2012 Ryan Maxwell. All rights reserved.
//

#import "UXBaseManagedObject.h"

@implementation UXBaseManagedObject

@dynamic createdAt, updatedAt;

- (void)willSave {
    [self setPrimitiveValue:NSDate.date
                     forKey:@"updatedAt"];
    
    if (![self primitiveValueForKey:@"createdAt"]) {
        [self setPrimitiveValue:NSDate.date
                         forKey:@"createdAt"];
    }
    
    [super willSave];
}

@end
