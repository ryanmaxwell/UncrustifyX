// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UXSubCategory.h instead.

#import <CoreData/CoreData.h>
#import "UXAbstractCategory.h"

extern const struct UXSubCategoryAttributes {
} UXSubCategoryAttributes;

extern const struct UXSubCategoryRelationships {
	__unsafe_unretained NSString *options;
	__unsafe_unretained NSString *parentCategories;
} UXSubCategoryRelationships;

extern const struct UXSubCategoryFetchedProperties {
} UXSubCategoryFetchedProperties;

@class UXOption;
@class UXCategory;


@interface UXSubCategoryID : NSManagedObjectID {}
@end

@interface _UXSubCategory : UXAbstractCategory {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (UXSubCategoryID*)objectID;





@property (nonatomic, strong) NSSet *options;

- (NSMutableSet*)optionsSet;




@property (nonatomic, strong) NSSet *parentCategories;

- (NSMutableSet*)parentCategoriesSet;





@end

@interface _UXSubCategory (CoreDataGeneratedAccessors)

- (void)addOptions:(NSSet*)value_;
- (void)removeOptions:(NSSet*)value_;
- (void)addOptionsObject:(UXOption*)value_;
- (void)removeOptionsObject:(UXOption*)value_;

- (void)addParentCategories:(NSSet*)value_;
- (void)removeParentCategories:(NSSet*)value_;
- (void)addParentCategoriesObject:(UXCategory*)value_;
- (void)removeParentCategoriesObject:(UXCategory*)value_;

@end

@interface _UXSubCategory (CoreDataGeneratedPrimitiveAccessors)



- (NSMutableSet*)primitiveOptions;
- (void)setPrimitiveOptions:(NSMutableSet*)value;



- (NSMutableSet*)primitiveParentCategories;
- (void)setPrimitiveParentCategories:(NSMutableSet*)value;


@end
