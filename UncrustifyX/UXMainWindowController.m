//
//  UXMainWindowController.m
//  UncrustifyX
//
//  Created by Ryan Maxwell on 13/10/12.
//  Copyright (c) 2012 Ryan Maxwell. All rights reserved.
//

#import "UXMainWindowController.h"
#import "UXDocumentationPanelController.h"
#import "UXCodeSample.h"
#import "UXTaskRunner.h"
#import "UXFileUtils.h"
#import "UXOption.h"
#import "UXCategory.h"
#import "UXSubCategory.h"
#import "UXLanguage.h"
#import "UXPersistentConfigOption.h"
#import "UXConfigOptionTableCellView.h"
#import "UXConfigOptionTableView.h"
#import "UXExportPanelAccessoryView.h"

/* NSWindowRestoration keys */
#define kSourceContainerViewWidthKey        @"SourceContainerViewWidth"
#define kSelectedLanguageCodeKey            @"SelectedLanguageCode"
#define kDocumentationPanelVisibleKey       @"DocumentationPanelVisible"
#define kSelectedToolbarItemIdentifierKey   @"SelectedToolbarItemIdentifier"

#define kDocumentationPanelIdentifier       @"DocumentationPanel"
#define kSidebarSpaceToolbarItemIdentifier  @"UXSidebarSpace"

static const CGFloat SourceViewMinWidth = 200.0f;
static const CGFloat SourceViewMaxWidth = 450.0f;

@interface UXMainWindowController () <NSTableViewDelegate, NSTableViewDataSource, NSSplitViewDelegate, UXConfigOptionTableViewDelegate, NSTextViewDelegate, NSWindowRestoration> {
    BOOL _initialize;
}
@property (strong, nonatomic) NSArray *sortedCategories;

@property (strong, nonatomic) NSMutableArray *sortedConfigOptionsAndCategories;
@property (strong, nonatomic) NSMutableArray *filePaths;

@property (strong, nonatomic) NSView *spaceView;
@property (strong, nonatomic) NSToolbarItem *spaceItem;

@property (strong, nonatomic) NSString *searchQuery;

@end

@implementation UXMainWindowController

- (id)initWithWindowNibName:(NSString *)windowNibName {
    self = [super initWithWindowNibName:windowNibName];
    if (self) {
        _documentationPanelController = [[UXDocumentationPanelController alloc] initWithWindowNibName:@"UXDocumentationPanelController"];
        _documentationPanelController.window.restorationClass = self.class;
        _documentationPanelController.window.identifier = kDocumentationPanelIdentifier;
        
        _sortedConfigOptionsAndCategories = [[NSMutableArray alloc] init];
        _filePaths = [[NSMutableArray alloc] init];
        
        _sortedCategories = [UXCategory findAllSortedBy:UXAbstractCategoryAttributes.name
                                              ascending:YES];
        
        _configOptions = [[NSMutableArray alloc] initWithArray:[UXPersistentConfigOption findAll]];
        [self sortConfigOptions];
        
        _inputLanguageArrayController = [[NSArrayController alloc] init];
        _inputLanguageArrayController.sortDescriptors = @[
            [NSSortDescriptor sortDescriptorWithKey:UXLanguageAttributes.name
                                          ascending:YES]
        ];
        _inputLanguageArrayController.managedObjectContext = NSManagedObjectContext.defaultContext;
        _inputLanguageArrayController.entityName = UXLanguage.entityName;
        
        _initialize = YES;
    }
    return self;
}

