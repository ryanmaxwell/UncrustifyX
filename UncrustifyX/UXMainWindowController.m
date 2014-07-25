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
#import "UXOption.h"
#import "UXValueType.h"
#import "UXSubcategory.h"
#import "UXLanguage.h"
#import "UXPersistentConfigOption.h"
#import "UXConfigOptionTableCellView.h"
#import "UXConfigOptionTableView.h"
#import "UXExportPanelAccessoryView.h"

#import <MGSFragaria/MGSFragaria.h>
#import <MGSFragaria/MGSSyntaxController.h>

static NSString *const FilePathObjectPathKey                = @"path";
static NSString *const FilePathObjectTypeKey                = @"type";

/* NSWindowRestoration keys */
static NSString *const UXSourceContainerViewWidthKey        = @"SourceContainerViewWidth";
static NSString *const UXDocumentationPanelVisibleKey       = @"DocumentationPanelVisible";
static NSString *const UXSelectedToolbarItemIdentifierKey   = @"SelectedToolbarItemIdentifier";
static NSString *const UXDirectInputStringKey               = @"DirectInputString";
static NSString *const UXFilePathsKey                       = @"FilePaths";

static NSString *const UXDocumentationPanelIdentifier       = @"DocumentationPanel";
static NSString *const UXConsolePanelIdentifier             = @"Console";
static NSString *const UXSidebarSpaceToolbarItemIdentifier  = @"UXSidebarSpace";

static const CGFloat SourceViewMinWidth = 200.0f;
static const CGFloat SourceViewMaxWidth = 450.0f;

@interface UXMainWindowController () <NSTableViewDelegate, NSTableViewDataSource, NSSplitViewDelegate, UXConfigOptionTableViewDelegate, NSTextViewDelegate, NSWindowRestoration> {
    BOOL _initialize;
}
@property (strong, nonatomic) NSArray *sortedCategories;

@property (strong, nonatomic) NSMutableArray *sortedConfigOptionsAndCategories;

@property (strong, nonatomic) NSView *spaceView;
@property (strong, nonatomic) NSToolbarItem *spaceItem;

@property (strong, nonatomic) NSString *searchQuery;

@property (strong, nonatomic) MGSFragaria *fragaria;

@end

@implementation UXMainWindowController

- (id)initWithWindowNibName:(NSString *)windowNibName {
    self = [super initWithWindowNibName:windowNibName];

    if (self) {
        _documentationPanelController = [[UXDocumentationPanelController alloc] initWithWindowNibName:@"UXDocumentationPanelController"];
        _documentationPanelController.window.restorationClass = self.class;
        _documentationPanelController.window.identifier = UXDocumentationPanelIdentifier;
        
        UXCONSOLE.window.restorationClass = self.class;
        UXCONSOLE.window.identifier = UXConsolePanelIdentifier;

        _sortedConfigOptionsAndCategories = [[NSMutableArray alloc] init];

        _sortedCategories = [UXCategory MR_findAllSortedBy:UXAbstractCategoryAttributes.name
                                                 ascending:YES];

        _configOptions = [[NSMutableArray alloc] initWithArray:[UXPersistentConfigOption MR_findAll]];
        [self sortConfigOptions];

        _inputLanguageArrayController = [[NSArrayController alloc] init];
        _inputLanguageArrayController.sortDescriptors = @[
            [NSSortDescriptor sortDescriptorWithKey:UXLanguageAttributes.name
                                          ascending:YES]
        ];
        _inputLanguageArrayController.managedObjectContext = [NSManagedObjectContext MR_defaultContext];
        _inputLanguageArrayController.entityName = UXLanguage.entityName;
        
        _filePathsArrayController = [[NSArrayController alloc] init];

        _fragaria = [[MGSFragaria alloc] init];

        _initialize = YES;
    }

    return self;
}

