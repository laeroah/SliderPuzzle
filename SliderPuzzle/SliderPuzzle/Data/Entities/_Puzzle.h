// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Puzzle.h instead.

#import <CoreData/CoreData.h>


extern const struct PuzzleAttributes {
	 NSString *bestRecord;
	 NSString *createTime;
	 NSString *hasCompletedBefore;
	 NSString *isDefaultPuzzle;
	 NSString *numOfPiecesHorizontal;
	 NSString *numOfPiecesVertical;
	 NSString *orignalImagePath;
	 NSString *puzzleName;
	 NSString *thumbnailImagePath;
} PuzzleAttributes;

extern const struct PuzzleRelationships {
} PuzzleRelationships;

extern const struct PuzzleFetchedProperties {
} PuzzleFetchedProperties;












@interface PuzzleID : NSManagedObjectID {}
@end

@interface _Puzzle : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (PuzzleID*)objectID;




@property (nonatomic, retain) NSNumber* bestRecord;


@property int32_t bestRecordValue;
- (int32_t)bestRecordValue;
- (void)setBestRecordValue:(int32_t)value_;

//- (BOOL)validateBestRecord:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSDate* createTime;


//- (BOOL)validateCreateTime:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSNumber* hasCompletedBefore;


@property BOOL hasCompletedBeforeValue;
- (BOOL)hasCompletedBeforeValue;
- (void)setHasCompletedBeforeValue:(BOOL)value_;

//- (BOOL)validateHasCompletedBefore:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSNumber* isDefaultPuzzle;


@property BOOL isDefaultPuzzleValue;
- (BOOL)isDefaultPuzzleValue;
- (void)setIsDefaultPuzzleValue:(BOOL)value_;

//- (BOOL)validateIsDefaultPuzzle:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSNumber* numOfPiecesHorizontal;


@property int16_t numOfPiecesHorizontalValue;
- (int16_t)numOfPiecesHorizontalValue;
- (void)setNumOfPiecesHorizontalValue:(int16_t)value_;

//- (BOOL)validateNumOfPiecesHorizontal:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSNumber* numOfPiecesVertical;


@property int16_t numOfPiecesVerticalValue;
- (int16_t)numOfPiecesVerticalValue;
- (void)setNumOfPiecesVerticalValue:(int16_t)value_;

//- (BOOL)validateNumOfPiecesVertical:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString* orignalImagePath;


//- (BOOL)validateOrignalImagePath:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString* puzzleName;


//- (BOOL)validatePuzzleName:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString* thumbnailImagePath;


//- (BOOL)validateThumbnailImagePath:(id*)value_ error:(NSError**)error_;






@end

@interface _Puzzle (CoreDataGeneratedAccessors)

@end

@interface _Puzzle (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveBestRecord;
- (void)setPrimitiveBestRecord:(NSNumber*)value;

- (int32_t)primitiveBestRecordValue;
- (void)setPrimitiveBestRecordValue:(int32_t)value_;




- (NSDate*)primitiveCreateTime;
- (void)setPrimitiveCreateTime:(NSDate*)value;




- (NSNumber*)primitiveHasCompletedBefore;
- (void)setPrimitiveHasCompletedBefore:(NSNumber*)value;

- (BOOL)primitiveHasCompletedBeforeValue;
- (void)setPrimitiveHasCompletedBeforeValue:(BOOL)value_;




- (NSNumber*)primitiveIsDefaultPuzzle;
- (void)setPrimitiveIsDefaultPuzzle:(NSNumber*)value;

- (BOOL)primitiveIsDefaultPuzzleValue;
- (void)setPrimitiveIsDefaultPuzzleValue:(BOOL)value_;




- (NSNumber*)primitiveNumOfPiecesHorizontal;
- (void)setPrimitiveNumOfPiecesHorizontal:(NSNumber*)value;

- (int16_t)primitiveNumOfPiecesHorizontalValue;
- (void)setPrimitiveNumOfPiecesHorizontalValue:(int16_t)value_;




- (NSNumber*)primitiveNumOfPiecesVertical;
- (void)setPrimitiveNumOfPiecesVertical:(NSNumber*)value;

- (int16_t)primitiveNumOfPiecesVerticalValue;
- (void)setPrimitiveNumOfPiecesVerticalValue:(int16_t)value_;




- (NSString*)primitiveOrignalImagePath;
- (void)setPrimitiveOrignalImagePath:(NSString*)value;




- (NSString*)primitivePuzzleName;
- (void)setPrimitivePuzzleName:(NSString*)value;




- (NSString*)primitiveThumbnailImagePath;
- (void)setPrimitiveThumbnailImagePath:(NSString*)value;




@end
