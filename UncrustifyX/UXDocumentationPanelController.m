//
//  UXDocumentationPanelController.m
//  UncrustifyX
//
//  Created by Ryan Maxwell on 13/10/12.
//  Copyright (c) 2012 Ryan Maxwell. All rights reserved.
//

#import "UXDocumentationPanelController.h"
#import "UXSyntaxColoredTextViewController.h"

#import "UXCategory.h"
#import "UXSubCategory.h"
#import "UXConfigOption.h"
#import "UXOption.h"
#import "UXLanguage.h"
#import "UXPlaceholder.h"
#import "UXValueType.h"
#import "UXValue.h"
#import "UXCodeSample.h"
#import "UXTaskRunner.h"
#import "UXUIUtils.h"

static CGFloat const PreviewViewHeight = 400.0f;

@interface UXDocumentationPanelController () <UKSyntaxColoredTextViewDelegate, NSTableViewDelegate, NSTableViewDataSource, NSTextDelegate, NSSplitViewDelegate>
@property (strong, nonatomic) UXPlaceholder *languagesHeader;
@property (strong, nonatomic) UXPlaceholder *categoriesHeader;
@property (strong, nonatomic) NSString *searchQuery;
@property (assign, nonatomic) BOOL previewExpanded;

@property (strong, nonatomic) NSArray *allOptions;
@property (strong, nonatomic) NSArray *allSubCategories;
@property (strong, nonatomic) NSMutableArray *currentOptionsAndSubCategories;

@property (weak, nonatomic) UXOption *selectedOption;
@end

@implementation UXDocumentationPanelController

- (id)initWithWindowNibName:(NSString *)windowNibName {
    self = [super initWithWindowNibName:windowNibName];
    if (self) {
        _languagesHeader = UXPlaceholder.new;
        _languagesHeader.name = @"Languages";
        
        _categoriesHeader = UXPlaceholder.new;
        _categoriesHeader.name = @"All";
        
        _categoriesArrayController = [[NSArrayController alloc] init];
        _browseLanguagesArrayController = [[NSArrayController alloc] init];
        _previewLanguagesArrayController = [[NSArrayController alloc] init];
        _codeSamplesArrayController = [[NSArrayController alloc] init];
        
        _allOptions = [[NSArray alloc] initWithArray:[UXOption findAll]];
        _allSubCategories = [[NSArray alloc] initWithArray:[UXSubCategory findAll]];
        
        _currentOptionsAndSubCategories = [[NSMutableArray alloc] init];
        
        _previewExpanded = NO;
    }
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)awakeFromNib {
    
    [self.optionsTableView setDraggingSourceOperationMask:NSDragOperationCopy forLocal:NO];
    
    if (UXDefaultsManager.documentationPreviewExpanded) {
        [self setPreviewExpanded:YES animated:NO];
        self.disclosureTriangle.state = NSOnState;
    } else {
        [self setPreviewExpanded:NO animated:NO];
        self.disclosureTriangle = NSOffState;
    }
    
    self.browseLanguagesArrayController.sortDescriptors =
    self.previewLanguagesArrayController.sortDescriptors =
    self.categoriesArrayController.sortDescriptors =
    self.codeSamplesArrayController.sortDescriptors = @[
        [NSSortDescriptor sortDescriptorWithKey:@"displayName"
                                      ascending:YES
                                       selector:@selector(localizedStandardCompare:)]
    ];
    
    self.categoriesArrayController.managedObjectContext =
    self.browseLanguagesArrayController.managedObjectContext =
    self.previewLanguagesArrayController.managedObjectContext =
    self.codeSamplesArrayController.managedObjectContext = NSManagedObjectContext.defaultContext;
    
    self.categoriesArrayController.entityName = UXCategory.entityName;
    self.browseLanguagesArrayController.entityName = UXLanguage.entityName;
    self.previewLanguagesArrayController.entityName = UXLanguage.entityName;
    self.codeSamplesArrayController.entityName = UXCodeSample.entityName;
    
    [self.categoriesArrayController addObserver:self
                                    forKeyPath:@"arrangedObjects.@count"
                                       options:NSKeyValueObservingOptionNew
                                       context:NULL];
    
    [self.browseLanguagesArrayController addObserver:self
                                    forKeyPath:@"arrangedObjects.@count"
                                       options:NSKeyValueObservingOptionNew
                                       context:NULL];
    
    [self.categoriesArrayController fetch:nil];
    [self.browseLanguagesArrayController fetch:nil];
    [self.previewLanguagesArrayController fetch:nil];
    [self.codeSamplesArrayController fetch:nil];
    
    [self filterCodeSamplesForLanguage:self.browseLanguagesArrayController.selection];
}

