// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UXCategory.h instead.

#import <CoreData/CoreData.h>
#import "UXAbstractCategory.h"

extern const struct UXCategoryAttributes {
} UXCategoryAttributes;

extern const struct UXCategoryRelationships {
	__unsafe_unretained NSString *options;
	__unsafe_unretained NSString *subCategories;
} UXCategoryRelationships;

extern const struct UXCategoryFetchedProperties {
} UXCategoryFetchedProperties;

@class UXOption;
@class UXSubCategory;


@interface UXCategoryID : NSManagedObjectID {}
@end

@interface _UXCategory : UXAbstractCategory {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (UXCategoryID*)objectID;





@property (nonatomic, strong) NSSet *options;

- (NSMutableSet*)optionsSet;




@property (nonatomic, strong) NSSet *subCategories;

- (NSMutableSet*)subCategoriesSet;





@end

@interface _UXCategory (CoreDataGeneratedAccessors)

- (void)addOptions:(NSSet*)value_;
- (void)removeOptions:(NSSet*)value_;
- (void)addOptionsObject:(UXOption*)value_;
- (void)removeOptionsObject:(UXOption*)value_;

- (void)addSubCategories:(NSSet*)value_;
- (void)removeSubCategories:(NSSet*)value_;
- (void)addSubCategoriesObject:(UXSubCategory*)value_;
- (void)removeSubCategoriesObject:(UXSubCategory*)value_;

@end

@interface _UXCategory (CoreDataGeneratedPrimitiveAccessors)



- (NSMutableSet*)primitiveOptions;
- (void)setPrimitiveOptions:(NSMutableSet*)value;



- (NSMutableSet*)primitiveSubCategories;
- (void)setPrimitiveSubCategories:(NSMutableSet*)value;


@end
