//
//  SPGameViewController.h
//  SliderPuzzle
//
//  Created by 王 昊 on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPPuzzleTile.h"

typedef enum {
    SPPuzzleTileMovingDirectionNone,
    SPPuzzleTileMovingDirectionLeft,
    SPPuzzleTileMovingDirectionRight,
    SPPuzzleTileMovingDirectionUp,
    SPPuzzleTileMovingDirectionDown
}SPPuzzleTileMovingDirection;

@class SPPuzzleView;
@class Puzzle;

@interface SPGameViewController : UIViewController 
<SPPuzzleTileDelegate, UIAlertViewDelegate>
{
    SPPuzzleView *_puzzleGameView;
    NSArray *_gameTiles;
    
    //record the blank tile's position
    CGPoint _currentBlankTilePosition;
    
    //record how much the current tile has moved, helps decide if the move should be completed or reverted.
    CGPoint _accumulateDisplacement;
    
    UIAlertView *_finishAlertView;
    
    UIAlertView *_puzzleShuffleAlertView;
    
    Puzzle *_puzzle;
    
    CGPoint _blankTilePosition;
    
    NSInteger _moveCount;
    
    BOOL _isShuffling;
    
    UIImageView *_originalPuzzleImageView;
    
    BOOL _hasLoadedTiles;
}

@property (nonatomic, retain) Puzzle *puzzle;
@property (retain, nonatomic) IBOutlet UILabel *moveCountLabel;
@property (retain, nonatomic) IBOutlet UILabel *bestRecordLabel;
@property (retain, nonatomic) IBOutlet UILabel *loadingLabel;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (retain, nonatomic) IBOutlet UIButton *hintToggleButton;
@property (retain, nonatomic) IBOutlet UIView *contentView;
@property (retain, nonatomic) IBOutlet UIButton *shuffleButton;

- (id)initWithNibName:(NSString *)nibNameOrNil andPuzzle:(Puzzle *)puzzle;
- (IBAction)shufflePuzzle:(id)sender;
- (IBAction)toggleHintAndPuzzle:(id)sender;

@end
