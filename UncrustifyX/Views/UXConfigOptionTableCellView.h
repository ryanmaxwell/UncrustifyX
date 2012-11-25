//
//  UXConfigOptionTableCellView.h
//  UncrustifyX
//
//  Created by Ryan Maxwell on 11/11/12.
//  Copyright (c) 2012 Ryan Maxwell. All rights reserved.
//

#import <Cocoa/Cocoa.h>

FOUNDATION_EXPORT NSString *const ConfigOptionCellReuseIdentifier;
FOUNDATION_EXPORT NSString *const CategoryCellReuseIdentifier;
FOUNDATION_EXPORT NSString *const SubCategoryCellReuseIdentifier;

@interface UXConfigOptionTableCellView : NSTableCellView <NSTextFieldDelegate>

@property (weak, nonatomic) IBOutlet NSSegmentedControl *valueSegmentedControl;
@property (weak, nonatomic) IBOutlet NSTextField *valueTextField;

- (IBAction)infoPressed:(id)sender;
- (IBAction)valueSegmentedControlChanged:(id)sender;

@end
