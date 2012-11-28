//
//  UXMainWindowController.h
//  UncrustifyX
//
//  Created by Ryan Maxwell on 13/10/12.
//  Copyright (c) 2012 Ryan Maxwell. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "UXSyntaxColoredTextViewController.h"
@class UXDocumentationPanelController;
@class UXExportPanelAccessoryView;

@interface UXMainWindowController : NSWindowController

@property (strong, nonatomic) UXDocumentationPanelController *documentationPanelController;
@property (strong, nonatomic) IBOutlet UXSyntaxColoredTextViewController *syntaxColoringController;

@property (weak, nonatomic) IBOutlet NSView *mainContainerView;
@property (weak, nonatomic) IBOutlet NSView *sourceContainerView;
@property (strong, nonatomic) IBOutlet NSView *fileInputView;
@property (strong, nonatomic) IBOutlet NSView *directInputView;

@property (strong, nonatomic) IBOutlet NSTextView *codeTextView;

@property (weak, nonatomic) IBOutlet NSTableView *filesTableView;
@property (weak, nonatomic) IBOutlet NSSplitView *mainSplitView;

@property (weak, nonatomic) IBOutlet NSToolbar *toolbar;
@property (weak, nonatomic) IBOutlet NSToolbarItem *exportToolbarItem;
@property (weak, nonatomic) IBOutlet NSToolbarItem *runToolbarItem;
@property (weak, nonatomic) IBOutlet NSToolbarItem *fileInputToolbarItem;
@property (weak, nonatomic) IBOutlet NSToolbarItem *directInputToolbarItem;

@property (weak, nonatomic) IBOutlet NSScrollView *configOptionsScrollView;
@property (weak, nonatomic) IBOutlet NSTableView *configOptionsTableView;
@property (weak, nonatomic) IBOutlet NSTableColumn *configOptionsTableColumn;

@property (weak, nonatomic) IBOutlet NSPopUpButton *inputLanguagesPopUpButton;
@property (strong, nonatomic) NSArrayController *inputLanguageArrayController;

@property (strong, nonatomic) IBOutlet UXExportPanelAccessoryView *exportPanelAccessoryView;

- (IBAction)exportConfiguration:(id)sender;
- (IBAction)importConfiguration:(id)sender;
- (IBAction)deletePressed:(id)sender;
- (IBAction)runButtonPressed:(id)sender;
- (IBAction)showFileList:(id)sender;
- (IBAction)showDirectInput:(id)sender;

- (IBAction)showDocumentationPanel:(id)sender;

- (void)addFilePaths:(NSArray *)filePaths;

@end