- (void)awakeFromNib {
    
    /* awakeFromNib annoyingly called each time a table view cell view is created */
    @synchronized(self) {
        if (_initialize) {
            _initialize = NO;
            
            NSNib *cellNib = [[NSNib alloc] initWithNibNamed:@"UXConfigOptionTableCellViews" bundle:nil];
            [self.configOptionsTableView registerNib:cellNib forIdentifier:ConfigOptionCellReuseIdentifier];
            [self.configOptionsTableView registerNib:cellNib forIdentifier:CategoryCellReuseIdentifier];
            [self.configOptionsTableView registerNib:cellNib forIdentifier:SubCategoryCellReuseIdentifier];
            
            [self.filesTableView registerForDraggedTypes:@[
             NSURLPboardType
             ]];
            
            [self.configOptionsTableView registerForDraggedTypes:@[
             NSPasteboardTypeString
             ]];
            
            [self showFileInputView];
            
            _spaceView = [[NSView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
            [self.toolbar insertItemWithItemIdentifier:kSidebarSpaceToolbarItemIdentifier
                                               atIndex:2];
            
            [self.inputLanguageArrayController fetch:nil];
            
            self.selectedLanguage = [UXLanguage findFirstOrderedByAttribute:UXLanguageAttributes.name
                                                                  ascending:YES];
            
            [self.window makeKeyAndOrderFront:self];
        }
    }
}

#pragma mark - 

- (UXPersistentConfigOption *)configOptionWithCode:(NSString *)code {
    for (UXPersistentConfigOption *configOption in self.configOptions) {
        if (configOption.option && ([configOption.option.code caseInsensitiveCompare:code] == NSOrderedSame)) {
            return configOption;
        }
    }
    return nil;
}

- (void)parseConfigLine:(NSString *)line {
    NSString *lineValue = nil;
    NSScanner *lineScanner = [NSScanner scannerWithString:line];
    [lineScanner scanUpToString:@"#" intoString:&lineValue];
    
    if (lineValue.length) {
        NSArray *lineOptions = [lineValue componentsSeparatedByString:@"="];
        NSString *optionCode = nil;
        NSString *optionValue = nil;
        
        if (lineOptions.count > 0) {
            optionCode = [lineOptions[0] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
            NSLog(@"Code: '%@'", optionCode);
        }
        
        if (lineOptions.count > 1) {
            optionValue = [lineOptions[1] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
            NSLog(@"Value: '%@'", optionValue);
        }
        [self addConfigOptionWithCode:optionCode value:optionValue];
    }
}

- (void)addConfigOptionWithCode:(NSString *)code value:(NSString *)value {
    if (![self configOptionWithCode:code]) {
        UXOption *theOption = [UXOption findFirstByAttribute:UXOptionAttributes.code withValue:code];
        if (theOption) {
            UXPersistentConfigOption *newConfigOption = [UXPersistentConfigOption createEntity];
            newConfigOption.option = theOption;
            newConfigOption.value = value;
            
            [self.configOptions addObject:newConfigOption];
            [NSManagedObjectContext.defaultContext save];
        } else {
            DLog(@"COULD NOT FIND OPTION WITH %@ code", code);
        }
    } else {
        DLog(@"ALREADY HAVE CONFIG OPTION WITH %@ code", code);
    }
}

- (void)sortConfigOptions {
    
    NSArray *filteredConfigOptions = nil;
    
    if (self.searchQuery) {
        NSPredicate  *searchFilter = [NSPredicate predicateWithFormat:@"%K.%K CONTAINS[c] %@ OR %K.%K CONTAINS[c] %@ OR %K.%K CONTAINS[c] %@ OR %K.%K CONTAINS[c] %@",
                                      UXPersistentConfigOptionRelationships.option, UXOptionAttributes.optionDescription, self.searchQuery,
                                      UXPersistentConfigOptionRelationships.option, UXOptionAttributes.code, self.searchQuery,
                                      UXPersistentConfigOptionRelationships.option, UXOptionAttributes.name, self.searchQuery,
                                      UXPersistentConfigOptionRelationships.option, @"explodedCode", self.searchQuery];
        
        filteredConfigOptions = [self.configOptions filteredArrayUsingPredicate:searchFilter];
    } else {
        filteredConfigOptions = [NSArray arrayWithArray:self.configOptions];
    }
    
    [self.sortedConfigOptionsAndCategories removeAllObjects];
    
    NSString *sortKey = [NSString stringWithFormat:@"%@.%@",
                         UXPersistentConfigOptionRelationships.option, UXOptionAttributes.name];
    NSSortDescriptor *optionNameSort = [NSSortDescriptor sortDescriptorWithKey:sortKey
                                                                     ascending:YES];
    
    NSMutableArray *optionsInCategory = NSMutableArray.array;
    
    /* Categories and their config options */
    for (UXCategory *category in self.sortedCategories) {
        
        NSSortDescriptor *subCategoryNameSort = [NSSortDescriptor sortDescriptorWithKey:UXAbstractCategoryAttributes.name
                                                                              ascending:YES];
        
        NSArray *filteredSubCategories = [category.subCategories sortedArrayUsingDescriptors:@[subCategoryNameSort]];
        
        NSMutableArray *optionsInSubCategories = NSMutableArray.array;
        
        for (UXSubCategory *subCategory in filteredSubCategories) {
            
            NSPredicate *categoryFilter = [NSPredicate predicateWithFormat:@"%K.%K == %@ && %K.%K == %@",
                                           UXPersistentConfigOptionRelationships.option, UXOptionRelationships.category, category,
                                           UXPersistentConfigOptionRelationships.option, UXOptionRelationships.subCategory, subCategory];
            
            NSArray *filteredOptions = [[filteredConfigOptions filteredArrayUsingPredicate:categoryFilter]
                                        sortedArrayUsingDescriptors:@[optionNameSort]];
            
            /* Add Subcategory Header and options */
            if (filteredOptions.count > 0) {
                [optionsInSubCategories addObject:subCategory];
                [optionsInSubCategories addObjectsFromArray:filteredOptions];
            }
        }
        
        /* Add Category Header and options */
        if (optionsInSubCategories.count > 0) {
            [optionsInCategory addObject:category];
            [optionsInCategory addObjectsFromArray:optionsInSubCategories];
        }
    }
    
    [self.sortedConfigOptionsAndCategories addObjectsFromArray:optionsInCategory];
    
    [self.configOptionsTableView reloadData];
}

- (UXExportPanelAccessoryView *)exportPanelAccessoryView {
    if (!_exportPanelAccessoryView) {
        [NSBundle.mainBundle loadNibNamed:@"UXExportPanelAccessoryView"
                                    owner:self
                          topLevelObjects:nil];
    }
    return _exportPanelAccessoryView;
}

- (void)showFileInputView {
    self.toolbar.selectedItemIdentifier = @"UXFileInput";
    
    if (!self.fileInputView.superview) {
        [self.directInputView removeFromSuperview];
        
        self.fileInputView.frame = self.mainContainerView.bounds;
        [self.mainContainerView addSubview:self.fileInputView];
    }
}

- (void)showDirectInputView {
    self.toolbar.selectedItemIdentifier = @"UXDirectInput";
    
    if (!self.directInputView.superview) {
        [self.fileInputView removeFromSuperview];
        
        self.directInputView.frame = self.mainContainerView.bounds;
        [self.mainContainerView addSubview:self.directInputView];
    }
}

#pragma mark - IBAction

- (IBAction)showView:(id)sender {
    if (sender == self.fileInputToolbarItem) {
        [self showFileInputView];
    } else if (sender == self.directInputToolbarItem) {
        [self showDirectInputView];
    }
}

- (IBAction)runButtonPressed:(id)sender {
    if ([self.toolbar.selectedItemIdentifier isEqualToString:self.fileInputToolbarItem.itemIdentifier]
        && self.filePaths.count > 0) {
        
        NSArray *args = nil;
        if (UXDefaultsManager.overwriteFiles) {
            args = @[@"--no-backup"];
        }
        
        [UXTaskRunner uncrustifyFilesAtPaths:self.filePaths
                           withConfigOptions:self.configOptions
                                   arguments:args];
    } else if ([self.toolbar.selectedItemIdentifier isEqualToString:self.directInputToolbarItem.itemIdentifier]
        && self.codeTextView.string.length > 0) {
        
        NSString *result = [UXTaskRunner uncrustifyCodeFragment:self.codeTextView.string
                                              withConfigOptions:self.configOptions
                                                      arguments:@[@"-l", self.selectedLanguage.code]];
        if (result) {
            self.codeTextView.string = result;
            [self.syntaxColoringController recolorCompleteFile:self];
        }
    }
}

- (IBAction)toggleDocumentationPanel:(id)sender {
    self.documentationPanelController.window.isVisible = !self.documentationPanelController.window.isVisible;
}

- (IBAction)exportConfigurationPressed:(id)sender {
    NSSavePanel *savePanel = NSSavePanel.savePanel;
    savePanel.allowedFileTypes = @[@"cfg"];
    savePanel.accessoryView = self.exportPanelAccessoryView;
    
    [savePanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result){
        
        BOOL includeDocumentation = (self.exportPanelAccessoryView.includeDocumentationCheckbox.state == NSOnState);
        DLog(@"Include documentation %d", includeDocumentation);
        
        if (result == NSFileHandlingPanelOKButton) {
            [UXFileUtils writeConfigOptions:self.configOptions
                               toFileAtPath:savePanel.URL.path
                               withDocumentation:includeDocumentation];
        }
    }];
}

- (IBAction)importConfigurationPressed:(id)sender {
    NSOpenPanel *openPanel = NSOpenPanel.openPanel;
    openPanel.allowedFileTypes = @[@"cfg"];
    
    [openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            [self importConfigurationAtURL:openPanel.URL];
        }
    }];
}

- (void)importConfigurationAtURL:(NSURL *)fileURL {
    NSError *error = nil;
    NSString *contents = [NSString stringWithContentsOfURL:fileURL
                                                  encoding:NSUTF8StringEncoding
                                                     error:&error];
    if (!error) {
        
        for (UXPersistentConfigOption *configOption in self.configOptions) {
            [configOption deleteEntity];
        }
        [self.configOptions removeAllObjects];
        
        
        NSArray *lines = [contents componentsSeparatedByString:@"\n"];
        
        for (NSString *line in lines) {
            [self parseConfigLine:line];
        }
        
        [self sortConfigOptions];
    } else {
        DErr(@"%@", error);
    }
}

- (IBAction)deletePressed:(id)sender {
    NSIndexSet *selectedConfigOptions = self.configOptionsTableView.selectedRowIndexes;
    NSIndexSet *selectedFilePaths = self.filesTableView.selectedRowIndexes;
    
    if (self.window.firstResponder == self.filesTableView && selectedFilePaths.count > 0) {
        NSMutableArray *objectsToRemove = NSMutableArray.array;
        
        [selectedFilePaths enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop){
            [objectsToRemove addObject:self.filePaths[index]];
        }];
        
        [self.filePaths removeObjectsInArray:objectsToRemove];
        
        /* Validate immediately as system only does it periodically */
        [self.toolbar validateVisibleItems];
        
        [self.filesTableView reloadData];
    } else if (self.window.firstResponder == self.configOptionsTableView && selectedConfigOptions.count > 0) {
        NSMutableArray *objectsToRemove = NSMutableArray.array;
        
        [selectedConfigOptions enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop){
            [objectsToRemove addObject:self.sortedConfigOptionsAndCategories[index]];
        }];
        
        [self.configOptions removeObjectsInArray:objectsToRemove];
        for (NSManagedObject *mo in objectsToRemove) {
            [NSManagedObjectContext.defaultContext deleteObject:mo];
        }
        [NSManagedObjectContext.defaultContext save];
        
        /* Validate immediately as system only does it periodically */
        [self.toolbar validateVisibleItems];
        
        [self sortConfigOptions];
    }
}

