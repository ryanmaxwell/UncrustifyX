// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UXCodeSample.h instead.

#import <CoreData/CoreData.h>
#import "UXBaseManagedObject.h"

extern const struct UXCodeSampleAttributes {
	__unsafe_unretained NSString *codeSampleDescription;
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *source;
	__unsafe_unretained NSString *updatedAt;
} UXCodeSampleAttributes;

extern const struct UXCodeSampleRelationships {
	__unsafe_unretained NSString *language;
} UXCodeSampleRelationships;

extern const struct UXCodeSampleFetchedProperties {
} UXCodeSampleFetchedProperties;

@class UXLanguage;






@interface UXCodeSampleID : NSManagedObjectID {}
@end

@interface _UXCodeSample : UXBaseManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (UXCodeSampleID*)objectID;





@property (nonatomic, strong) NSString* codeSampleDescription;



//- (BOOL)validateCodeSampleDescription:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* createdAt;



//- (BOOL)validateCreatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* source;



//- (BOOL)validateSource:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* updatedAt;



//- (BOOL)validateUpdatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) UXLanguage *language;

//- (BOOL)validateLanguage:(id*)value_ error:(NSError**)error_;





@end

@interface _UXCodeSample (CoreDataGeneratedAccessors)

@end

@interface _UXCodeSample (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveCodeSampleDescription;
- (void)setPrimitiveCodeSampleDescription:(NSString*)value;




- (NSDate*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(NSDate*)value;




- (NSString*)primitiveSource;
- (void)setPrimitiveSource:(NSString*)value;




- (NSDate*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(NSDate*)value;





- (UXLanguage*)primitiveLanguage;
- (void)setPrimitiveLanguage:(UXLanguage*)value;


@end
