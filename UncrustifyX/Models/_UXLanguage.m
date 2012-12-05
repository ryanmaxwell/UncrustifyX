// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UXLanguage.m instead.

#import "_UXLanguage.h"

const struct UXLanguageAttributes UXLanguageAttributes = {
	.code = @"code",
	.createdAt = @"createdAt",
	.extensions = @"extensions",
	.name = @"name",
	.updatedAt = @"updatedAt",
};

const struct UXLanguageRelationships UXLanguageRelationships = {
	.codeSamples = @"codeSamples",
	.options = @"options",
};

const struct UXLanguageFetchedProperties UXLanguageFetchedProperties = {
};

@implementation UXLanguageID
@end

@implementation _UXLanguage

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"UXLanguage" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"UXLanguage";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"UXLanguage" inManagedObjectContext:moc_];
}

- (UXLanguageID*)objectID {
	return (UXLanguageID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic code;






@dynamic createdAt;






@dynamic extensions;






@dynamic name;






@dynamic updatedAt;






@dynamic codeSamples;

	
- (NSMutableSet*)codeSamplesSet {
	[self willAccessValueForKey:@"codeSamples"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"codeSamples"];
  
	[self didAccessValueForKey:@"codeSamples"];
	return result;
}
	

@dynamic options;

	
- (NSMutableSet*)optionsSet {
	[self willAccessValueForKey:@"options"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"options"];
  
	[self didAccessValueForKey:@"options"];
	return result;
}
	






@end
