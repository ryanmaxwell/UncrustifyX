// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UXCategory.m instead.

#import "_UXCategory.h"

const struct UXCategoryAttributes UXCategoryAttributes = {
};

const struct UXCategoryRelationships UXCategoryRelationships = {
	.options = @"options",
	.subCategories = @"subCategories",
};

const struct UXCategoryFetchedProperties UXCategoryFetchedProperties = {
};

@implementation UXCategoryID
@end

@implementation _UXCategory

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"UXCategory" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"UXCategory";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"UXCategory" inManagedObjectContext:moc_];
}

- (UXCategoryID*)objectID {
	return (UXCategoryID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic options;

	
- (NSMutableSet*)optionsSet {
	[self willAccessValueForKey:@"options"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"options"];
  
	[self didAccessValueForKey:@"options"];
	return result;
}
	

@dynamic subCategories;

	
- (NSMutableSet*)subCategoriesSet {
	[self willAccessValueForKey:@"subCategories"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"subCategories"];
  
	[self didAccessValueForKey:@"subCategories"];
	return result;
}
	






@end