#pragma mark - UKSyntaxColoredTextViewDelegate

#pragma mark - NSTableViewDelegate

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
    NSTableView *sender = (NSTableView *)aNotification.object;
    if (sender == self.categoriesTableView) {
        [self filterOptions];
    } else if (sender == self.optionsTableView) {
        NSUInteger selectedRow = sender.selectedRow;
        if (selectedRow < sender.numberOfRows) {
            self.selectedOption = [self.currentOptionsAndSubCategories objectAtIndex:sender.selectedRow];
        }
    }
}

- (BOOL)tableView:(NSTableView *)tableView isGroupRow:(NSInteger)row {
    return (tableView == self.optionsTableView && [self.currentOptionsAndSubCategories[row] isKindOfClass:UXSubCategory.class]);
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    return ![self tableView:tableView isGroupRow:row];
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if (tableView == self.optionsTableView) {
        return self.currentOptionsAndSubCategories.count;
    }
    return 0;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)rowIndex {
    if (tableView == self.optionsTableView) {
        return [self.currentOptionsAndSubCategories[rowIndex] displayName];
    }
    return nil;
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)rowIndex {
    if (tableView == self.optionsTableView) {
        [self.currentOptionsAndSubCategories[rowIndex] setDisplayName:object];
    }
}

/* Allow dragging options */
- (BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard {
    if (tableView == self.optionsTableView) {
        
        if (rowIndexes.count == 1 && [self tableView:tableView isGroupRow:rowIndexes.firstIndex]) {
            return NO;
        }
        
        [pboard declareTypes:@[NSPasteboardTypeString] owner:self];
        
        NSMutableArray *items = [NSMutableArray array];
        
        [rowIndexes enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop){
            if (![self tableView:tableView isGroupRow:index]) {
                NSPasteboardItem *item = [[NSPasteboardItem alloc] init];
                UXOption *option = self.currentOptionsAndSubCategories[index];
                
                [item setString:option.code forType:NSPasteboardTypeString];
                
                [items addObject:item];
            }
        }];
        
        [pboard writeObjects:items];
        
        return YES;
    }
    
    return NO;
}

#pragma mark - NSControl Delegate

- (void)controlTextDidChange:(NSNotification *)aNotification {
    id sender = aNotification.object;
    if (sender == self.searchField) {
        NSSearchField *searchField = (NSSearchField *)sender;
        
        NSString *query = searchField.stringValue;
        self.searchQuery = (query.length) ? query : nil;
        
        [self filterOptions];
    }
}

#pragma mark - NSSplitViewDelegate

- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)subview {
    if (subview == self.categoriesContainerView) {
        // keep source list fixed width on view resize
        return NO;
    }
    return YES;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)dividerIndex {
    if (dividerIndex == 0) {
        proposedMin = 150.0;
    }
    return proposedMin;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)dividerIndex {
    if (dividerIndex == 0) {
        proposedMax = 350.0;
    }
    return proposedMax;
}

#pragma mark -

