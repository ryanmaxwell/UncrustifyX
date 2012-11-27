//
//  UXUIUtils.m
//  UncrustifyX
//
//  Created by Ryan Maxwell on 16/11/12.
//  Copyright (c) 2012 Ryan Maxwell. All rights reserved.
//

#import "UXUIUtils.h"
#import "UXOption.h"
#import "UXValueType.h"
#import "UXValue.h"

@implementation UXUIUtils

+ (void)configureSegmentedControlValues:(NSSegmentedControl *)segmentedControl forOption:(UXOption *)option selectedValue:(NSString *)selectedValue {
    
    if (!option) return;
    
    NSUInteger numberOfValues = option.valueType.values.count;
    if (numberOfValues > 0) {
        segmentedControl.segmentCount = numberOfValues;
        
        CGFloat controlWidth = segmentedControl.frame.size.width - 6.0f; // 3pts each side for rounded corners
        CGFloat segmentWidth = controlWidth / numberOfValues;
        
        NSUInteger index = 0;
        NSInteger defaultValueIndex = NSNotFound;
        NSInteger selectedValueIndex = NSNotFound;
        
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:UXValueAttributes.value
                                                                         ascending:YES
                                                                          selector:@selector(caseInsensitiveCompare:)];
        NSArray *orderedValues = [option.valueType.values sortedArrayUsingDescriptors:@[sortDescriptor]];
        for (UXValue *value in orderedValues) {
            if ([value.value caseInsensitiveCompare:option.defaultValue] == NSOrderedSame) {
                defaultValueIndex = index;
            }
            
            if (selectedValue && ([value.value caseInsensitiveCompare:selectedValue] == NSOrderedSame)) {
                selectedValueIndex = index;
            }
            
            [segmentedControl setLabel:value.value forSegment:index];
            [segmentedControl setWidth:segmentWidth forSegment:index];
            index++;
        }
        
        if (selectedValueIndex != NSNotFound) {
            [segmentedControl setSelectedSegment:selectedValueIndex];
        } else if (defaultValueIndex != NSNotFound) {
            /* set default value selected */
            [segmentedControl setSelectedSegment:defaultValueIndex];
        } else {
            /* deselect any selected value */
            NSInteger selectedSegment = segmentedControl.selectedSegment;
            if (selectedSegment != -1) {
                [segmentedControl setSelected:NO forSegment:selectedSegment];
            }
        }
    }
}

@end