- (void)awakeFromNib {
    /* awakeFromNib annoyingly called each time a table view cell view is created */
    @synchronized(self) {
        if (_initialize) {
            _initialize = NO;

            [self.filePathsTableView registerForDraggedTypes:@[
                 NSURLPboardType
            ]];

            [self.configOptionsTableView registerForDraggedTypes:@[
                 NSPasteboardTypeString
            ]];

            [self showFileInputView];

            _spaceView = [[NSView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
            [self.toolbar insertItemWithItemIdentifier:UXSidebarSpaceToolbarItemIdentifier
                                               atIndex:2];

            [self.inputLanguageArrayController fetch:nil];

            [self.fragaria embedInView:self.fragariaContainerView];

            NSString *selectedLanguageCode = UXDEFAULTS.selectedPreviewLanguageInMainWindow;
            UXLanguage *selectedLanguage = [UXLanguage MR_findFirstByAttribute:UXLanguageAttributes.code
                                                                     withValue:selectedLanguageCode];

            if (selectedLanguage) {
                self.selectedPreviewLanguage = selectedLanguage;

                [self.fragaria setObject:selectedLanguage.name
                                  forKey:MGSFOSyntaxDefinitionName];
            }

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

- (BOOL)parseConfigLine:(NSString *)line error:(NSError **)error {
    NSString *lineValue = nil;
    NSScanner *lineScanner = [NSScanner scannerWithString:line];

    [lineScanner scanUpToString:@"#"
                     intoString:&lineValue];

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

        NSError *inError = nil;
        [self addConfigOptionWithCode:optionCode
                                value:optionValue
                                error:&inError];

        if (inError) {
            *error = inError;
            return YES;
        }
    }

    return NO;
}

- (BOOL)addConfigOptionWithCode:(NSString *)code value:(NSString *)value error:(NSError **)error {
    BOOL errorOccurred = NO;

    if (![self configOptionWithCode:code]) {
        UXOption *theOption = [UXOption MR_findFirstByAttribute:UXOptionAttributes.code
                                                      withValue:code];

        if (theOption) {
            UXPersistentConfigOption *newConfigOption = [UXPersistentConfigOption MR_createEntity];
            newConfigOption.option = theOption;

            if (value.length) {
                NSString *valueToSet = nil;

                if ([theOption.valueType isValidValue:value]) {
                    valueToSet = value;
                } else {
                    /* value may be the code of a previously parsed option */
                    UXPersistentConfigOption *previousConfigOption = [self configOptionWithCode:value];

                    if (previousConfigOption != nil) {
                        valueToSet = previousConfigOption.value;
                    }
                }

                if (valueToSet != nil) {
                    if ([theOption.valueType.type caseInsensitiveCompare:@"Boolean"] == NSOrderedSame) {
                        /* sanitize boolean input */
                        newConfigOption.value = [UXValueType booleanStringForBooleanValue:valueToSet];
                    } else {
                        newConfigOption.value = valueToSet;
                    }
                } else {
                    if (error) {
                        NSString *errorDescription = [NSString stringWithFormat:@"The value '%@' is not valid for the %@ value type required for the %@ option",
                                                      value,
                                                      theOption.valueType.type.lowercaseString,
                                                      theOption.code];

                        *error = [NSError errorWithDomain:UXErrorDomain
                                                     code:0
                                                 userInfo:@{ NSLocalizedDescriptionKey: errorDescription }];
                    }

                    errorOccurred = YES;
                }
            }

            [self.configOptions addObject:newConfigOption];
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];
        } else {
            if (error) {
                NSString *errorDescription = [NSString stringWithFormat:@"Could not find option with %@ code", code];

                *error = [NSError errorWithDomain:UXErrorDomain
                                             code:0
                                         userInfo:@{ NSLocalizedDescriptionKey: errorDescription }];
            }

            errorOccurred = YES;
        }
    } else {
        if (error) {
            NSString *errorDescription = [NSString stringWithFormat:@"Already have config option with %@ code", code];

            *error = [NSError errorWithDomain:UXErrorDomain
                                         code:0
                                     userInfo:@{ NSLocalizedDescriptionKey: errorDescription }];
        }

        errorOccurred = YES;
    }

    return errorOccurred;
}

- (void)sortConfigOptions {
    NSArray *result = [UXConfigOptionSharedImplementation categorizedConfigOptionsFromConfigOptions:self.configOptions
                                                                                        searchQuery:self.searchQuery];

    [self.sortedConfigOptionsAndCategories removeAllObjects];
    [self.sortedConfigOptionsAndCategories addObjectsFromArray:result];
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

- (void)setSelectedPreviewLanguage:(UXLanguage *)selectedPreviewLanguage {
    if (selectedPreviewLanguage != _selectedPreviewLanguage) {
        _selectedPreviewLanguage = selectedPreviewLanguage;
        UXDEFAULTS.selectedPreviewLanguageInMainWindow = selectedPreviewLanguage.code;
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
        && [self.filePathsArrayController.arrangedObjects count] > 0) {
        NSArray *args = nil;

        if (UXDEFAULTS.overwriteFiles) {
            args = @[@"--no-backup"];
        }
        
        NSArray *paths = [self.filePathsArrayController.arrangedObjects valueForKey:FilePathObjectPathKey];

        [UXTaskRunner uncrustifyFilesAtPaths:paths
                           withConfigOptions:self.configOptions
                                   arguments:args];
    } else if ([self.toolbar.selectedItemIdentifier isEqualToString:self.directInputToolbarItem.itemIdentifier]
               && self.fragaria.string.length > 0) {
        NSString *result = [UXTaskRunner uncrustifyCodeFragment:self.fragaria.string
                                              withConfigOptions:self.configOptions
                                                      arguments:@[@"-l", self.selectedPreviewLanguage.code]];

        if (result) {
            self.fragaria.string = result;
        }
    }
}

- (IBAction)toggleDocumentationPanel:(id)sender {
    self.documentationPanelController.window.isVisible = !self.documentationPanelController.window.isVisible;
    
    [UXAPPDELEGATE updateDocumentationMenuItem:nil];
}

- (IBAction)toggleConsole:(id)sender {
    UXCONSOLE.window.isVisible = !UXCONSOLE.window.isVisible;
    
    [UXAPPDELEGATE updateConsoleMenuItem:nil];
}

- (IBAction)addFilesPressed:(id)sender {
    NSOpenPanel *openPanel = NSOpenPanel.openPanel;
    openPanel.allowsMultipleSelection = YES;
    openPanel.allowedFileTypes = UXLanguage.allFileExtensions;

    [openPanel beginSheetModalForWindow:self.window
                      completionHandler:^(NSInteger result) {
                          if (result == NSFileHandlingPanelOKButton) {
                              NSMutableArray *filePaths = NSMutableArray.array;
                              
                              for (NSURL *url in openPanel.URLs) {
                                  [filePaths addObject:url.path];
                              }
                                  
                              [self addFilePaths:filePaths];
                          }
                      }];
}

- (IBAction)removeItems:(id)sender {
    
    if (self.window.firstResponder == self.filePathsTableView) {
        
        NSUInteger clickedRow = self.filePathsTableView.clickedRow;
        NSUInteger selectedRow = self.filePathsTableView.selectedRow;
        
        if (clickedRow == -1 && selectedRow == -1) return;
        
        NSIndexSet *selectedRows = self.filePathsTableView.selectedRowIndexes;
        
        if ((clickedRow != -1 && selectedRows.count > 0 && [selectedRows containsIndex:clickedRow])
            || (clickedRow == -1 && selectedRows.count > 0)) {
            /* selected rows and clicked on one of them, or not clicked on row and just selected some rows */
            [self.filePathsArrayController removeObjects:self.filePathsArrayController.selectedObjects];
        } else if (clickedRow != -1) {
            /* remove the single row clicked */
            [self.filePathsArrayController removeObjectAtArrangedObjectIndex:clickedRow];
        }
        
    } else if (self.window.firstResponder == self.configOptionsTableView) {
        
        NSUInteger clickedRow = self.configOptionsTableView.clickedRow;
        NSUInteger selectedRow = self.configOptionsTableView.selectedRow;
        
        if (clickedRow == -1 && selectedRow == -1) return;
        
        NSIndexSet *selectedRows = self.configOptionsTableView.selectedRowIndexes;
        NSMutableArray *objectsToRemove = NSMutableArray.array;
        
        if ((clickedRow != -1 && selectedRows.count > 0 && [selectedRows containsIndex:clickedRow])
            || (clickedRow == -1 && selectedRows.count > 0)) {
            /* selected rows and clicked on one of them, or not clicked on row and just selected some rows */
            
            [selectedRows enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
                [objectsToRemove addObject:self.sortedConfigOptionsAndCategories[index]];
            }];
        } else if (clickedRow != -1) {
            /* remove the single row clicked */
            [objectsToRemove addObject:self.sortedConfigOptionsAndCategories[clickedRow]];
        }
        
        if (objectsToRemove.count > 0) {
            [self.configOptions removeObjectsInArray:objectsToRemove];
            
            for (NSManagedObject *mo in objectsToRemove) {
                [[NSManagedObjectContext MR_defaultContext] deleteObject:mo];
            }
            
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];
            
            [self sortConfigOptions];
            
            /* Validate immediately as system only does it periodically */
            [self.toolbar validateVisibleItems];
        }
    }
}

- (IBAction)revealInFinderPressed:(id)sender {
    NSInteger selectedRow = self.filePathsTableView.selectedRow;
    NSInteger clickedRow = self.filePathsTableView.clickedRow;
    
    NSInteger rowToAction = NSNotFound;
    
    if (clickedRow != -1) {
        rowToAction = clickedRow;
    } else if (selectedRow != -1) {
        rowToAction = selectedRow;
    }
    
    if (rowToAction != NSNotFound) {
        NSDictionary *filePathDict = self.filePathsArrayController.arrangedObjects[rowToAction];
        NSString *path = filePathDict[FilePathObjectPathKey];
        
        [NSWorkspace.sharedWorkspace selectFile:path
                       inFileViewerRootedAtPath:@""];
    }
}

- (IBAction)showDocumentationPressed:(id)sender {
    NSUInteger selectedRow = self.configOptionsTableView.selectedRow;
    NSUInteger clickedRow = self.configOptionsTableView.clickedRow;
    
    NSInteger rowToAction = NSNotFound;
    
    if (clickedRow != -1 && ![self tableView:self.configOptionsTableView isGroupRow:clickedRow]) {
        rowToAction = clickedRow;
    } else if (selectedRow != -1 && ![self tableView:self.configOptionsTableView isGroupRow:selectedRow]) {
        rowToAction = selectedRow;
    }
    
    if (rowToAction != NSNotFound) {
        id<UXConfigOption> configOption = self.sortedConfigOptionsAndCategories[rowToAction];
        
        [self.documentationPanelController showInfoForOption:configOption.option];
    }
}

- (IBAction)exportConfigurationPressed:(id)sender {
    NSSavePanel *savePanel = NSSavePanel.savePanel;

    /* user can save without extension, e.g. to ~/.uncrustifyconfig */
    //savePanel.allowedFileTypes = @[@"cfg"];
    savePanel.allowsOtherFileTypes = YES;
    savePanel.nameFieldStringValue = @"untitled.cfg";
    savePanel.extensionHidden = NO;
    savePanel.accessoryView = self.exportPanelAccessoryView;

    NSURL *fileURL = [UXDefaultsManager sharedDefaultsManager].lastConfigURL;
    if (fileURL && [[NSFileManager defaultManager] fileExistsAtPath:fileURL.path]) {
        savePanel.nameFieldStringValue = fileURL.lastPathComponent;
        savePanel.directoryURL = [fileURL URLByDeletingLastPathComponent];
    }

    [savePanel beginSheetModalForWindow:self.window
                      completionHandler:^(NSInteger result) {
                          if (result == NSFileHandlingPanelOKButton) {
                              BOOL documentationForCategory = NO, documentationForSubcategory = NO, documentationForOptionName = NO, documentationForOptionValue = NO;

                              if (self.exportPanelAccessoryView.includeDocumentationCheckbox.state == NSOnState) {
                                  documentationForCategory = (self.exportPanelAccessoryView.categoriesCheckbox.state == NSOnState);
                                  documentationForSubcategory = (self.exportPanelAccessoryView.subcategoriesCheckbox.state == NSOnState);
                                  documentationForOptionName = (self.exportPanelAccessoryView.optionNameCheckbox.state == NSOnState);
                                  documentationForOptionValue = (self.exportPanelAccessoryView.optionValueCheckbox.state == NSOnState);
                              }
                              NSURL *url = [savePanel.directoryURL URLByAppendingPathComponent:savePanel.nameFieldStringValue];

                              [UXFileUtils writeConfigOptions:self.configOptions
                                                 toFileAtPath:url.path
                                          includeBlankOptions:(self.exportPanelAccessoryView.includeBlankOptionsCheckbox.state == NSOnState)
                                     documentationForCategory:documentationForCategory
                                                  subcategory:documentationForSubcategory
                                                   optionName:documentationForOptionName
                                                  optionValue:documentationForOptionValue];

                              [UXDefaultsManager sharedDefaultsManager].lastConfigURL = url;
                          }
                      }];
}

- (IBAction)importConfigurationPressed:(id)sender {
    NSOpenPanel *openPanel = NSOpenPanel.openPanel;

//    openPanel.allowedFileTypes = @[@"cfg"];
    openPanel.allowsOtherFileTypes = YES;

    NSURL *fileURL = [UXDefaultsManager sharedDefaultsManager].lastConfigURL;
    if (fileURL && [[NSFileManager defaultManager] fileExistsAtPath:fileURL.path]) {
        openPanel.directoryURL = [fileURL URLByDeletingLastPathComponent];
    }
    
    [openPanel beginSheetModalForWindow:self.window
                      completionHandler:^(NSInteger result) {
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
            [configOption MR_deleteEntity];
        }

        [self.configOptions removeAllObjects];


        NSArray *lines = [contents componentsSeparatedByCharactersInSet:NSCharacterSet.newlineCharacterSet];

        NSMutableArray *errorStrings = NSMutableArray.array;

        for (NSString *line in lines) {
            NSError *parseError = nil;
            [self parseConfigLine:line
                            error:&parseError];

            if (parseError) {
                DLog(@"%@", parseError);
                [errorStrings addObject:parseError.localizedDescription];
            }
        }

        [self sortConfigOptions];
        
        /* save filename for later when re-exporting */
        [UXDefaultsManager sharedDefaultsManager].lastConfigURL = fileURL;

        if (errorStrings.count) {
            NSAlert *errorAlert = [NSAlert alertWithMessageText:@"An error occurred during import"
                                                  defaultButton:@"OK"
                                                alternateButton:nil
                                                    otherButton:nil
                                      informativeTextWithFormat:@"%@", [errorStrings componentsJoinedByString:@"\n\n"]];
            [errorAlert runModal];
        }
    } else {
        DLog(@"%@", error);
    }
}

- (IBAction)previewLanguagePopUpChanged:(id)sender {
    [self.fragaria setObject:self.selectedPreviewLanguage.name
                      forKey:MGSFOSyntaxDefinitionName];
}

- (NSDictionary *)filePathObjectForFilePath:(NSString *)filePath {
    NSString *fileName = [filePath lastPathComponent];
    NSString *fileType = @"";
    
    NSRange dotRange = [fileName rangeOfString:@"."];
    if (dotRange.location != NSNotFound && dotRange.location != fileName.length - 1) {
        NSString *fileExtension = [fileName substringFromIndex:dotRange.location + 1];
        
        NSArray *languages = [UXLanguage languagesWithExtension:fileExtension];
        
        NSArray *languageNames = [languages valueForKeyPath:@"name"];
        
        fileType = [[languageNames sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] componentsJoinedByString:@"/"];
    };
    
    return @{FilePathObjectPathKey: filePath, FilePathObjectTypeKey: fileType};
}

- (void)addFilePaths:(NSArray *)filePaths {
    for (id obj in filePaths) {
        if ([obj isKindOfClass:NSString.class]) {
            
            __block BOOL containsPath = NO;
            
            [self.filePathsArrayController.arrangedObjects enumerateObjectsUsingBlock:^(NSDictionary *filePathObj, NSUInteger index, BOOL *stop){
                
                if ([filePathObj[FilePathObjectPathKey] isEqual:obj]) {
                    containsPath = YES;
                    *stop = YES;
                }
            }];
            
            if (!containsPath) {
                NSDictionary *filePathObj = [self filePathObjectForFilePath:obj];
                [self.filePathsArrayController addObject:filePathObj];
            }
        }
    }

    [self showFileInputView];
}

- (NSString *)directInputText {
    return self.fragaria.string;
}

- (void)setDirectInputText:(NSString *)text {
    self.fragaria.string = text;
}

#pragma mark - Validation for UI Items

- (BOOL)isRunEnabled {
    return self.configOptions.count > 0 && ([self.filePathsArrayController.arrangedObjects count] > 0 || self.fragaria.string.length > 0);
}

- (BOOL)isExportEnabled {
    return self.configOptions.count > 0;
}

- (BOOL)isDocumentationVisible {
    return self.documentationPanelController.window.isVisible;
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if (tableView == self.configOptionsTableView) {
        return self.sortedConfigOptionsAndCategories.count;
    } else if (tableView == self.filePathsTableView) {
//        return self.filePaths.count;
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
    if (tableView == self.filePathsTableView) {
        NSPasteboard *pboard = [info draggingPasteboard];

        if ([pboard.types containsObject:NSFilenamesPboardType]) {
            NSArray *fileList = [pboard propertyListForType:NSFilenamesPboardType];
            [self addFilePaths:fileList];
        }

        return YES;
    } else if (tableView == self.configOptionsTableView) {
        NSPasteboard *pboard = [info draggingPasteboard];

        NSArray *stringItems = [pboard readObjectsForClasses:@[NSString.class]
                                                     options:nil];

        NSMutableArray *errorStrings = NSMutableArray.array;

        for (NSString *optionLine in stringItems) {
            DLog(@"%@", optionLine);
            NSError *parseError = nil;
            [self parseConfigLine:optionLine
                            error:&parseError];

            if (parseError) {
                DLog(@"%@", parseError);
                [errorStrings addObject:parseError.localizedDescription];
            }
        }

        if (errorStrings.count) {
            NSAlert *errorAlert = [NSAlert alertWithMessageText:@"An error occurred during import"
                                                  defaultButton:@"OK"
                                                alternateButton:nil
                                                    otherButton:nil
                                      informativeTextWithFormat:@"%@", [errorStrings componentsJoinedByString:@"\n\n"]];
            [errorAlert runModal];
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
    }

    return nil;
}

#pragma mark - NSTableViewDelegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (tableView == self.configOptionsTableView) {
        id objectValue = self.sortedConfigOptionsAndCategories[row];

        if ([self tableView:tableView isGroupRow:row]) {
            if ([objectValue isKindOfClass:UXCategory.class]) {
                UXCategory *category = (UXCategory *)objectValue;

                NSTableCellView *tableCellView = [tableView makeViewWithIdentifier:CategoryCellReuseIdentifier
                                                                             owner:self];
                tableCellView.textField.stringValue = category.name.uppercaseString;

                return tableCellView;
            } else if ([objectValue isKindOfClass:UXSubcategory.class]) {
                UXSubcategory *subcategory = (UXSubcategory *)objectValue;

                NSTableCellView *tableCellView = [tableView makeViewWithIdentifier:SubcategoryCellReuseIdentifier
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
    return tableView == self.configOptionsTableView
           && ([self.sortedConfigOptionsAndCategories[row] isKindOfClass:UXCategory.class]
               || [self.sortedConfigOptionsAndCategories[row] isKindOfClass:UXSubcategory.class]);
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    return ![self tableView:tableView
                 isGroupRow:row];
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
        return self.isExportEnabled;
    } else if (theItem == self.runToolbarItem) {
        return self.isRunEnabled;
    }

    return YES;
}

#pragma mark - NSToolbarDelegate

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
    if ([itemIdentifier isEqualToString:UXSidebarSpaceToolbarItemIdentifier]) {
        _spaceItem = [[NSToolbarItem alloc] initWithItemIdentifier:UXSidebarSpaceToolbarItemIdentifier];
        _spaceItem.view = self.spaceView;
        return _spaceItem;
    }

    return nil;
}

#pragma mark - UXConfigOptionTableViewDelegate

- (void)tableView:(UXConfigOptionTableView *)tableView didUpdateFrame:(NSSize)newSize {
    self.spaceItem.minSize = self.spaceItem.maxSize = NSMakeSize(newSize.width - 147.0f, 32.0f);
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
    [state encodeObject:self.toolbar.selectedItemIdentifier
                 forKey:UXSelectedToolbarItemIdentifierKey];
    [state encodeBool:self.documentationPanelController.window.isVisible
               forKey:UXDocumentationPanelVisibleKey];
    [state encodeFloat:self.sourceContainerView.frame.size.width
                forKey:UXSourceContainerViewWidthKey];
    [state encodeObject:self.fragaria.string
                 forKey:UXDirectInputStringKey];
    [state encodeObject:self.filePathsArrayController.arrangedObjects
                 forKey:UXFilePathsKey];
}

- (void)window:(NSWindow *)window didDecodeRestorableState:(NSCoder *)state {
    NSString *selectedToolbarItemIdentifer = [state decodeObjectForKey:UXSelectedToolbarItemIdentifierKey];

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

    CGFloat sourceWidth = [state decodeFloatForKey:UXSourceContainerViewWidthKey];

    if (sourceWidth >= SourceViewMinWidth && sourceWidth <= SourceViewMaxWidth) {
        self.sourceContainerView.frame = NSMakeRect(self.sourceContainerView.frame.origin.x,
                                                    self.sourceContainerView.frame.origin.y,
                                                    sourceWidth,
                                                    self.sourceContainerView.frame.size.height);
    }

    self.documentationPanelController.window.isVisible = [state decodeBoolForKey:UXDocumentationPanelVisibleKey];

    NSString *savedText = [state decodeObjectForKey:UXDirectInputStringKey];

    if (savedText.length) {
        self.fragaria.string = savedText;
    }

    NSArray *filePaths = [state decodeObjectForKey:UXFilePathsKey];

    if (filePaths.count) {
        for (id filePath in filePaths) {
            if ([filePath isKindOfClass:NSString.class]) {
                /* old versions saved array of strings */
                NSDictionary *filePathObj = [self filePathObjectForFilePath:filePath];
                [self.filePathsArrayController addObject:filePathObj];
            } else if ([filePath isKindOfClass:NSDictionary.class]) {
                /* new versions save as array of dictionaries */
                [self.filePathsArrayController addObject:filePath];
            }
        }
    }
}

- (void)windowWillClose:(NSNotification *)notification {
    [NSApplication.sharedApplication terminate:self];
}

#pragma mark - NSWindowRestoration

+ (void)restoreWindowWithIdentifier:(NSString *)identifier state:(NSCoder *)state completionHandler:(void (^)(NSWindow *, NSError *))completionHandler {
    if ([identifier isEqualToString:UXDocumentationPanelIdentifier]) {
        completionHandler(UXAPPDELEGATE.mainWindowController.documentationPanelController.window, nil);
    } else if ([identifier isEqualToString:UXConsolePanelIdentifier]) {
        completionHandler(UXCONSOLE.window, nil);
    }
}

@end
