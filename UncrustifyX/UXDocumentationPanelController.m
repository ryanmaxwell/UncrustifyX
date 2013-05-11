//
//  UXDocumentationPanelController.m
//  UncrustifyX
//
//  Created by Ryan Maxwell on 13/10/12.
//  Copyright (c) 2012 Ryan Maxwell. All rights reserved.
//

#import "UXDocumentationPanelController.h"
#import <MGSFragaria/MGSFragaria.h>

#import "UXCategory.h"
#import "UXSubcategory.h"
#import "UXTransientConfigOption.h"
#import "UXOption.h"
#import "UXLanguage.h"
#import "UXPlaceholder.h"
#import "UXValueType.h"
#import "UXValue.h"
#import "UXCodeSample.h"
#import "UXTaskRunner.h"
#import "UXUIUtils.h"

/* NSWindowRestoration keys */
static NSString *const UXPreviewExpandedKey = @"PreviewExpanded";

static CGFloat const PreviewViewHeight = 250.0f;

@interface UXDocumentationPanelController () <NSTableViewDelegate, NSTableViewDataSource, NSTextDelegate, NSSplitViewDelegate, NSWindowDelegate> {
    /* may be used if screen is too small for expanded window */
    CGFloat _previewViewUsedHeight;
}
@property (strong, nonatomic) UXPlaceholder *languagesHeader;
@property (strong, nonatomic) UXPlaceholder *categoriesHeader;
@property (strong, nonatomic) NSString *searchQuery;
@property (assign, nonatomic) BOOL previewExpanded;

@property (strong, nonatomic) NSArray *allOptions;
@property (strong, nonatomic) NSArray *allSubcategories;
@property (strong, nonatomic) NSMutableArray *currentOptionsAndSubcategories;

@property (weak, nonatomic) UXOption *selectedOption;
@property (strong, nonatomic) MGSFragaria *fragaria;
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

        _allOptions = [UXOption findAll];
        _allSubcategories = [UXSubcategory findAll];

        _currentOptionsAndSubcategories = [[NSMutableArray alloc] init];

        _previewExpanded = NO;

        _fragaria = [[MGSFragaria alloc] init];
    }

    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter
     removeObserver:self];
}

- (void)awakeFromNib {
    [self.optionsTableView setDraggingSourceOperationMask:NSDragOperationCopy
                                                 forLocal:NO];

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

    NSString *selectedLanguageCode = UXDEFAULTS.selectedPreviewLanguageInDocumentation;
    UXLanguage *selectedLanguage = [UXLanguage findFirstByAttribute:UXLanguageAttributes.code
                                                          withValue:selectedLanguageCode];

    if (selectedLanguage) {
        self.selectedPreviewLanguage = selectedLanguage;

        [self filterCodeSamplesForLanguage:self.selectedPreviewLanguage];

        [self.fragaria setObject:selectedLanguage.name
                          forKey:MGSFOSyntaxDefinitionName];
    }

    [self.fragaria embedInView:self.fragariaContainerView];
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
            self.selectedOption = self.currentOptionsAndSubcategories[sender.selectedRow];
        }
    }
}

- (BOOL)tableView:(NSTableView *)tableView isGroupRow:(NSInteger)row {
    return tableView == self.optionsTableView && [self.currentOptionsAndSubcategories[row] isKindOfClass:UXSubcategory.class];
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    return ![self tableView:tableView isGroupRow:row];
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if (tableView == self.optionsTableView) {
        return self.currentOptionsAndSubcategories.count;
    }

    return 0;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)rowIndex {
    if (tableView == self.optionsTableView) {
        return [self.currentOptionsAndSubcategories[rowIndex] displayName];
    }

    return nil;
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)rowIndex {
    if (tableView == self.optionsTableView) {
        [self.currentOptionsAndSubcategories[rowIndex] setDisplayName:object];
    }
}

