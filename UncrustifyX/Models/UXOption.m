//
//  UXOption.m
//  UncrustifyX
//
//  Created by Ryan Maxwell on 11/10/12.
//  Copyright (c) 2012 Ryan Maxwell. All rights reserved.
//

#import "UXOption.h"
#import "UXSubcategory.h"

@implementation UXOption

- (NSString *)displayName {
    return (self.name.length) ? self.name : self.code;
}

- (NSString *)explodedCode {
    return [self.code stringByReplacingOccurrencesOfString:@"_" withString:@" "];
}

- (void)setDisplayName:(NSString *)newName {
    self.name = newName;
    
    if (!newName.length)
        newName = @"";
    
    [self updateOptionValue:newName forKey:@"Name"];
}

- (NSString *)subcategoryName {
    return self.subcategory.name;
}

- (void)setSubcategoryName:(NSString *)newName {
    self.subcategory.name = newName;
    
    if (!newName.length)
        newName = @"";
    
    [self willChangeValueForKey:@"Subcategory"];
    [self updateOptionValue:newName forKey:@"Subcategory"];
    [self didChangeValueForKey:@"Subcategory"];
}

- (void)updateOptionValue:(id)value forKey:(NSString *)key {
    NSString *plistPath = @"/Users/ryan/Code/UncrustifyX-Github/UncrustifyX/Resources/Definitions.plist";
    NSFileManager *manager = NSFileManager.defaultManager;
    
    if (![manager fileExistsAtPath:plistPath]) return;
    
    if ([manager isWritableFileAtPath:plistPath]) {
        NSMutableDictionary *infoDict = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
        
        NSMutableDictionary *oldOption = infoDict[@"Options"][self.code];
        oldOption[key] = value;
        
        infoDict[@"UpdatedAt"] = NSDate.date;
        
        [infoDict writeToFile:plistPath atomically:NO];
        
        
        [manager setAttributes:@{NSFileModificationDate : NSDate.date}
                  ofItemAtPath:plistPath
                         error:nil];
    }
}

@end
