// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UXSubCategory.m instead.

#import "_UXSubCategory.h"

const struct UXSubCategoryAttributes UXSubCategoryAttributes = {
};

const struct UXSubCategoryRelationships UXSubCategoryRelationships = {
	.options = @"options",
	.parentCategories = @"parentCategories",
};

const struct UXSubCategoryFetchedProperties UXSubCategoryFetchedProperties = {
};

@implementation UXSubCategoryID
@end

@implementation _UXSubCategory

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"UXSubCategory" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"UXSubCategory";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"UXSubCategory" inManagedObjectContext:moc_];
}

- (UXSubCategoryID*)objectID {
	return (UXSubCategoryID*)[super objectID];
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
	

@dynamic parentCategories;

	
- (NSMutableSet*)parentCategoriesSet {
	[self willAccessValueForKey:@"parentCategories"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"parentCategories"];
  
	[self didAccessValueForKey:@"parentCategories"];
	return result;
}
	






@end