/* Allow dragging options */
- (BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard {
    if (tableView == self.optionsTableView) {
        if (rowIndexes.count == 1 && [self tableView:tableView
                                          isGroupRow:rowIndexes.firstIndex]) {
            return NO;
        }

        [pboard declareTypes:@[NSPasteboardTypeString]
                       owner:self];

        NSMutableArray *items = [NSMutableArray array];

        [rowIndexes enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
            if (![self tableView:tableView isGroupRow:index]) {
                NSPasteboardItem *item = [[NSPasteboardItem alloc] init];
                UXOption *option = self.currentOptionsAndSubcategories[index];

                [item setString:option.code
                        forType:NSPasteboardTypeString];

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

    if ([self.codeSamplesArrayController.arrangedObjects count] == 0) {
        self.selectedCodeSample = nil;
    } else {
        self.selectedCodeSample = self.codeSamplesArrayController.arrangedObjects[0];
    }
}

- (void)filterOptions {
    NSSortDescriptor *displayNameSort = [NSSortDescriptor sortDescriptorWithKey:@"displayName"
                                                                      ascending:YES];

    NSArray *sortedSubcategories = nil;

    if (self.selectedCategory) {
        NSPredicate *subcategoriesFilter = [NSPredicate predicateWithFormat:@"%@ IN %K",
                                            self.selectedCategory,
                                            UXSubcategoryRelationships.parentCategories];

        sortedSubcategories = [[self.allSubcategories filteredArrayUsingPredicate:subcategoriesFilter]
                               sortedArrayUsingDescriptors:@[displayNameSort]];
    } else {
        sortedSubcategories = [self.allSubcategories sortedArrayUsingDescriptors:@[displayNameSort]];
    }

    [self.currentOptionsAndSubcategories removeAllObjects];

    NSPredicate *searchFilter = self.keywordSearchPredicate;

    /* subcategories and their options */
    for (UXSubcategory *subcategory in sortedSubcategories) {
        NSPredicate *categoryFilter = nil;

        if (self.selectedCategory) {
            categoryFilter = [NSPredicate predicateWithFormat:@"%K == %@ AND %K == %@",
                              UXOptionRelationships.category,
                              self.selectedCategory,
                              UXOptionRelationships.subcategory,
                              subcategory];
        } else {
            categoryFilter = [NSPredicate predicateWithFormat:@"%K == %@",
                              UXOptionRelationships.subcategory,
                              subcategory];
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
            [self.currentOptionsAndSubcategories addObject:subcategory];
            [self.currentOptionsAndSubcategories addObjectsFromArray:filteredOptions];
        }
    }

    /* remaining options without subcategories */
    NSPredicate *categoryFilter = nil;

    if (self.selectedCategory) {
        categoryFilter = [NSPredicate predicateWithFormat:@"%K == %@ AND %K == nil",
                          UXOptionRelationships.category,
                          self.selectedCategory,
                          UXOptionRelationships.subcategory];
    } else {
        categoryFilter = [NSPredicate predicateWithFormat:@"%K == nil",
                          UXOptionRelationships.subcategory];
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

    if (sortedSubcategories.count > 0 && filteredOptions.count > 0) {
        /* show "Other" header */
        [self.currentOptionsAndSubcategories addObject:UXSubcategory.otherSubcategory];
    }

    [self.currentOptionsAndSubcategories addObjectsFromArray:filteredOptions];

    [self.optionsTableView reloadData];

    /* select first option */
    [self.currentOptionsAndSubcategories enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop) {
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

    NSArray *selectedLanguageCodes = UXDEFAULTS.languagesIncludedInDocumentationPanel;
    
    if (selectedLanguageCodes.count) {
        NSPredicate *selectedLanguagePredicate = [NSPredicate predicateWithFormat:@"%K IN %@",
                                                  UXLanguageAttributes.code,
                                                  selectedLanguageCodes];
        NSArray *selectedLanguages = [UXLanguage findAllWithPredicate:selectedLanguagePredicate];
        
        BOOL requiresLanguageFilter = (selectedLanguages.count < UXLanguage.findAll.count);
        
        if (requiresLanguageFilter) {
            NSPredicate *languageFilter = [NSPredicate predicateWithFormat:@"languages.@count == 0 OR ANY languages IN %@", selectedLanguages];
            [appliedPredicates addObject:languageFilter];
        }
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

- (void)setSelectedCodeSample:(UXCodeSample *)selectedCodeSample {
    if (_selectedCodeSample != selectedCodeSample) {
        _selectedCodeSample = selectedCodeSample;

        if (selectedCodeSample) {
            self.fragaria.string = selectedCodeSample.source;
        } else {
            self.fragaria.string = @"";
        }
    }
}

- (void)setSelectedPreviewLanguage:(UXLanguage *)selectedPreviewLanguage {
    if (selectedPreviewLanguage != _selectedPreviewLanguage) {
        _selectedPreviewLanguage = selectedPreviewLanguage;
        UXDEFAULTS.selectedPreviewLanguageInDocumentation = selectedPreviewLanguage.code;
    }
}

- (void)setPreviewExpanded:(BOOL)previewExpanded {
    [self setPreviewExpanded:previewExpanded
                    animated:NO];
}

- (void)setPreviewExpanded:(BOOL)previewExpanded animated:(BOOL)animated {
    if (previewExpanded == _previewExpanded) return;

    _previewExpanded = previewExpanded;

    dispatch_async(dispatch_get_main_queue(), ^{
        /* perform window resize async so that disclosure triangle can do flip animation at same time */

        NSRect oldFrame = self.window.frame;
        CGFloat deltaY = 0.0f;

        CGFloat newOriginY;

        if (!self.previewExpanded) {
            /* contract view */
            if (_previewViewUsedHeight != 0.0f) {
                deltaY = -_previewViewUsedHeight;
                _previewViewUsedHeight = 0.0f;
            } else {
                deltaY = -PreviewViewHeight;
            }

            newOriginY = oldFrame.origin.y - deltaY;
        } else {
            /* expand view */
            NSRect screenFrame = self.window.screen.visibleFrame;

            CGFloat proposedHeight = oldFrame.size.height + PreviewViewHeight;

            if (screenFrame.size.height < proposedHeight) {
                proposedHeight = screenFrame.size.height;
                _previewViewUsedHeight = (proposedHeight - oldFrame.size.height);
                deltaY = _previewViewUsedHeight;
                newOriginY = screenFrame.origin.y;
            } else {
                deltaY = PreviewViewHeight;
                newOriginY = oldFrame.origin.y - deltaY;
            }
        }

        CGFloat newHeight = oldFrame.size.height + deltaY;
        NSRect newFrame = NSMakeRect(oldFrame.origin.x, newOriginY, oldFrame.size.width, newHeight);

        [self.window setFrame:newFrame
                      display:YES
                      animate:animated];
    });
}

#pragma mark - IBAction

- (IBAction)browseLanguagesPopUpChanged:(id)sender {
    NSPopUpButton *senderButton = (NSPopUpButton *)sender;
    UXLanguage *selectedLanguage = senderButton.selectedItem.representedObject;

    selectedLanguage.includedInDocumentation = !selectedLanguage.includedInDocumentation;
    [self filterOptions];
}

- (IBAction)previewLanguagePopUpChanged:(id)sender {
    [self filterCodeSamplesForLanguage:self.selectedPreviewLanguage];
    [self.fragaria setObject:self.selectedPreviewLanguage.name
                      forKey:MGSFOSyntaxDefinitionName];
}

- (IBAction)disclosureTriangleClicked:(id)sender {
    [self setPreviewExpanded:!self.previewExpanded
                    animated:YES];
    [self.window invalidateRestorableState];
}

- (IBAction)valueSegmentedControlChanged:(id)sender {
    NSSegmentedControl *segmentedControl = (NSSegmentedControl *)sender;
    NSString *selectedValue = [segmentedControl labelForSegment:segmentedControl.selectedSegment];

    [self uncrustifyCodePreviewUsingOption:self.selectedOption
                                     value:selectedValue];
}

- (IBAction)applyPressed:(id)sender {
    [self uncrustifyCodePreviewUsingOption:self.selectedOption
                                     value:self.valueTextField.stringValue];
}

- (void)uncrustifyCodePreviewUsingOption:(UXOption *)option value:(NSString *)value {
    UXTransientConfigOption *configOption = UXTransientConfigOption.new;

    configOption.option = option;
    configOption.value = value;

    UXLanguage *selectedLangauge = self.previewLanguagePopUpButton.selectedItem.representedObject;

    NSString *result = [UXTaskRunner uncrustifyCodeFragment:self.fragaria.string
                                          withConfigOptions:@[configOption]
                                                  arguments:@[@"-l", selectedLangauge.code]];

    if (result) {
        self.fragaria.string = result;
    }
}

- (void)showInfoForOption:(UXOption *)option {
    if (!option) return;
    
    if (!self.window.isVisible) {
        self.window.isVisible = YES;
    }

    /* Clear any search query */
    if (self.searchQuery) {
        self.searchQuery = nil;
        self.searchField.stringValue = @"";
        [self filterOptions];
    }

    NSUInteger optionIndex = [self.allOptions
                              indexOfObject:option];

    if (optionIndex != NSNotFound) {
        if (option.category) {
            /* select category in left */
            self.categoriesArrayController.selectedObjects = @[option.category];
        } else {
            /* select 'All' header */
            self.categoriesArrayController.selectedObjects = @[self.categoriesHeader];
        }

        /* select option on right */
        NSUInteger filteredOptionIndex = [self.currentOptionsAndSubcategories
                                          indexOfObject:option];

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
        [self.browseLanguagesArrayController insertObject:self.languagesHeader
                                    atArrangedObjectIndex:0];
    } else if (object == self.categoriesArrayController
               && [keyPath isEqualToString:@"arrangedObjects.@count"]
               && ![self.categoriesArrayController.arrangedObjects containsObject:self.categoriesHeader]) {
        [self.categoriesArrayController insertObject:self.categoriesHeader
                                   atArrangedObjectIndex:0];
        [self filterOptions];
    }
}

#pragma mark - NSWindowDelegate

- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize {
    /* no vertical resizing */
    frameSize.height = self.window.frame.size.height;
    return frameSize;
}

- (void)window:(NSWindow *)window willEncodeRestorableState:(NSCoder *)state {
    [state encodeBool:self.previewExpanded
               forKey:UXPreviewExpandedKey];
}

- (void)window:(NSWindow *)window didDecodeRestorableState:(NSCoder *)state {
    BOOL expanded = [state decodeBoolForKey:UXPreviewExpandedKey];

    if (expanded) {
        /* move up to account for initial window position */
        self.window.frameOrigin = NSMakePoint(self.window.frame.origin.x, self.window.frame.origin.y + PreviewViewHeight);

        [self setPreviewExpanded:YES
                        animated:NO];
        self.disclosureTriangle.state = NSOnState;
    }
}

@end