// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Puzzle.m instead.

#import "_Puzzle.h"

const struct PuzzleAttributes PuzzleAttributes = {
	.bestRecord = @"bestRecord",
	.createTime = @"createTime",
	.hasCompletedBefore = @"hasCompletedBefore",
	.isDefaultPuzzle = @"isDefaultPuzzle",
	.numOfPiecesHorizontal = @"numOfPiecesHorizontal",
	.numOfPiecesVertical = @"numOfPiecesVertical",
	.orignalImagePath = @"orignalImagePath",
	.puzzleName = @"puzzleName",
	.thumbnailImagePath = @"thumbnailImagePath",
};

const struct PuzzleRelationships PuzzleRelationships = {
};

const struct PuzzleFetchedProperties PuzzleFetchedProperties = {
};

@implementation PuzzleID
@end

@implementation _Puzzle

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Puzzle" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Puzzle";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Puzzle" inManagedObjectContext:moc_];
}

- (PuzzleID*)objectID {
	return (PuzzleID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"bestRecordValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"bestRecord"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"hasCompletedBeforeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"hasCompletedBefore"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"isDefaultPuzzleValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isDefaultPuzzle"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"numOfPiecesHorizontalValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"numOfPiecesHorizontal"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"numOfPiecesVerticalValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"numOfPiecesVertical"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic bestRecord;



- (int32_t)bestRecordValue {
	NSNumber *result = [self bestRecord];
	return [result intValue];
}

- (void)setBestRecordValue:(int32_t)value_ {
	[self setBestRecord:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveBestRecordValue {
	NSNumber *result = [self primitiveBestRecord];
	return [result intValue];
}

- (void)setPrimitiveBestRecordValue:(int32_t)value_ {
	[self setPrimitiveBestRecord:[NSNumber numberWithInt:value_]];
}





@dynamic createTime;






@dynamic hasCompletedBefore;



- (BOOL)hasCompletedBeforeValue {
	NSNumber *result = [self hasCompletedBefore];
	return [result boolValue];
}

- (void)setHasCompletedBeforeValue:(BOOL)value_ {
	[self setHasCompletedBefore:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveHasCompletedBeforeValue {
	NSNumber *result = [self primitiveHasCompletedBefore];
	return [result boolValue];
}

- (void)setPrimitiveHasCompletedBeforeValue:(BOOL)value_ {
	[self setPrimitiveHasCompletedBefore:[NSNumber numberWithBool:value_]];
}





@dynamic isDefaultPuzzle;



- (BOOL)isDefaultPuzzleValue {
	NSNumber *result = [self isDefaultPuzzle];
	return [result boolValue];
}

- (void)setIsDefaultPuzzleValue:(BOOL)value_ {
	[self setIsDefaultPuzzle:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsDefaultPuzzleValue {
	NSNumber *result = [self primitiveIsDefaultPuzzle];
	return [result boolValue];
}

- (void)setPrimitiveIsDefaultPuzzleValue:(BOOL)value_ {
	[self setPrimitiveIsDefaultPuzzle:[NSNumber numberWithBool:value_]];
}





@dynamic numOfPiecesHorizontal;



- (int16_t)numOfPiecesHorizontalValue {
	NSNumber *result = [self numOfPiecesHorizontal];
	return [result shortValue];
}

- (void)setNumOfPiecesHorizontalValue:(int16_t)value_ {
	[self setNumOfPiecesHorizontal:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveNumOfPiecesHorizontalValue {
	NSNumber *result = [self primitiveNumOfPiecesHorizontal];
	return [result shortValue];
}

- (void)setPrimitiveNumOfPiecesHorizontalValue:(int16_t)value_ {
	[self setPrimitiveNumOfPiecesHorizontal:[NSNumber numberWithShort:value_]];
}





@dynamic numOfPiecesVertical;



- (int16_t)numOfPiecesVerticalValue {
	NSNumber *result = [self numOfPiecesVertical];
	return [result shortValue];
}

- (void)setNumOfPiecesVerticalValue:(int16_t)value_ {
	[self setNumOfPiecesVertical:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveNumOfPiecesVerticalValue {
	NSNumber *result = [self primitiveNumOfPiecesVertical];
	return [result shortValue];
}

- (void)setPrimitiveNumOfPiecesVerticalValue:(int16_t)value_ {
	[self setPrimitiveNumOfPiecesVertical:[NSNumber numberWithShort:value_]];
}





@dynamic orignalImagePath;






@dynamic puzzleName;






@dynamic thumbnailImagePath;











@end
