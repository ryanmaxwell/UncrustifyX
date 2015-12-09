// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UXLanguage.h instead.

#import <CoreData/CoreData.h>
#import "UXBaseManagedObject.h"

extern const struct UXLanguageAttributes {
	__unsafe_unretained NSString *code;
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *extensions;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *updatedAt;
} UXLanguageAttributes;

extern const struct UXLanguageRelationships {
	__unsafe_unretained NSString *codeSamples;
	__unsafe_unretained NSString *options;
} UXLanguageRelationships;

@class UXCodeSample;
@class UXOption;

@interface UXLanguageID : NSManagedObjectID {}
@end

@interface _UXLanguage : UXBaseManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) UXLanguageID* objectID;

@property (nonatomic, strong) NSString* code;

//- (BOOL)validateCode:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* createdAt;

//- (BOOL)validateCreatedAt:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* extensions;

//- (BOOL)validateExtensions:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* updatedAt;

//- (BOOL)validateUpdatedAt:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *codeSamples;

- (NSMutableSet*)codeSamplesSet;

@property (nonatomic, strong) NSSet *options;

- (NSMutableSet*)optionsSet;

@end

@interface _UXLanguage (CodeSamplesCoreDataGeneratedAccessors)
- (void)addCodeSamples:(NSSet*)value_;
- (void)removeCodeSamples:(NSSet*)value_;
- (void)addCodeSamplesObject:(UXCodeSample*)value_;
- (void)removeCodeSamplesObject:(UXCodeSample*)value_;

@end

@interface _UXLanguage (OptionsCoreDataGeneratedAccessors)
- (void)addOptions:(NSSet*)value_;
- (void)removeOptions:(NSSet*)value_;
- (void)addOptionsObject:(UXOption*)value_;
- (void)removeOptionsObject:(UXOption*)value_;

@end

@interface _UXLanguage (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveCode;
- (void)setPrimitiveCode:(NSString*)value;

- (NSDate*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(NSDate*)value;

- (NSString*)primitiveExtensions;
- (void)setPrimitiveExtensions:(NSString*)value;

- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;

- (NSDate*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(NSDate*)value;

- (NSMutableSet*)primitiveCodeSamples;
- (void)setPrimitiveCodeSamples:(NSMutableSet*)value;

- (NSMutableSet*)primitiveOptions;
- (void)setPrimitiveOptions:(NSMutableSet*)value;

@end