- (void)addFilePaths:(NSArray *)filePaths {
    for (id obj in filePaths) {
        if ([obj isKindOfClass:NSString.class] && ![self.filePaths containsObject:obj]) {
            [self.filePaths addObject:obj];
        }
    }
    [self showFileInputView];
    [self.filesTableView reloadData];
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if (tableView == self.configOptionsTableView) {
        return self.sortedConfigOptionsAndCategories.count;
    } else if (tableView == self.filesTableView) {
        return self.filePaths.count;
    }
    return 0;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    if (tableView == self.configOptionsTableView) {
        if (![self tableView:tableView isGroupRow:row]) {
            return 40.0f;
        }
    }
    
    return 20.0f;
}

- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id<NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation {
    
    if (tableView == self.filesTableView) {
        NSPasteboard *pboard = [info draggingPasteboard];
        
        if([pboard.types containsObject:NSFilenamesPboardType]){
            
            NSArray *fileList = [pboard propertyListForType:NSFilenamesPboardType];
            [self addFilePaths:fileList];
        }
        
        return YES;
    } else if (tableView == self.configOptionsTableView) {
        NSPasteboard *pboard = [info draggingPasteboard];
        
        NSArray *stringItems = [pboard readObjectsForClasses:@[NSString.class]
                                                     options:nil];
        
        for (NSString *optionLine in stringItems) {
            DLog(@"%@", optionLine);
            
            [self parseConfigLine:optionLine];
        }
        
        [self sortConfigOptions];
        
        return YES;
    }
    
    return NO;
}

- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation {
    return operation;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)rowIndex {
    if (tableView == self.configOptionsTableView && tableColumn == self.configOptionsTableColumn) {
        return self.sortedConfigOptionsAndCategories[rowIndex];
    } else if (tableView == self.filesTableView) {
        return self.filePaths[rowIndex];
    }
    return nil;
}

#pragma mark - NSTableViewDelegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    if (tableView == self.configOptionsTableView) {
        id objectValue = self.sortedConfigOptionsAndCategories[row];
        
        if ([self tableView:tableView isGroupRow:row]) {
            
            if ([objectValue isKindOfClass:UXCategory.class]) {
                UXCategory *category = (UXCategory *) objectValue;
                
                NSTableCellView *tableCellView = [tableView makeViewWithIdentifier:CategoryCellReuseIdentifier
                                                                             owner:self];
                tableCellView.textField.stringValue = category.name.uppercaseString;
                
                return tableCellView;
            } else if ([objectValue isKindOfClass:UXSubCategory.class]) {
                UXSubCategory *subcategory = (UXSubCategory *) objectValue;
                
                NSTableCellView *tableCellView = [tableView makeViewWithIdentifier:SubCategoryCellReuseIdentifier
                                                                             owner:self];
                tableCellView.textField.stringValue = subcategory.name.uppercaseString;
                
                return tableCellView;
            }
        }
        
        if (tableColumn == self.configOptionsTableColumn) {
                
            UXConfigOptionTableCellView *tableCellView = [tableView makeViewWithIdentifier:ConfigOptionCellReuseIdentifier
                                                                                            owner:self];
            
            UXPersistentConfigOption *configOption = objectValue;
            
            tableCellView.textField.stringValue = configOption.option.displayName;
            tableCellView.toolTip = configOption.option.code;
            
            return tableCellView;
        }
    }
    
    return nil;
}

