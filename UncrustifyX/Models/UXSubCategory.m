//
//  UXSubcategory.m
//  UncrustifyX
//
//  Created by Ryan Maxwell on 10/11/12.
//  Copyright (c) 2012 Ryan Maxwell. All rights reserved.
//

#import "UXSubcategory.h"

@implementation UXSubcategory

- (NSString *)displayName {
    return self.name;
}

+ (UXSubcategory *)otherSubcategory {
    static UXSubcategory *other;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        other = [UXSubcategory MR_findFirstByAttribute:UXAbstractCategoryAttributes.name
                                             withValue:@"Other"];
        
        if (!other) {
            other = [UXSubcategory MR_createEntity];
            other.name = @"Other";
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        }
    });
    return other;
}

@end
