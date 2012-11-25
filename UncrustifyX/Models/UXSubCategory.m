//
//  UXSubCategory.m
//  UncrustifyX
//
//  Created by Ryan Maxwell on 10/11/12.
//  Copyright (c) 2012 Ryan Maxwell. All rights reserved.
//

#import "UXSubCategory.h"

@implementation UXSubCategory

- (NSString *)displayName {
    return self.name;
}

+ (UXSubCategory *)otherSubCategory {
    static UXSubCategory *other;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        other = [UXSubCategory findFirstByAttribute:UXAbstractCategoryAttributes.name
                                                withValue:@"Other"];
        
        if (!other) {
            other = [UXSubCategory createEntity];
            other.name = @"Other";
            [NSManagedObjectContext.defaultContext save];
        }
    });
    return other;
}

@end