- (void)filterCodeSamplesForLanguage:(UXLanguage *)language {
    self.codeSamplesArrayController.filterPredicate = [NSPredicate predicateWithFormat:@"%K == %@",
                                                       UXCodeSampleRelationships.language,
                                                       language];
}

- (void)filterOptions {
    NSSortDescriptor *displayNameSort = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    
    NSArray *sortedSubCategories = nil;
    
    if (self.selectedCategory) {
        NSPredicate *subCategoriesFilter = [NSPredicate predicateWithFormat:@"%@ IN %K",
                                            self.selectedCategory,
                                            UXSubCategoryRelationships.parentCategories];
        
        sortedSubCategories = [[self.allSubCategories filteredArrayUsingPredicate:subCategoriesFilter]
                               sortedArrayUsingDescriptors:@[displayNameSort]];
    } else {
        sortedSubCategories = [self.allSubCategories sortedArrayUsingDescriptors:@[displayNameSort]];
    }
    
    [self.currentOptionsAndSubCategories removeAllObjects];
    
    NSPredicate *searchFilter = self.keywordSearchPredicate;
    
    /* subcategories and their options */
    for (UXSubCategory *subCategory in sortedSubCategories) {
        
        NSPredicate *categoryFilter = nil;
        if (self.selectedCategory) {
            categoryFilter = [NSPredicate predicateWithFormat:@"%K == %@ AND %K == %@",
                             UXOptionRelationships.category,
                             self.selectedCategory,
                             UXOptionRelationships.subCategory,
                             subCategory];
        } else {
            categoryFilter = [NSPredicate predicateWithFormat:@"%K == %@",
                             UXOptionRelationships.subCategory,
                             subCategory];
        }
        
        NSPredicate *optionsFilter = categoryFilter;
        
        if (searchFilter) {
            optionsFilter = [NSCompoundPredicate andPredicateWithSubpredicates:@[
                                categoryFilter,
                                searchFilter
                             ]];
        }
        
        NSArray *filteredOptions = [[self.allOptions filteredArrayUsingPredicate:optionsFilter]
                                    sortedArrayUsingDescriptors:@[displayNameSort]];
        
        if (filteredOptions.count > 0) {
            [self.currentOptionsAndSubCategories addObject:subCategory];
            [self.currentOptionsAndSubCategories addObjectsFromArray:filteredOptions];
        }
    }
    
    /* remaining options without subcategories */
    NSPredicate *categoryFilter = nil;
    if (self.selectedCategory) {
        categoryFilter = [NSPredicate predicateWithFormat:@"%K == %@ AND %K == nil",
                         UXOptionRelationships.category,
                         self.selectedCategory,
                         UXOptionRelationships.subCategory];
    } else {
        categoryFilter = [NSPredicate predicateWithFormat:@"%K == nil",
                         UXOptionRelationships.subCategory];
    }
    
    NSPredicate *optionsFilter = categoryFilter;
    
    if (searchFilter) {
        optionsFilter = [NSCompoundPredicate andPredicateWithSubpredicates:@[
                         categoryFilter,
                         searchFilter
                         ]];
    }
    
    NSArray *filteredOptions = [[self.allOptions filteredArrayUsingPredicate:optionsFilter]
                                sortedArrayUsingDescriptors:@[displayNameSort]];
    
    if (sortedSubCategories.count > 0 && filteredOptions.count > 0) {
        /* show "Other" header */
        [self.currentOptionsAndSubCategories addObject:UXSubCategory.otherSubCategory];
    }
    
    [self.currentOptionsAndSubCategories addObjectsFromArray:filteredOptions];
    
    [self.optionsTableView reloadData];
    
    /* select first option */
    [self.currentOptionsAndSubCategories enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop){
        if ([obj isKindOfClass:UXOption.class]) {
            
            [self.optionsTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:index]
                               byExtendingSelection:NO];
            
            /* fire KVO for bindings */
            self.selectedOption = obj;
            
            *stop = YES;
        }
    }];
}

