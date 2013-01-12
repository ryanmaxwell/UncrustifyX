//
//  UXCategory.m
//  UncrustifyX
//
//  Created by Ryan Maxwell on 11/10/12.
//  Copyright (c) 2012 Ryan Maxwell. All rights reserved.
//

#import "UXCategory.h"

@implementation UXCategory

- (NSString *)displayName {
    return self.name;
}

+ (UXCategory *)otherCategory {
    static UXCategory *other;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        other = [UXCategory findFirstByAttribute:UXAbstractCategoryAttributes.name
                                          withValue:@"Other"];
        
        if (!other) {
            other = [UXCategory createEntity];
            other.name = @"Other";
            [NSManagedObjectContext.defaultContext saveToPersistentStoreWithCompletion:nil];
        }
    });
    return other;
}

@end
