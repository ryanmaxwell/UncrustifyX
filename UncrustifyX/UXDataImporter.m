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
    
    /* Check version */
    NSUInteger definitionsVersion = [rootDict[@"Version"] unsignedIntegerValue];
    
    if (definitionsVersion <= UXDefaultsManager.definitionsVersion) {
        
        DLog(@"Current definitions version (%d) up to date", definitionsVersion);
        return;
    };
    
    /* reimport data */
    DLog(@"Definitions version (%d) newer than current definitions (%d) - Performing Import",
         definitionsVersion,
         UXDefaultsManager.definitionsVersion);
    
    [self deleteData];
    
    UXDefaultsManager.definitionsVersion = definitionsVersion;
    
    NSMutableDictionary *languagesDict = NSMutableDictionary.dictionary;
    NSMutableDictionary *categoriesDict = NSMutableDictionary.dictionary;
    NSMutableDictionary *subCategoriesDict = NSMutableDictionary.dictionary;
    NSMutableArray *valueTypesArray = NSMutableArray.array;
    
    NSDictionary *languages = rootDict[@"Languages"];
    [languages enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL *stop){
        if ([value isKindOfClass:NSDictionary.class]) {
            NSDictionary *language = (NSDictionary *)value;
            
            UXLanguage *newLanguage = [UXLanguage createEntity];
            newLanguage.code = key;
            newLanguage.name = language[@"Name"];
            
            languagesDict[key] = newLanguage;
        }
    }];

    for (NSDictionary *valueType in rootDict[@"ValueTypes"]) {
        UXValueType *newValueType = [UXValueType createEntity];
        newValueType.type = valueType[@"Type"];
        
        for (NSString *value in valueType[@"Values"]) {
            UXValue *newValue = [UXValue createEntity];
            newValue.value = value;
            [newValueType addValuesObject:newValue];
        }

        NSNumber *valueTypeID = valueType[@"ID"];
        if (valueTypeID) {
            valueTypesArray[valueTypeID.unsignedIntegerValue] = newValueType;
        }
    }
    
    for (NSDictionary *codeSample in rootDict[@"CodeSamples"]) {
        UXCodeSample *newCodeSample = [UXCodeSample createEntity];
        newCodeSample.codeSampleDescription = codeSample[@"Description"];
        
        NSString *languageCode = codeSample[@"Language"];
        if (languageCode) {
            newCodeSample.language = languagesDict[languageCode];
        }
        newCodeSample.source = codeSample[@"Source"];
    }
    
    NSDictionary *options = rootDict[@"Options"];
    [options enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL *stop){
        if ([value isKindOfClass:NSDictionary.class]) {
            NSDictionary *option = (NSDictionary *)value;
            
            UXOption *newOption = [UXOption createEntity];
            newOption.code = key;
            newOption.name = option[@"Name"];
            newOption.optionDescription = option[@"Description"];
            
            NSString *categoryName = option[@"Category"];
            UXCategory *theCategory = nil;
            if (categoryName.length) {
                theCategory = categoriesDict[categoryName];
                if (!theCategory) {
                    theCategory = [UXCategory createEntity];
                    theCategory.name = categoryName;
                    
                    categoriesDict[categoryName] = theCategory;
                }
                newOption.category = theCategory;
            } else {
                newOption.category =
                theCategory = UXCategory.otherCategory;
            }
            
            NSString *subCategoryName = option[@"SubCategory"];
            UXSubCategory *theSubCategory = nil;
            if (subCategoryName.length) {
                theSubCategory = subCategoriesDict[subCategoryName];
                if (!theSubCategory) {
                    theSubCategory = [UXSubCategory createEntity];
                    theSubCategory.name = subCategoryName;
                    
                    subCategoriesDict[subCategoryName] = theSubCategory;
                }
                
                newOption.subCategory = theSubCategory;
            } else {
                newOption.subCategory = theSubCategory = UXSubCategory.otherSubCategory;
            }
            [theSubCategory addParentCategoriesObject:theCategory];
            
            NSNumber *valueTypeID = option[@"ValueTypeID"];
            if (valueTypeID && valueTypeID.unsignedIntegerValue < valueTypesArray.count) {
                newOption.valueType = valueTypesArray[valueTypeID.unsignedIntegerValue];
            }
            
            newOption.defaultValue = option[@"Default"];
            
            for (NSString *languageCode in option[@"Languages"]) {
                UXLanguage *language = languagesDict[languageCode];
                if (language) {
                    [newOption addLanguagesObject:language];
                }
            }
        }
    }];
    
    [NSManagedObjectContext.defaultContext save];
}

@end
