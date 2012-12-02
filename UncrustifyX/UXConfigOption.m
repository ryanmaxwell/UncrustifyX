//
//  UXConfigOption.m
//  UncrustifyX
//
//  Created by Ryan Maxwell on 28/11/12.
//  Copyright (c) 2012 Ryan Maxwell. All rights reserved.
//

#import "UXConfigOption.h"
#import "UXCategory.h"
#import "UXPersistentConfigOption.h"

@implementation UXConfigOptionSharedImplementation

+ (NSString *)configStringForOption:(UXOption *)option value:(NSString *)value {
    if (option && value.length) {
        return [NSString stringWithFormat:@"%@ = %@", option.code, value.lowercaseString];
    }
    return nil;
}

static NSArray *sortedCategories;

+ (NSArray *)categorizedConfigOptionsFromConfigOptions:(NSArray *)configOptions searchQuery:(NSString *)searchQuery {
    
    NSMutableArray *result = NSMutableArray.array;
    NSArray *filteredConfigOptions = nil;
    
    if (searchQuery) {
        NSPredicate  *searchFilter = [NSPredicate predicateWithFormat:@"%K.%K CONTAINS[c] %@ OR %K.%K CONTAINS[c] %@ OR %K.%K CONTAINS[c] %@ OR %K.%K CONTAINS[c] %@",
                                      UXPersistentConfigOptionRelationships.option, UXOptionAttributes.optionDescription, searchQuery,
                                      UXPersistentConfigOptionRelationships.option, UXOptionAttributes.code, searchQuery,
                                      UXPersistentConfigOptionRelationships.option, UXOptionAttributes.name, searchQuery,
                                      UXPersistentConfigOptionRelationships.option, @"explodedCode", searchQuery];
        
        filteredConfigOptions = [configOptions filteredArrayUsingPredicate:searchFilter];
    } else {
        filteredConfigOptions = [NSArray arrayWithArray:configOptions];
    }
    
    NSString *sortKey = [NSString stringWithFormat:@"%@.%@",
                         UXPersistentConfigOptionRelationships.option, UXOptionAttributes.name];
    NSSortDescriptor *optionNameSort = [NSSortDescriptor sortDescriptorWithKey:sortKey
                                                                     ascending:YES];
    
    NSMutableArray *optionsInCategory = NSMutableArray.array;
    
    
    
    
    /* Categories and their config options */
    if (!sortedCategories) {
        sortedCategories = [UXCategory findAllSortedBy:UXAbstractCategoryAttributes.name
                                             ascending:YES];
    }
    
    
    for (UXCategory *category in sortedCategories) {
        
        NSSortDescriptor *subCategoryNameSort = [NSSortDescriptor sortDescriptorWithKey:UXAbstractCategoryAttributes.name
                                                                              ascending:YES];
        
        NSArray *filteredSubCategories = [category.subCategories sortedArrayUsingDescriptors:@[subCategoryNameSort]];
        
        NSMutableArray *optionsInSubCategories = NSMutableArray.array;
        
        for (UXSubCategory *subCategory in filteredSubCategories) {
            
            NSPredicate *categoryFilter = [NSPredicate predicateWithFormat:@"%K.%K == %@ && %K.%K == %@",
                                           UXPersistentConfigOptionRelationships.option, UXOptionRelationships.category, category,
                                           UXPersistentConfigOptionRelationships.option, UXOptionRelationships.subCategory, subCategory];
            
            NSArray *filteredOptions = [[filteredConfigOptions filteredArrayUsingPredicate:categoryFilter]
                                        sortedArrayUsingDescriptors:@[optionNameSort]];
            
            /* Add Subcategory Header and options */
            if (filteredOptions.count > 0) {
                [optionsInSubCategories addObject:subCategory];
                [optionsInSubCategories addObjectsFromArray:filteredOptions];
            }
        }
        
        /* Add Category Header and options */
        if (optionsInSubCategories.count > 0) {
            [optionsInCategory addObject:category];
            [optionsInCategory addObjectsFromArray:optionsInSubCategories];
        }
    }
    
    [result addObjectsFromArray:optionsInCategory];
    
    return result;
}

@end