#import "Puzzle.h"
#import "CoreData+MagicalRecord.h"

@implementation Puzzle

+ (Puzzle *) puzzleWithName:(NSString *)puzzleName {
    
	@synchronized (self)
	{
        if (!puzzleName) {
            return nil;
        }
        
        NSPredicate *filter =[NSPredicate predicateWithFormat:@"puzzleName = %@", puzzleName];
        NSFetchRequest *request = [Puzzle MR_requestFirstWithPredicate:filter];
        Puzzle *puzzle  = [Puzzle MR_executeFetchRequestAndReturnFirstObject:request];
        
        if (puzzle == nil)
        {
            puzzle = [Puzzle MR_createEntity];
            puzzle.puzzleName = puzzleName;
        }
        return puzzle;
        
	}
}
@end