- (NSPredicate *)keywordSearchPredicate {
    NSMutableArray *appliedPredicates = NSMutableArray.array;
    
    NSArray *selectedLanguages = [UXLanguage findByAttribute:UXLanguageAttributes.includedInDocumentation
                                                   withValue:@YES];
    
    BOOL requiresLanguageFilter = (selectedLanguages.count < UXLanguage.findAll.count);
    
    if (requiresLanguageFilter) {
        NSPredicate *languageFilter = [NSPredicate predicateWithFormat:@"ANY languages IN %@", selectedLanguages];
        [appliedPredicates addObject:languageFilter];
    }
    
    if (self.selectedCategory) {
        NSPredicate *categoryFilter = [NSPredicate predicateWithFormat:@"%K == %@",
                                       UXOptionRelationships.category,
                                       self.selectedCategory];
        [appliedPredicates addObject:categoryFilter];
    }
    
    if (self.searchQuery) {
        NSPredicate *searchFilter = [NSPredicate predicateWithFormat:@"%K CONTAINS[c] %@ OR %K CONTAINS[c] %@ OR %K CONTAINS[c] %@ OR %K CONTAINS[c] %@",
                                     UXOptionAttributes.optionDescription, self.searchQuery,
                                     UXOptionAttributes.code, self.searchQuery,
                                     UXOptionAttributes.name, self.searchQuery,
                                     @"explodedCode", self.searchQuery];
        [appliedPredicates addObject:searchFilter];
    }
    
    return (appliedPredicates.count > 0) ? [NSCompoundPredicate andPredicateWithSubpredicates:appliedPredicates] : nil;
}

- (void)setPreviewExpanded:(BOOL)previewExpanded {
    [self setPreviewExpanded:previewExpanded animated:NO];
}

- (void)setPreviewExpanded:(BOOL)previewExpanded animated:(BOOL)animated {
    if (previewExpanded == _previewExpanded) return;
    
    UXDefaultsManager.documentationPreviewExpanded = _previewExpanded = previewExpanded;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        /* perform window resize async so that disclosure triangle can do flip animation at same time */
        
        CGFloat deltaY = (self.previewExpanded) ? PreviewViewHeight : - PreviewViewHeight;
        
        NSRect oldFrame = self.window.frame;
        NSRect newFrame = NSMakeRect(oldFrame.origin.x, oldFrame.origin.y - deltaY, oldFrame.size.width, oldFrame.size.height + deltaY);
        
        [self.window setFrame:newFrame display:YES animate:animated];
    });
}

#pragma mark - Readonly Getters

- (UXCategory *)selectedCategory {
    if (self.categoriesArrayController.selectedObjects.count == 0) {
        return nil;
    }
    
    id selectedObject = self.categoriesArrayController.selectedObjects[0];
    
    if ([selectedObject isKindOfClass:UXCategory.class]) {
        return selectedObject;
    } else {
        /* All Placeholder */
        return nil;
    }
}

#pragma mark - Setters

- (void)setSelectedOption:(UXOption *)selectedOption {
    if (_selectedOption != selectedOption) {
        [self willChangeValueForKey:@"selectedOption"];
        _selectedOption = selectedOption;
        [self didChangeValueForKey:@"selectedOption"];
        
        [UXUIUtils configureSegmentedControlValues:self.valueSegmentedControl
                                         forOption:selectedOption
                                     selectedValue:nil];
    }
}

#pragma mark - IBAction

- (IBAction)browseLanguagesPopUpChanged:(id)sender {
    NSPopUpButton *senderButton = (NSPopUpButton *)sender;
    UXLanguage *selectedLanguage = senderButton.selectedItem.representedObject;
    selectedLanguage.includedInDocumentationValue = !selectedLanguage.includedInDocumentationValue;
    [self filterOptions];
}

