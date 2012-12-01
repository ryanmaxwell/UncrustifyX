//
//  UXDataImporter.m
//  UncrustifyX
//
//  Created by Ryan Maxwell on 13/10/12.
//  Copyright (c) 2012 Ryan Maxwell. All rights reserved.
//

#import "UXDataImporter.h"

#import "UXLanguage.h"
#import "UXCategory.h"
#import "UXSubCategory.h"
#import "UXOption.h"
#import "UXValueType.h"
#import "UXValue.h"
#import "UXCodeSample.h"

@implementation UXDataImporter

+ (void)deleteData {
    [UXCategory truncateAll];
    [UXSubCategory truncateAll];
    [UXLanguage truncateAll];
    [UXOption truncateAll];
    [UXValueType truncateAll];
    [UXCodeSample truncateAll];
    [NSManagedObjectContext.defaultContext save];
}

+ (void)importDefinitions {
    NSURL *fileURL = [NSBundle.mainBundle URLForResource:@"Definitions" withExtension:@"plist"];
    NSDictionary *rootDict = [NSDictionary dictionaryWithContentsOfURL:fileURL];
    
    /* Check updated at date */
    NSDate *definitionsUpdatedAt = rootDict[@"UpdatedAt"];
    if ([definitionsUpdatedAt timeIntervalSinceDate:UXDefaultsManager.definitionsUpdatedAt] == 0) {
        
        DLog(@"Current definitions up to date");
        return;
    };
    
    /* reimport data */
    DLog(@"Definitions version (%@) newer than current definitions (%@) - Performing Import",
         definitionsUpdatedAt,
         UXDefaultsManager.definitionsUpdatedAt);
    
    UXDefaultsManager.definitionsUpdatedAt = definitionsUpdatedAt;
    
    NSMutableDictionary *languagesDict = NSMutableDictionary.dictionary;
    NSMutableDictionary *categoriesDict = NSMutableDictionary.dictionary;
    NSMutableDictionary *subCategoriesDict = NSMutableDictionary.dictionary;
    NSMutableArray *valueTypesArray = NSMutableArray.array;
    
    /* Create or Update Languages */
    NSDictionary *languages = rootDict[@"Languages"];
    [languages enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL *stop){
        if ([value isKindOfClass:NSDictionary.class]) {
            NSDictionary *language = (NSDictionary *)value;
            
            UXLanguage *languageEntity = [UXLanguage findFirstByAttribute:UXLanguageAttributes.code
                                                                withValue:key];
            if (!languageEntity) {
                languageEntity = [UXLanguage createEntity];
                languageEntity.code = key;
            }
            
            languageEntity.name = language[@"Name"];
            
            languagesDict[key] = languageEntity;
        }
    }];
    
    /* Create or Update Value Types */
    for (NSDictionary *valueType in rootDict[@"ValueTypes"]) {
        NSString *theType = valueType[@"Type"];
        
        UXValueType *valueTypeEntity = [UXValueType findFirstByAttribute:UXValueTypeAttributes.type
                                                               withValue:theType];
        if (!valueTypeEntity) {
            valueTypeEntity = [UXValueType createEntity];
            valueTypeEntity.type = theType;
        } else {
            /* trash old values rather than update */
            for (UXValueType *vt in valueTypeEntity.values) {
                [vt deleteEntity];
            }
        }
        
        for (NSString *value in valueType[@"Values"]) {
            UXValue *newValue = [UXValue createEntity];
            newValue.value = value;
            newValue.valueType = valueTypeEntity;
        }

        NSNumber *valueTypeID = valueType[@"ID"];
        if (valueTypeID) {
            valueTypesArray[valueTypeID.unsignedIntegerValue] = valueTypeEntity;
        }
    }
    
    /* Replace all code samples */
    [UXCodeSample truncateAll];
    for (NSDictionary *codeSample in rootDict[@"CodeSamples"]) {
        UXCodeSample *newCodeSample = [UXCodeSample createEntity];
        newCodeSample.codeSampleDescription = codeSample[@"Description"];
        
        NSString *languageCode = codeSample[@"Language"];
        if (languageCode) {
            newCodeSample.language = languagesDict[languageCode];
        }
        newCodeSample.source = codeSample[@"Source"];
    }
    
    /* Create or Update Options */
    NSDictionary *options = rootDict[@"Options"];
    [options enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL *stop){
        if ([value isKindOfClass:NSDictionary.class]) {
            NSDictionary *option = (NSDictionary *)value;
            
            UXOption *optionEntity = [UXOption findFirstByAttribute:UXOptionAttributes.code
                                                          withValue:key];
            if (!optionEntity) {
                optionEntity = [UXOption createEntity];
                optionEntity.code = key;
            }
            
            optionEntity.name = option[@"Name"];
            optionEntity.optionDescription = option[@"Description"];
            
            NSString *categoryName = option[@"Category"];
            UXCategory *categoryEntity = nil;
            if (categoryName.length) {
                categoryEntity = categoriesDict[categoryName];
                if (!categoryEntity) {
                    categoryEntity = [UXCategory findFirstByAttribute:UXAbstractCategoryAttributes.name
                                                            withValue:categoryName];
                    if (!categoryEntity) {
                        categoryEntity = [UXCategory createEntity];
                        categoryEntity.name = categoryName;
                    }
                    
                    categoriesDict[categoryName] = categoryEntity;
                }
                optionEntity.category = categoryEntity;
            } else {
                optionEntity.category =
                categoryEntity = UXCategory.otherCategory;
            }
            
            NSString *subCategoryName = option[@"SubCategory"];
            UXSubCategory *subCategoryEntity = nil;
            if (subCategoryName.length) {
                subCategoryEntity = subCategoriesDict[subCategoryName];
                if (!subCategoryEntity) {
                    subCategoryEntity = [UXSubCategory findFirstByAttribute:UXAbstractCategoryAttributes.name
                                                                  withValue:subCategoryName];
                    if (!subCategoryEntity) {
                        subCategoryEntity = [UXSubCategory createEntity];
                        subCategoryEntity.name = subCategoryName;
                    } else {
                        /* relink parent categories */
                        subCategoryEntity.parentCategories = nil;
                    }
                    
                    subCategoriesDict[subCategoryName] = subCategoryEntity;
                }
                
                optionEntity.subCategory = subCategoryEntity;
            } else {
                optionEntity.subCategory = subCategoryEntity = UXSubCategory.otherSubCategory;
            }
            [subCategoryEntity addParentCategoriesObject:categoryEntity];
            
            /* Relink Value Types */
            optionEntity.valueType = nil;
            NSNumber *valueTypeID = option[@"ValueTypeID"];
            if (valueTypeID && valueTypeID.unsignedIntegerValue < valueTypesArray.count) {
                optionEntity.valueType = valueTypesArray[valueTypeID.unsignedIntegerValue];
            }
            
            optionEntity.defaultValue = option[@"Default"];
            
            /* Relink Languages */
            optionEntity.languages = nil;
            for (NSString *languageCode in option[@"Languages"]) {
                UXLanguage *language = languagesDict[languageCode];
                if (language) {
                    [optionEntity addLanguagesObject:language];
                }
            }
        }
    }];
    
    [NSManagedObjectContext.defaultContext save];
}

@end
