//
//  UXConfigOptionTableCellView.m
//  UncrustifyX
//
//  Created by Ryan Maxwell on 11/11/12.
//  Copyright (c) 2012 Ryan Maxwell. All rights reserved.
//

#import "UXConfigOptionTableCellView.h"
#import "UXMainWindowController.h"
#import "UXDocumentationPanelController.h"
#import "UXConfigOption.h"
#import "UXUIUtils.h"
#import "UXOption.h"
#import "UXValueType.h"

NSString *const ConfigOptionCellReuseIdentifier = @"ConfigOptionTableCellView";
NSString *const CategoryCellReuseIdentifier = @"CategoryTableCellView";
NSString *const SubcategoryCellReuseIdentifier = @"SubcategoryTableCellView";

@implementation UXConfigOptionTableCellView

- (IBAction)infoPressed:(id)sender {
    UXAppDelegate *appDelegate = (UXAppDelegate *) NSApplication.sharedApplication.delegate;
    
    id<UXConfigOption> configOption = self.objectValue;
    [appDelegate.mainWindowController.documentationPanelController showInfoForOption:configOption.option];
}

- (NSString *)reuseIdentifier {
    return ConfigOptionCellReuseIdentifier;
}

- (void)setObjectValue:(id)objectValue {
    [super setObjectValue:objectValue];
    
    if ([objectValue conformsToProtocol:@protocol(UXConfigOption)]) {
        id<UXConfigOption> configOption = (id<UXConfigOption>)objectValue;
        
        if (configOption.option.valueType.values.count) {
            /* value type has set values */
            [UXUIUtils configureSegmentedControlValues:self.valueSegmentedControl
                                             forOption:configOption.option
                                         selectedValue:configOption.value];
        } else {
            /* value type is free-form string */
            if (configOption.value) {
                self.valueTextField.stringValue = configOption.value;
            } else {
                self.valueTextField.stringValue = @"";
            }
        }
    }
}

- (IBAction)valueSegmentedControlChanged:(id)sender {
    NSSegmentedControl *segmentedControl = (NSSegmentedControl *)sender;
    
    NSString *selectedValue = [segmentedControl labelForSegment:segmentedControl.selectedSegment];
    
    id<UXConfigOption> selectedOption = self.objectValue;
    selectedOption.value = selectedValue;
    [NSManagedObjectContext.defaultContext saveToPersistentStoreWithCompletion:nil];
}

#pragma mark - NSTextFieldDelegate

- (void)controlTextDidChange:(NSNotification *)notification {
    NSTextField *textField = notification.object;
    id<UXConfigOption> selectedOption = self.objectValue;
    selectedOption.value = textField.stringValue;
    [NSManagedObjectContext.defaultContext saveToPersistentStoreWithCompletion:nil];
}

@end
