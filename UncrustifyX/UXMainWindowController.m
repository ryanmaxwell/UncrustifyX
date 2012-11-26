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
#import "UXConfigOption.h"
#import "UXConfigOptionTableCellView.h"
#import "UXConfigOptionTableView.h"
#import "UXExportPanelAccessoryView.h"

@interface UXMainWindowController () <UKSyntaxColoredTextViewDelegate, NSTableViewDelegate, NSTableViewDataSource, NSSplitViewDelegate, UXConfigOptionTableViewDelegate, NSTextViewDelegate>
@property (strong, nonatomic) NSMutableArray *configOptions;
@property (strong, nonatomic) NSMutableArray *sortedConfigOptionsAndCategories;
@property (strong, nonatomic) NSMutableArray *filePaths;

@property (strong, nonatomic) NSView *spaceView;
@property (strong, nonatomic) NSToolbarItem *spaceItem;

@end

@implementation UXMainWindowController

- (id)initWithWindowNibName:(NSString *)windowNibName {
    self = [super initWithWindowNibName:windowNibName];
    if (self) {
        _documentationPanelController = [[UXDocumentationPanelController alloc] initWithWindowNibName:@"UXDocumentationPanelController"];
        _documentationPanelController.window.isVisible = UXDefaultsManager.documentationPanelVisible;
        
        _configOptions = [[NSMutableArray alloc] init];
        _sortedConfigOptionsAndCategories = [[NSMutableArray alloc] init];
        _filePaths = [[NSMutableArray alloc] init];
        
        _inputLanguageArrayController = [[NSArrayController alloc] init];
        _inputLanguageArrayController.sortDescriptors = @[
        [NSSortDescriptor sortDescriptorWithKey:@"name"
                                      ascending:YES
                                       selector:@selector(localizedStandardCompare:)]
        ];
        _inputLanguageArrayController.managedObjectContext = NSManagedObjectContext.defaultContext;
        _inputLanguageArrayController.entityName = UXLanguage.entityName;
    }
    return self;
}

