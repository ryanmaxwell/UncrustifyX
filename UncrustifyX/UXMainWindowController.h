//
//  UXMainWindowController.h
//  UncrustifyX
//
//  Created by Ryan Maxwell on 13/10/12.
//  Copyright (c) 2012 Ryan Maxwell. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class UXDocumentationPanelController;
@class UXExportPanelAccessoryView;
@class UXLanguage;

@interface UXMainWindowController : NSWindowController

@property (strong, nonatomic) UXDocumentationPanelController *documentationPanelController;

@property (weak, nonatomic) IBOutlet NSView *mainContainerView;
@property (weak, nonatomic) IBOutlet NSView *sourceContainerView;
@property (strong, nonatomic) IBOutlet NSView *fileInputView;
@property (strong, nonatomic) IBOutlet NSView *directInputView;

@property (weak, nonatomic) IBOutlet NSSearchField *searchField;

@property (weak, nonatomic) IBOutlet NSView *fragariaContainerView;

@property (weak, nonatomic) IBOutlet NSTableView *filePathsTableView;
@property (weak, nonatomic) IBOutlet NSSplitView *mainSplitView;
@property (weak, nonatomic) IBOutlet NSTableColumn *filePathTableColumn;
@property (weak, nonatomic) IBOutlet NSTableColumn *fileTypeTableColumn;

@property (weak, nonatomic) IBOutlet NSToolbar *toolbar;
@property (weak, nonatomic) IBOutlet NSToolbarItem *exportToolbarItem;
@property (weak, nonatomic) IBOutlet NSToolbarItem *runToolbarItem;
@property (weak, nonatomic) IBOutlet NSToolbarItem *fileInputToolbarItem;
@property (weak, nonatomic) IBOutlet NSToolbarItem *directInputToolbarItem;

@property (weak, nonatomic) IBOutlet NSScrollView *configOptionsScrollView;
@property (weak, nonatomic) IBOutlet NSTableView *configOptionsTableView;
@property (weak, nonatomic) IBOutlet NSTableColumn *configOptionsTableColumn;

@property (weak, nonatomic) IBOutlet NSPopUpButton *inputLanguagePopUpButton;
@property (strong, nonatomic) NSArrayController *inputLanguageArrayController;
@property (weak, nonatomic) UXLanguage *selectedPreviewLanguage;

@property (strong, nonatomic) IBOutlet UXExportPanelAccessoryView *exportPanelAccessoryView;

@property (strong, nonatomic) NSMutableArray *configOptions;

- (IBAction)addFilesPressed:(id)sender;
- (IBAction)removeFilesPressed:(id)sender;

- (IBAction)exportConfigurationPressed:(id)sender;
- (IBAction)importConfigurationPressed:(id)sender;
- (IBAction)deletePressed:(id)sender;
- (IBAction)runButtonPressed:(id)sender;
- (IBAction)showView:(id)sender;
- (IBAction)previewLanguagePopUpChanged:(id)sender;
- (IBAction)toggleDocumentationPanel:(id)sender;

- (void)addFilePaths:(NSArray *)filePaths;
- (void)importConfigurationAtURL:(NSURL *)fileURL;

/* Validation for toolbar / menu items */
@property (readonly) BOOL isRunEnabled;
@property (readonly) BOOL isExportEnabled;

@end
