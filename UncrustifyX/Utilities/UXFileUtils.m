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
        if (configOption.configString) {
            
            if (documentation && configOption.option.name) {
                [contents appendFormat:@"\n\n# %@",configOption.option.name];
            }
            [contents appendFormat:@"\n%@", configOption.configString];
            
            if (documentation) {
                UXValueType *valueType = configOption.option.valueType;
                
                NSInteger tabs = 12;
                NSInteger totalSpaces = (tabs * 4);
                NSInteger trailingSpaces = (totalSpaces - configOption.configString.length);
                
                if (trailingSpaces > 0) {
                    for (NSInteger i = 0; i < trailingSpaces; i++) {
                        [contents appendString:@" "];
                    }
                } else {
                    [contents appendString:@" "];
                }
                
                [contents appendFormat:@"# %@", valueType.type];
                if (valueType.values.count) {
                    
                    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"value" ascending:YES];
                    NSArray *valuesArray = [valueType.values sortedArrayUsingDescriptors:@[sortDescriptor]];
                    NSMutableArray *valueNamesArray = NSMutableArray.array;
                    
                    for (UXValue *value in valuesArray) {
                        [valueNamesArray addObject:value.value];
                    }
                    
                    [contents appendFormat:@" (%@)", [valueNamesArray componentsJoinedByString:@", "]];
                }
            }
        }
    }
    
    NSData *data = [contents dataUsingEncoding:NSUTF8StringEncoding];
    
    return [NSFileManager.defaultManager createFileAtPath:filePath
                                          contents:data
                                               attributes:nil];
}

@end
