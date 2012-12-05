// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UXCategory.h instead.

#import <CoreData/CoreData.h>
#import "UXAbstractCategory.h"

extern const struct UXCategoryAttributes {
} UXCategoryAttributes;

extern const struct UXCategoryRelationships {
	__unsafe_unretained NSString *options;
	__unsafe_unretained NSString *subcategories;
} UXCategoryRelationships;

extern const struct UXCategoryFetchedProperties {
} UXCategoryFetchedProperties;

@class UXOption;
@class UXSubcategory;


@interface UXCategoryID : NSManagedObjectID {}
@end

@interface _UXCategory : UXAbstractCategory {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (UXCategoryID*)objectID;





@property (nonatomic, strong) NSSet *options;

- (NSMutableSet*)optionsSet;




@property (nonatomic, strong) NSSet *subcategories;

- (NSMutableSet*)subcategoriesSet;





@end

@interface _UXCategory (CoreDataGeneratedAccessors)

- (void)addOptions:(NSSet*)value_;
- (void)removeOptions:(NSSet*)value_;
- (void)addOptionsObject:(UXOption*)value_;
- (void)removeOptionsObject:(UXOption*)value_;

- (void)addSubcategories:(NSSet*)value_;
- (void)removeSubcategories:(NSSet*)value_;
- (void)addSubcategoriesObject:(UXSubcategory*)value_;
- (void)removeSubcategoriesObject:(UXSubcategory*)value_;

@end

@interface _UXCategory (CoreDataGeneratedPrimitiveAccessors)



- (NSMutableSet*)primitiveOptions;
- (void)setPrimitiveOptions:(NSMutableSet*)value;



- (NSMutableSet*)primitiveSubcategories;
- (void)setPrimitiveSubcategories:(NSMutableSet*)value;


@end
