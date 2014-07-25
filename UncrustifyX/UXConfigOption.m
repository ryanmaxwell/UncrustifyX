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
        NSPredicate *searchFilter = [NSPredicate predicateWithFormat:@"%K.%K CONTAINS[c] %@ OR %K.%K CONTAINS[c] %@ OR %K.%K CONTAINS[c] %@ OR %K.%K CONTAINS[c] %@",
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
        sortedCategories = [UXCategory MR_findAllSortedBy:UXAbstractCategoryAttributes.name
                                                ascending:YES];
    }

    for (UXCategory *category in sortedCategories) {
        NSSortDescriptor *subcategoryNameSort = [NSSortDescriptor sortDescriptorWithKey:UXAbstractCategoryAttributes.name
                                                                              ascending:YES];

        NSArray *filteredSubcategories = [category.subcategories sortedArrayUsingDescriptors:@[subcategoryNameSort]];

        NSMutableArray *optionsInSubcategories = NSMutableArray.array;

        for (UXSubcategory *subcategory in filteredSubcategories) {
            NSPredicate *categoryFilter = [NSPredicate predicateWithFormat:@"%K.%K == %@ && %K.%K == %@",
                                           UXPersistentConfigOptionRelationships.option, UXOptionRelationships.category, category,
                                           UXPersistentConfigOptionRelationships.option, UXOptionRelationships.subcategory, subcategory];

            NSArray *filteredOptions = [[filteredConfigOptions filteredArrayUsingPredicate:categoryFilter]
                                        sortedArrayUsingDescriptors:@[optionNameSort]];

            /* Add Subcategory Header and options */
            if (filteredOptions.count > 0) {
                [optionsInSubcategories addObject:subcategory];
                [optionsInSubcategories addObjectsFromArray:filteredOptions];
            }
        }

        /* Add Category Header and options */
        if (optionsInSubcategories.count > 0) {
            [optionsInCategory addObject:category];
            [optionsInCategory addObjectsFromArray:optionsInSubcategories];
        }
    }

    [result addObjectsFromArray:optionsInCategory];

    return result;
}

@end