- (IBAction)previewLanguagePopUpChanged:(id)sender {
    NSPopUpButton *senderButton = (NSPopUpButton *)sender;
    UXLanguage *selectedLanguage = senderButton.selectedItem.representedObject;
    [self filterCodeSamplesForLanguage:selectedLanguage];
    
    [self codeSamplePopUpChanged:self.codeSamplePopUpButton];
}

- (IBAction)codeSamplePopUpChanged:(id)sender {
    NSPopUpButton *senderButton = (NSPopUpButton *)sender;
    UXCodeSample *selectedSample = senderButton.selectedItem.representedObject;
    if (selectedSample) {
        self.codePreviewTextView.string = selectedSample.source;
        [self.syntaxColoringController recolorCompleteFile:self];
    } else {
        self.codePreviewTextView.string = @"";
    }
}

- (IBAction)valueSegmentedControlChanged:(id)sender {
    NSSegmentedControl *segmentedControl = (NSSegmentedControl *)sender;
    UXOption *selectedOption = self.selectedOption;
    NSString *selectedValue = [segmentedControl labelForSegment:segmentedControl.selectedSegment];
    
    UXConfigOption *configOption = UXConfigOption.new;
    configOption.option = selectedOption;
    configOption.value = selectedValue;
    
    UXLanguage *selectedLangauge = self.previewLanguagePopUpButton.selectedItem.representedObject;
    
    NSString *result = [UXTaskRunner uncrustifyCodeFragment:self.codePreviewTextView.string
                                          withConfigOptions:@[configOption]
                                                  arguments:@[@"-l", selectedLangauge.code]];
    
    if (result) {
        self.codePreviewTextView.string = result;
        [self.syntaxColoringController recolorCompleteFile:self];
    }
}

- (IBAction)disclosureTriangleClicked:(id)sender {
    [self setPreviewExpanded:!self.previewExpanded animated:YES];
}

- (void)showInfoForOption:(UXOption *)option {
    if (!self.window.isVisible) {
        self.window.isVisible = YES;
    }
    
    NSUInteger optionIndex = [self.allOptions indexOfObject:option];
    
    if (optionIndex != NSNotFound) {
        if (option.category) {
            /* select category in left */
            self.categoriesArrayController.selectedObjects = @[option.category];
        } else {
            /* select 'All' header */
            self.categoriesArrayController.selectedObjects = @[self.categoriesHeader];
        }
        
        /* select option on right */
        NSUInteger filteredOptionIndex = [self.currentOptionsAndSubCategories indexOfObject:option];
        
        if (filteredOptionIndex != NSNotFound) {
            NSIndexSet *selectionIndexSet = [NSIndexSet indexSetWithIndex:filteredOptionIndex];
            [self.optionsTableView selectRowIndexes:selectionIndexSet
                               byExtendingSelection:NO];
            [self.optionsTableView scrollRowToVisible:filteredOptionIndex];
        }
    }
}

#pragma mark - Notification Callbacks

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (object == self.browseLanguagesArrayController
        && [keyPath isEqualToString:@"arrangedObjects.@count"]
        && ![self.browseLanguagesArrayController.arrangedObjects containsObject:self.languagesHeader]) {
        
        [self.browseLanguagesArrayController insertObject:self.languagesHeader atArrangedObjectIndex:0];
        
    } else if (object == self.categoriesArrayController
        && [keyPath isEqualToString:@"arrangedObjects.@count"]
        && ![self.categoriesArrayController.arrangedObjects containsObject:self.categoriesHeader]) {
        
        [self.categoriesArrayController insertObject:self.categoriesHeader atArrangedObjectIndex:0];
        [self filterOptions];
    }
}

#pragma mark - NSResponder

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [super encodeRestorableStateWithCoder:coder];
    
    //TODO
}

#pragma mark - NSWindowDelegate

- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize {
    /* no vertical resizing */
    frameSize.height = self.window.frame.size.height;
    return frameSize;
}

@end