- (BOOL)tableView:(NSTableView *)tableView isGroupRow:(NSInteger)row {
    return (tableView == self.configOptionsTableView
            && ([self.sortedConfigOptionsAndCategories[row] isKindOfClass:UXCategory.class]
                || [self.sortedConfigOptionsAndCategories[row] isKindOfClass:UXSubCategory.class]));
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    return ![self tableView:tableView isGroupRow:row];
}

#pragma mark - NSSplitViewDelegate

- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)subview {
    if (splitView == self.mainSplitView && subview == self.sourceContainerView) {
        // keep options list fixed width on view resize
        return NO;
    }
    return YES;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)dividerIndex {
    if (splitView == self.mainSplitView && dividerIndex == 0) {
        proposedMin = SourceViewMinWidth;
    }
    return proposedMin;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)dividerIndex {
    if (splitView == self.mainSplitView && dividerIndex == 0) {
        proposedMax = SourceViewMaxWidth;
    }
    return proposedMax;
}

#pragma mark - NSToolbarItemValidation

- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem {
    if (theItem == self.exportToolbarItem) {
        NSLog(@"%d", self.configOptions.count);
        return (self.configOptions.count > 0);
    } else if (theItem == self.runToolbarItem) {
        return (self.configOptions.count > 0
                && (self.filePaths.count > 0 || self.codeTextView.string.length > 0));
    }
    return YES;
}

