//
//  UXUIUtils.h
//  UncrustifyX
//
//  Created by Ryan Maxwell on 16/11/12.
//  Copyright (c) 2012 Ryan Maxwell. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UXOption;

@interface UXUIUtils : NSObject

+ (void)configureSegmentedControlValues:(NSSegmentedControl *)segmentedControl forOption:(UXOption *)option selectedValue:(NSString *)selectedValue;

@end
