//
//  UXLanguage.m
//  UncrustifyX
//
//  Created by Ryan Maxwell on 11/10/12.
//  Copyright (c) 2012 Ryan Maxwell. All rights reserved.
//

#import "UXLanguage.h"

@implementation UXLanguage

- (void)setIncludedInDocumentation:(NSNumber *)includedInDocumentation {
    [self willChangeValueForKey:@"menuDisplayName"];
    [self willChangeValueForKey:@"includedInDocumentation"];
    self.primitiveIncludedInDocumentation = includedInDocumentation;
    [self didChangeValueForKey:@"menuDisplayName"];
    [self didChangeValueForKey:@"includedInDocumentation"];
}

- (NSString *)displayName {
    return self.name;
}

- (NSString *)menuDisplayName {
    return self.primitiveIncludedInDocumentationValue ?
    [NSString stringWithFormat:@"✓ %@", self.name] : [NSString stringWithFormat:@"   %@", self.name];
}

@end
