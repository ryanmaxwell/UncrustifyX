// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UXAbstractCategory.h instead.

#import <CoreData/CoreData.h>
#import "UXBaseManagedObject.h"

extern const struct UXAbstractCategoryAttributes {
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *updatedAt;
} UXAbstractCategoryAttributes;

@interface UXAbstractCategoryID : NSManagedObjectID {}
@end

@interface _UXAbstractCategory : UXBaseManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) UXAbstractCategoryID* objectID;

@property (nonatomic, strong) NSDate* createdAt;

//- (BOOL)validateCreatedAt:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* updatedAt;

//- (BOOL)validateUpdatedAt:(id*)value_ error:(NSError**)error_;

@end

@interface _UXAbstractCategory (CoreDataGeneratedPrimitiveAccessors)

- (NSDate*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(NSDate*)value;

- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;

- (NSDate*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(NSDate*)value;

@end