#pragma mark - NSToolbarDelegate

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
    if ([itemIdentifier isEqualToString:kSidebarSpaceToolbarItemIdentifier]) {
        _spaceItem = [[NSToolbarItem alloc] initWithItemIdentifier:kSidebarSpaceToolbarItemIdentifier];
        _spaceItem.view = self.spaceView;
        return _spaceItem;
    }
    return nil;
}

#pragma mark - UXConfigOptionTableViewDelegate

- (void)tableView:(UXConfigOptionTableView *)tableView didUpdateFrame:(NSSize)newSize {
    self.spaceItem.minSize = self.spaceItem.maxSize = NSMakeSize(newSize.width - 147.0f, 32.0f);
}

#pragma mark - NSTextViewDelegate

- (void)textDidChange:(NSNotification *)notification {
    if (notification.object == self.codeTextView) {
        //TODO
//        [self.syntaxColoringController recolorCompleteFile:self];
    }
}

#pragma mark - NSControl Delegate

- (void)controlTextDidChange:(NSNotification *)aNotification {
    id sender = aNotification.object;
    if (sender == self.searchField) {
        NSSearchField *searchField = (NSSearchField *)sender;
        
        NSString *query = searchField.stringValue;
        self.searchQuery = (query.length) ? query : nil;
        
        [self sortConfigOptions];
    }
}

#pragma mark - NSWindowDelegate

- (void)window:(NSWindow *)window willEncodeRestorableState:(NSCoder *)state {
    [state encodeObject:self.toolbar.selectedItemIdentifier forKey:kSelectedToolbarItemIdentifierKey];
    [state encodeBool:self.documentationPanelController.window.isVisible forKey:kDocumentationPanelVisibleKey];
    [state encodeObject:self.selectedLanguage.code forKey:kSelectedLanguageCodeKey];
    [state encodeFloat:self.sourceContainerView.frame.size.width forKey:kSourceContainerViewWidthKey];
}

- (void)window:(NSWindow *)window didDecodeRestorableState:(NSCoder *)state {
    NSString *selectedToolbarItemIdentifer = [state decodeObjectForKey:kSelectedToolbarItemIdentifierKey];
    
    if (selectedToolbarItemIdentifer) {
        
        /* find toolbar item with identifier */
        for (NSToolbarItem *item in self.toolbar.items) {
            if ([item.itemIdentifier isEqualToString:selectedToolbarItemIdentifer]) {
                
                self.toolbar.selectedItemIdentifier = selectedToolbarItemIdentifer;
                [self showView:item];
                
                break;
            }
        }
    }
    
    NSString *selectedLanguageCode = [state decodeObjectForKey:kSelectedLanguageCodeKey];
    if (selectedLanguageCode) {
        self.selectedLanguage = [UXLanguage findFirstByAttribute:UXLanguageAttributes.code
                                                       withValue:selectedLanguageCode];
    }
    
    CGFloat sourceWidth = [state decodeFloatForKey:kSourceContainerViewWidthKey];
    if (sourceWidth >= SourceViewMinWidth && sourceWidth <= SourceViewMaxWidth) {
        self.sourceContainerView.frame = NSMakeRect(self.sourceContainerView.frame.origin.x,
                                                    self.sourceContainerView.frame.origin.y,
                                                    sourceWidth,
                                                    self.sourceContainerView.frame.size.height);
    }
    
    self.documentationPanelController.window.isVisible = [state decodeBoolForKey:kDocumentationPanelVisibleKey];
}

- (void)windowWillClose:(NSNotification *)notification {
    [NSApplication.sharedApplication terminate:self];
}

#pragma mark - NSWindowRestoration

+ (void)restoreWindowWithIdentifier:(NSString *)identifier state:(NSCoder *)state completionHandler:(void (^)(NSWindow *, NSError *))completionHandler {
    
    if ([identifier isEqualToString:kDocumentationPanelIdentifier]) {
        UXAppDelegate *appDelegate = (UXAppDelegate *)NSApplication.sharedApplication.delegate;
        NSWindow *documentationPanel = appDelegate.mainWindowController.documentationPanelController.window;
        
        completionHandler(documentationPanel, nil);
    }
}

@end
