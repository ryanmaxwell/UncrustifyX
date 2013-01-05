//
//  UXExportPanelAccessoryView.h
//  UncrustifyX
//
//  Created by Ryan Maxwell on 23/11/12.
//  Copyright (c) 2012 Ryan Maxwell. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface UXExportPanelAccessoryView : NSView

@property (weak, nonatomic) IBOutlet NSButton *includeBlankOptionsCheckbox;
@property (weak, nonatomic) IBOutlet NSButton *includeDocumentationCheckbox;
@property (weak, nonatomic) IBOutlet NSButton *categoriesCheckbox;
@property (weak, nonatomic) IBOutlet NSButton *subcategoriesCheckbox;
@property (weak, nonatomic) IBOutlet NSButton *optionNameCheckbox;
@property (weak, nonatomic) IBOutlet NSButton *optionValueCheckbox;

@end
