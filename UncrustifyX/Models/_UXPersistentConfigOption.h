// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UXPersistentConfigOption.h instead.

#import <CoreData/CoreData.h>
#import "UXBaseManagedObject.h"

extern const struct UXPersistentConfigOptionAttributes {
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *updatedAt;
	__unsafe_unretained NSString *value;
} UXPersistentConfigOptionAttributes;

extern const struct UXPersistentConfigOptionRelationships {
	__unsafe_unretained NSString *option;
} UXPersistentConfigOptionRelationships;

extern const struct UXPersistentConfigOptionFetchedProperties {
} UXPersistentConfigOptionFetchedProperties;

@class UXOption;





@interface UXPersistentConfigOptionID : NSManagedObjectID {}
@end

@interface _UXPersistentConfigOption : UXBaseManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (UXPersistentConfigOptionID*)objectID;





@property (nonatomic, strong) NSDate* createdAt;



//- (BOOL)validateCreatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* updatedAt;



//- (BOOL)validateUpdatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* value;



//- (BOOL)validateValue:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) UXOption *option;

//- (BOOL)validateOption:(id*)value_ error:(NSError**)error_;





@end

@interface _UXPersistentConfigOption (CoreDataGeneratedAccessors)

@end

@interface _UXPersistentConfigOption (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(NSDate*)value;




- (NSDate*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(NSDate*)value;




- (NSString*)primitiveValue;
- (void)setPrimitiveValue:(NSString*)value;





- (UXOption*)primitiveOption;
- (void)setPrimitiveOption:(UXOption*)value;


@end