- (void)awakeFromNib {
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
    
    if (!self.toolbar.selectedItemIdentifier) {
        self.toolbar.selectedItemIdentifier = @"UXFileInput";
        
        self.fileInputView.frame = self.containerView.bounds;
        [self.containerView addSubview:self.fileInputView];
    }
    
    if (!_spaceView) {
        _spaceView = [[NSView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        [self.toolbar insertItemWithItemIdentifier:@"UXSidebarSpace" atIndex:2];
    }
    
    [self.inputLanguageArrayController fetch:nil];
    
    [self.window makeKeyAndOrderFront:self];
}

#pragma mark - 

- (UXConfigOption *)configOptionWithCode:(NSString *)code {
    for (UXConfigOption *configOption in self.configOptions) {
        if ([configOption.option.code isEqualToString:code]) {
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
            optionCode = [lineOptions[0] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
            NSLog(@"Code: '%@'", optionCode);
        }
        
        if (lineOptions.count > 1) {
            optionValue = [lineOptions[1] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
            NSLog(@"Value: '%@'", optionValue);
        }
        [self addConfigOptionWithCode:optionCode value:optionValue];
    }
}

- (void)addConfigOptionWithCode:(NSString *)code value:(NSString *)value {
    if (![self configOptionWithCode:code]) {
        UXOption *theOption = [UXOption findFirstByAttribute:UXOptionAttributes.code withValue:code];
        if (theOption) {
            UXConfigOption *newConfigOption = [[UXConfigOption alloc] init];
            newConfigOption.option = theOption;
            newConfigOption.value = value;
            
            [self.configOptions addObject:newConfigOption];
        } else {
            DLog(@"COULD NOT FIND OPTION WITH %@ code", code);
        }
    } else {
        DLog(@"ALREADY HAVE CONFIG OPTION WITH %@ code", code);
    }
}

- (void)sortConfigOptions {
    [self.sortedConfigOptionsAndCategories removeAllObjects];
    
    NSSortDescriptor *nameSort = [NSSortDescriptor sortDescriptorWithKey:@"option.name"
                                                               ascending:YES];
    
    NSArray *sortedCategories = [UXCategory findAllSortedBy:UXAbstractCategoryAttributes.name
                                                  ascending:YES];
    
    NSMutableArray *optionsInCategory = NSMutableArray.array;
    
    /* Categories and their config options */
    for (UXCategory *category in sortedCategories) {
        
        NSPredicate *subCategoriesFilter = [NSPredicate predicateWithFormat:@"%@ IN %K",
                                            category,
                                            UXSubCategoryRelationships.parentCategories];
        
        NSArray *filteredSubCategories = [UXSubCategory findAllSortedBy:UXAbstractCategoryAttributes.name
                                                              ascending:YES
                                                          withPredicate:subCategoriesFilter];
        
        NSMutableArray *optionsInSubCategories = NSMutableArray.array;
        
        for (UXSubCategory *subCategory in filteredSubCategories) {
            
            NSPredicate *categoryFilter = [NSPredicate predicateWithFormat:@"option.category == %@ && option.subCategory == %@",
                                           category,
                                           subCategory];
            
            NSArray *filteredOptions = [[self.configOptions filteredArrayUsingPredicate:categoryFilter]
                                        sortedArrayUsingDescriptors:@[nameSort]];
            
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

#pragma mark - IBAction

- (IBAction)showFileList:(id)sender {
    if (!self.fileInputView.superview) {
        [self.directInputView removeFromSuperview];
        
        self.fileInputView.frame = self.containerView.bounds;
        [self.containerView addSubview:self.fileInputView];
    }
}

- (IBAction)showDirectInput:(id)sender {
    if (!self.directInputView.superview) {
        [self.fileInputView removeFromSuperview];
        
        self.directInputView.frame = self.containerView.bounds;
        [self.containerView addSubview:self.directInputView];
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
        
        UXLanguage *selectedLangauge = self.inputLanguagesPopUpButton.selectedItem.representedObject;
        
        NSString *result = [UXTaskRunner uncrustifyCodeFragment:self.codeTextView.string
                                              withConfigOptions:self.configOptions
                                                      arguments:@[@"-l", selectedLangauge.code]];
        if (result) {
            self.codeTextView.string = result;
            [self.syntaxColoringController recolorCompleteFile:self];
        }
    }
}

- (IBAction)showDocumentationPanel:(id)sender {
    self.documentationPanelController.window.isVisible = 
    UXDefaultsManager.documentationPanelVisible = !self.documentationPanelController.window.isVisible;
}

- (IBAction)exportConfiguration:(id)sender {
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

- (IBAction)importConfiguration:(id)sender {
    NSOpenPanel *openPanel = NSOpenPanel.openPanel;
    openPanel.allowedFileTypes = @[@"cfg"];
    
    [openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            NSError *error = nil;
            NSString *contents = [NSString stringWithContentsOfURL:openPanel.URL
                                                          encoding:NSUTF8StringEncoding
                                                             error:&error];
            
            [self.configOptions removeAllObjects];
            
            NSArray *lines = [contents componentsSeparatedByString:@"\n"];
            
            for (NSString *line in lines) {
                [self parseConfigLine:line];
            }
            
            [self sortConfigOptions];
        }
    }];
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
    [self.filesTableView reloadData];
}

#pragma mark - UKSyntaxColoredTextViewDelegate

- (void)textViewControllerWillStartSyntaxRecoloring:(UKSyntaxColoredTextViewController *)sender {
    DLog(@"Starting Syntax Coloring");
}

- (void)textViewControllerDidFinishSyntaxRecoloring:(UKSyntaxColoredTextViewController *)sender {
    DLog(@"Done Syntax Coloring");
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
            
            UXConfigOption *configOption = (UXConfigOption *) objectValue;
            
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
    if (splitView == self.mainSplitView && subview == self.configOptionsScrollView) {
        // keep options list fixed width on view resize
        return NO;
    }
    return YES;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)dividerIndex {
    if (splitView == self.mainSplitView && dividerIndex == 0) {
        proposedMin = 200.0f;
    }
    return proposedMin;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)dividerIndex {
    if (splitView == self.mainSplitView && dividerIndex == 0) {
        proposedMax = 450.0f;
    }
    return proposedMax;
}

#pragma mark - NSToolbarItemValidation

- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem {
    if (theItem == self.exportToolbarItem) {
        return (self.configOptions.count > 0);
    } else if (theItem == self.runToolbarItem) {
        return (self.configOptions.count > 0
                && (self.filePaths.count > 0 || self.codeTextView.string.length > 0));
    }
    return YES;
}

#pragma mark - NSToolbarDelegate

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
    if ([itemIdentifier isEqualToString:@"UXSidebarSpace"]) {
        _spaceItem = [[NSToolbarItem alloc] initWithItemIdentifier:@"UXSidebarSpace"];
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

@end
