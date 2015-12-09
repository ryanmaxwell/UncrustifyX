// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UXCodeSample.m instead.

#import "_UXCodeSample.h"

const struct UXCodeSampleAttributes UXCodeSampleAttributes = {
	.codeSampleDescription = @"codeSampleDescription",
	.createdAt = @"createdAt",
	.source = @"source",
	.updatedAt = @"updatedAt",
};

const struct UXCodeSampleRelationships UXCodeSampleRelationships = {
	.language = @"language",
};

@implementation UXCodeSampleID
@end

@implementation _UXCodeSample

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"UXCodeSample" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"UXCodeSample";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"UXCodeSample" inManagedObjectContext:moc_];
}

- (UXCodeSampleID*)objectID {
	return (UXCodeSampleID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic codeSampleDescription;

@dynamic createdAt;

@dynamic source;

@dynamic updatedAt;

@dynamic language;

@end

