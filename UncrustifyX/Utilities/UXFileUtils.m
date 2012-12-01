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

+ (BOOL)writeConfigOptions:(NSArray *)configOptions toFileAtPath:(NSString *)filePath withDocumentation:(BOOL)documentation {
    NSMutableString *contents = NSMutableString.string;
    
    NSString *header = [NSString stringWithFormat:@"#\n\
# Uncrustify Configuration File\n\
# File Created With UncrustifyX %@ (%@)\n\
#",
                        NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"],
                        NSBundle.mainBundle.infoDictionary[@"CFBundleVersion"]];
    
    [contents appendString:header];
    
    // TODO: sort config options by category and subcategory
    for (id<UXConfigOption> configOption in configOptions) {
        if (configOption.option && configOption.value.length) {
            
            if (documentation) {
                
                static const NSInteger SpacesPerTab = 4;
                
                NSInteger tabsBeforeValueAssignment = 10;
                NSInteger tabsBeforeValueDocumentation = 14;
                
                [contents appendString:@"\n"];
                
                if (configOption.option.name) {
                    [contents appendFormat:@"\n# %@",configOption.option.name];
                }
                
                NSMutableString *optionLine = [NSMutableString stringWithString:configOption.option.code];
                
                NSInteger trailingSpaces1 = ((tabsBeforeValueAssignment * SpacesPerTab) - optionLine.length);
                NSInteger spacesToAppend1 = (trailingSpaces1 > 0) ? trailingSpaces1 : 1;
                
                for (NSInteger i = 0; i < spacesToAppend1; i++) {
                    [optionLine appendString:@" "];
                }
                
                [optionLine appendFormat:@"= %@", configOption.value.lowercaseString];
                
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
                
                [contents appendFormat:@"\n%@", optionLine];
            } else {
                [contents appendFormat:@"\n%@", configOption.configString];
            }
        }
    }
    
    NSData *data = [contents dataUsingEncoding:NSUTF8StringEncoding];
    
    return [NSFileManager.defaultManager createFileAtPath:filePath
                                          contents:data
                                               attributes:nil];
}

@end
