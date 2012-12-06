//
//  UXFileUtils.m
//  UncrustifyX
//
//  Created by Ryan Maxwell on 13/11/12.
//  Copyright (c) 2012 Ryan Maxwell. All rights reserved.
//

#import "UXFileUtils.h"
#import "UXConfigOption.h"
#import "UXOption.h"
#import "UXValueType.h"
#import "UXValue.h"
#import "UXCategory.h"
#import "UXSubcategory.h"

static const NSUInteger SpacesPerTab = 4;

@implementation UXFileUtils

+ (NSString *)writeStringToTempFile:(NSString *)contents {
    NSString *guid = NSProcessInfo.processInfo.globallyUniqueString;
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:guid];
    NSData *data = [contents dataUsingEncoding:NSUTF8StringEncoding];
    
    if (![NSFileManager.defaultManager createFileAtPath:path
                                               contents:data
                                             attributes:nil]) {
        return nil;
    }
    return path;
}

+ (BOOL)  writeConfigOptions:(NSArray *)configOptions
                toFileAtPath:(NSString *)filePath
         includeBlankOptions:(BOOL)includeBlankOptions
    documentationForCategory:(BOOL)categoryDocumentation
                 subcategory:(BOOL)subcategoryDocumentation
                  optionName:(BOOL)optionNameDocumentation
                 optionValue:(BOOL)optionValueDocumentation {
    
    NSMutableString *contents = NSMutableString.string;
    
    NSString *header = [NSString stringWithFormat:@"#\n\
# Uncrustify Configuration File\n\
# File Created With UncrustifyX %@ (%@)\n\
#",
                        NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"],
                        NSBundle.mainBundle.infoDictionary[@"CFBundleVersion"]];
    
    [contents appendString:header];
    
    NSArray *categorizedConfigOptions = [UXConfigOptionSharedImplementation categorizedConfigOptionsFromConfigOptions:configOptions
                                                                                                          searchQuery:nil];
    
    for (id object in categorizedConfigOptions) {
        
        if (categoryDocumentation && [object isKindOfClass:UXCategory.class]) {
            UXCategory *category = object;
            
            if (category.name.length) {
                /*
                 
                 # Category name
                 # -------------
                 
                 */
                [contents appendFormat:@"\n\n# %@\n# ", category.name];
                
                for (NSUInteger i = 0; i < category.name.length; i++) {
                    [contents appendString:@"-"];
                }
            }
        } else if (subcategoryDocumentation && [object isKindOfClass:UXSubcategory.class]) {
            UXSubcategory *subcategory = object;
            
            if (subcategory.name.length) {
                /*
                 
                 ## Subcategory name
                 
                 */
                [contents appendFormat:@"\n\n## %@", subcategory.name];
            }
        } else if ([object conformsToProtocol:@protocol(UXConfigOption)]) {
            id<UXConfigOption> configOption = object;
            
            if (configOption.option == nil) continue;
            
            if (optionNameDocumentation && configOption.option.name) {
                [contents appendFormat:@"\n\n# %@",configOption.option.name];
            }
            
            if (configOption.value.length > 0 || includeBlankOptions) {
                NSInteger tabsBeforeValueAssignment = 10;
                NSInteger tabsBeforeValueDocumentation = 14;
                
                NSMutableString *optionLine = [NSMutableString stringWithString:configOption.option.code];
                
                NSInteger trailingSpaces1 = ((tabsBeforeValueAssignment * SpacesPerTab) - optionLine.length);
                NSInteger spacesToAppend1 = (trailingSpaces1 > 0) ? trailingSpaces1 : 1;
                
                for (NSInteger i = 0; i < spacesToAppend1; i++) {
                    [optionLine appendString:@" "];
                }
                
                if (configOption.value.length) {
                    [optionLine appendFormat:@"= %@", configOption.value.lowercaseString];
                }
                
                if (optionValueDocumentation) {
                    NSInteger trailingSpaces2 = ((tabsBeforeValueDocumentation * SpacesPerTab) - optionLine.length);
                    NSInteger spacesToAppend2 = (trailingSpaces2 > 0) ? trailingSpaces2 : 1;
                    
                    for (NSInteger i = 0; i < spacesToAppend2; i++) {
                        [optionLine appendString:@" "];
                    }
                    
                    UXValueType *valueType = configOption.option.valueType;
                    [optionLine appendFormat:@"# %@", valueType.type.lowercaseString];
                    if (valueType.values.count) {
                        
                        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"value" ascending:YES];
                        NSArray *valuesArray = [valueType.values sortedArrayUsingDescriptors:@[sortDescriptor]];
                        NSMutableArray *valueNamesArray = NSMutableArray.array;
                        
                        for (UXValue *value in valuesArray) {
                            [valueNamesArray addObject:value.value.lowercaseString];
                        }
                        
                        [optionLine appendFormat:@" (%@)", [valueNamesArray componentsJoinedByString:@"/"]];
                    }
                }
                
                [contents appendFormat:@"\n%@", optionLine];
            }
        }
    }
    
    NSData *data = [contents dataUsingEncoding:NSUTF8StringEncoding];
    
    return [NSFileManager.defaultManager createFileAtPath:filePath
                                          contents:data
                                               attributes:nil];
}

@end
