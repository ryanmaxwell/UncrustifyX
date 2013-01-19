//
//  UXLanguage.m
//  UncrustifyX
//
//  Created by Ryan Maxwell on 11/10/12.
//  Copyright (c) 2012 Ryan Maxwell. All rights reserved.
//

#import "UXLanguage.h"

NSString *const UXLanguageExtensionDelimiter = @":";

@implementation UXLanguage

+ (NSArray *)languagesWithExtension:(NSString *)extension {
    NSMutableArray *results = NSMutableArray.array;
    
    for (UXLanguage *language in [UXLanguage findAll]) {
        if ([language.fileExtensions containsObject:extension]) {
            [results addObject:language];
        }
    }
    
    return [results mutableCopy];
}

- (void)setIncludedInDocumentation:(BOOL)includedInDocumentation {
    [self willChangeValueForKey:@"menuDisplayName"];
    [self willChangeValueForKey:@"includedInDocumentation"];
    
    if (includedInDocumentation) {
        [UXDefaultsManager addLanguageIncludedInDocumentation:self.code];
    } else {
        [UXDefaultsManager removeLanguageIncludedInDocumentation:self.code];
    }
    
    [self didChangeValueForKey:@"menuDisplayName"];
    [self didChangeValueForKey:@"includedInDocumentation"];
}

- (BOOL)isIncludedInDocumentation {
    return [[UXDefaultsManager languagesIncludedInDocumentationPanel] containsObject:self.code];
}

- (NSString *)displayName {
    return self.name;
}

- (NSString *)menuDisplayName {
    return self.isIncludedInDocumentation ?
    [NSString stringWithFormat:@"✓ %@", self.name] : [NSString stringWithFormat:@"   %@", self.name];
}

- (NSArray *)fileExtensions {
    return [self.extensions componentsSeparatedByString:UXLanguageExtensionDelimiter];
}

@end
