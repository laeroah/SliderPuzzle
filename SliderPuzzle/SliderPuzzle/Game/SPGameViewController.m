//
//  SPGameViewController.m
//  SliderPuzzle
//
//  Created by 王 昊 on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPGameViewController.h"
#import "SPPuzzleView.h"
#import "UIImageHelper.h"
#import "Puzzle.h"
#import "UIViewHelper.h"
#import "CoreData+MagicalRecord.h"

@interface SPGameViewController (private)

/**
 * use an user select image to create the puzzle tiles.
 */
- (NSArray *)createTilesFromImage:(UIImage *)image;

/**
 * use the image provided by Facebook (UIE_Slider_Puzzle--slider.jpg) to create the puzzle tiles.
 * I only implement this method so that the game can have an exact starting point described in UIE_Slider_Puzzle--slider.jpg. If it is not required to so, then it's completely unnecessary to use this method, and we can generate the tiles using UIE_Slider_Puzzle--globe.jpg.
 */
- (NSArray *)createDefaultGameTiles;

/**
 * returns the valid displacement of the tile which is subject to move
 * if the tile cannot be moved, (0, 0) is returned;
 */
- (CGPoint)validDisplacementFromFingerDisplacement:(CGPoint)fingerDisplacement forTile:(SPPuzzleTile *)tile;


/**
 * if finger lifted when the tile is moved less than half way, go back to its previous position.
 * otherwise, move the tile to it's new position
 */
- (void)snapTile:(SPPuzzleTile *)tile toPositionAnimated:(BOOL)isAnimated;

- (void)moveTile:(SPPuzzleTile *)tile withDisplacement:(CGPoint)displacement;

/**
 * this method will try to move the tile in a valid direction. If the tile cannot be moved then it will stay still.
 */
- (void)tryMoveTile:(SPPuzzleTile *)tile animated:(BOOL)isAnimated;

/**
 * returns the valid moving direction of a tile
 */
- (SPPuzzleTileMovingDirection)validMovingDirectionForTile:(SPPuzzleTile *)tile;

- (void)updateBlankTilePositionAfterMovingTile:(SPPuzzleTile *)tile withDirection:(SPPuzzleTileMovingDirection)direction;

/**
 * returns nil when the tile cannot be moved (does not assign with blank tile in x/y direction), or an empty array when it is right next to the blank tile
 */
- (NSArray *)tilesBetweenBlankTileAndTile:(SPPuzzleTile *)tile;

/**
 * checks if the puzzle is solved
 */
- (BOOL)isPuzzleComplete;

- (void)resetMoveCount;
- (void)incrementMoveCount;


/**
 * move the tiles with certain amount of times to shuffle them
 */
- (void)shuffleGameTiles;

- (void)loadingFinished;

@end

@implementation SPGameViewController

@synthesize puzzle = _puzzle;
@synthesize moveCountLabel = _moveCountLabel;
@synthesize bestRecordLabel = _bestRecordLabel;
@synthesize loadingLabel = _loadingLabel;
@synthesize loadingIndicator = _loadingIndicator;
@synthesize hintToggleButton = _hintToggleButton;
@synthesize contentView = _contentView;
@synthesize shuffleButton = _shuffleButton;

//change these two numbers can change the puzzle have different number of tiles
//the default puzzle wouldn't work because we are using the provided image
//possible future extenstion to let the user decide these number when create new puzzles
#define NUM_TILES_HORIZONTAL    4
#define NUM_TILES_VERTICAL      4

//the puzzle image has a border, which should not be included as part of tiles
#define PUZZLE_IMAGE_XOFFSET    15
#define PUZZLE_IMAGE_YOFFSET    5

#define SHUFFLE_TIME            300

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil andPuzzle:(Puzzle *)puzzle 
{
    self = [super initWithNibName:nibNameOrNil bundle:nil];
    if (self) {
        self.puzzle = puzzle;
    }
    return self;
}

/**
 * we load the tiles in viewDidAppear instead of viewDidLoad to make the user experience better
 * because we are going to draw things in the main thread, and doing so in viewDidLoad can cause the view controller transition to be sluggish.
 * use _hasLoadedTiles to record if the tiles are loaded already, in case loading them repeatedly.
 * if we release game view and the tiles upon memory warning(not needed in this case), we need to set _hasLoadedTiles to be NO in viewDidLoad to reload the tiles.
 */
- (void)viewDidAppear:(BOOL)animated 
{
    [super viewDidAppear:animated];
    
    if (_hasLoadedTiles) {
        return;
    }
    
    if ([self.puzzle isDefaultPuzzleValue]) 
    {
        //for default game, because we use provided image, the blank tile is marked at {0,1}
        _blankTilePosition = CGPointMake(0, 1);
        _currentBlankTilePosition = _blankTilePosition;
        
        //setup the default puzzle.
        //we do not want to block the main thread here, because cutting the tiles can take some time
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (!_gameTiles) {
                _gameTiles = [[self createDefaultGameTiles] retain];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [_puzzleGameView layoutTiles:_gameTiles withBlankTilePosition:_blankTilePosition andHorizontalTileNum:NUM_TILES_HORIZONTAL andVerticalTileNum:NUM_TILES_VERTICAL];
                [self loadingFinished];
                [self.contentView addSubview:_puzzleGameView];
            });
            
        });
    }else 
    {
        //for other game puzzles, the blank tile needs to be at a corner, and we choose the right bottom corner
        _blankTilePosition = CGPointMake(NUM_TILES_HORIZONTAL - 1, NUM_TILES_VERTICAL - 1);
        _currentBlankTilePosition = _blankTilePosition;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            if (!_gameTiles) {
                _gameTiles = [[self createTilesFromImage:[UIImage loadImageWithName:self.puzzle.orignalImagePath]] retain];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [_puzzleGameView layoutTiles:_gameTiles withBlankTilePosition:_blankTilePosition andHorizontalTileNum:NUM_TILES_HORIZONTAL andVerticalTileNum:NUM_TILES_VERTICAL];
                [self shuffleGameTiles];
                [self loadingFinished];
                [self.contentView addSubview:_puzzleGameView];
            });
            
        });
    }
    
    _hasLoadedTiles = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //create the puzzle game view
    _puzzleGameView = [[SPPuzzleView alloc]initWithFrame:CGRectMake(0, 0, SIZE_PUZZLE_VIEW.width, SIZE_PUZZLE_VIEW.height)];
    _isShuffling = NO;
    
    self.title = self.puzzle.puzzleName;
    
    if ([self.puzzle hasCompletedBeforeValue]) {
        self.bestRecordLabel.text = [NSString stringWithFormat:@"%@", [self.puzzle.bestRecord stringValue]];
    }else {
        self.bestRecordLabel.text = @"N/A";
    }

}

- (void)viewDidUnload
{
    [self setMoveCountLabel:nil];
    [self setBestRecordLabel:nil];
    [self setLoadingLabel:nil];
    [self setLoadingIndicator:nil];
    [self setHintToggleButton:nil];
    [self setContentView:nil];
    [self setShuffleButton:nil];
    [super viewDidUnload];
    _puzzleGameView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) || (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc 
{
    [_gameTiles release];
    [_puzzle release];
    [_moveCountLabel release];
    [_bestRecordLabel release];
    [_loadingLabel release];
    [_loadingIndicator release];
    [_puzzleGameView release];
    [_hintToggleButton release];
    [_contentView release];
    [_originalPuzzleImageView release];
    [_shuffleButton release];
    [super dealloc];
}

#pragma mark -
#pragma mark - move count
- (void)incrementMoveCount {
    _moveCount ++;
    //set the maximum move count to be 999
    _moveCount = _moveCount>=999?999:_moveCount;
    self.moveCountLabel.text = [NSString stringWithFormat:@"%d", _moveCount];
}


- (void)resetMoveCount 
{
    _moveCount = 0;
    self.moveCountLabel.text = [NSString stringWithFormat:@"%d", _moveCount];
}


#pragma mark -
#pragma mark - actions and shuffle
- (IBAction)shufflePuzzle:(id)sender {
    
    _puzzleShuffleAlertView = [[UIAlertView alloc]initWithTitle:@"Shuffle Puzzle?" message:@"The current progress will be lost." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Okay", nil];
    [_puzzleShuffleAlertView show];
    [_puzzleShuffleAlertView release];
}

- (IBAction)toggleHintAndPuzzle:(id)sender {
    self.hintToggleButton.selected = !self.hintToggleButton.selected;
    
    if (!_originalPuzzleImageView) {
        if ([self.puzzle isDefaultPuzzleValue]) 
        {
            //unlike other puzzles, default puzzle original image is not the same we store in coredata
            _originalPuzzleImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamedWithNoCach:@"UIE_Slider_Puzzle--globe.jpg"]];
        }else {
            _originalPuzzleImageView = [[UIImageView alloc]initWithImage:[UIImage loadImageWithName:self.puzzle.orignalImagePath]];
        }
        _originalPuzzleImageView.frame = _puzzleGameView.frame;
    }
	// set up an animation for the transition between the views
	[UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1.0];
    if (self.hintToggleButton.selected) {
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.contentView cache:YES];
        [self.contentView addSubview:_originalPuzzleImageView];
        [_puzzleGameView removeFromSuperview];
        self.shuffleButton.enabled = NO;
    }else {
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.contentView cache:YES];
        [self.contentView addSubview:_puzzleGameView];
        [_originalPuzzleImageView removeFromSuperview];
        self.shuffleButton.enabled = YES;
    }
    
    [UIView commitAnimations];

    
}

- (void)shuffleGameTiles 
{
    _isShuffling = YES;
    
    //shuffle the tiles by randomly moving them validly
    for (int i = 0; i<SHUFFLE_TIME; i++) {
        //get a random tile and try move it
        NSInteger randomIndex = arc4random()%[_gameTiles count];
        SPPuzzleTile *tile = [_gameTiles objectAtIndex:randomIndex];
        [self tryMoveTile:tile animated:NO];
    }
    _isShuffling = NO;
}

#pragma mark -
#pragma mark - Generating tiles
- (NSArray *)createTilesFromImage:(UIImage *)image 
{
    //find out the appropriate tile size from the puzzle view size
    CGFloat tileHeight = floorf(SIZE_PUZZLE_VIEW.height / NUM_TILES_HORIZONTAL);
    CGFloat tileWidth = floorf(SIZE_PUZZLE_VIEW.width / NUM_TILES_VERTICAL);
    
    //the slider image provided(UIE_Slider_Puzzle--slider.jpg) has borders, we need to cut along them
    CGFloat imageTileHeight = floorf((image.size.height - 2 * PUZZLE_IMAGE_YOFFSET) / NUM_TILES_HORIZONTAL);
    CGFloat imageTileWidth = floorf((image.size.width - 2 * PUZZLE_IMAGE_XOFFSET) / NUM_TILES_VERTICAL);
    
    NSMutableArray *tiles = [NSMutableArray array];
    
    for (int row = 0; row < NUM_TILES_VERTICAL; row ++) {
        for (int col = 0; col < NUM_TILES_HORIZONTAL; col ++) 
        {
            //break the original image into tiles
			CGRect cropRect = CGRectMake(imageTileWidth*col + PUZZLE_IMAGE_XOFFSET, imageTileHeight*row + PUZZLE_IMAGE_YOFFSET, imageTileWidth, imageTileHeight );
			CGImageRef tileImageRef = CGImageCreateWithImageInRect(image.CGImage, cropRect);
			UIImage *tileImage = [UIImage imageWithCGImage:tileImageRef];
            CGImageRelease(tileImageRef);

            SPPuzzleTile *tile = [[SPPuzzleTile alloc]initWithImage:tileImage andFrame:CGRectMake(0, 0, tileWidth, tileHeight)];
            
            CGPoint tileOriginalPosition = CGPointMake(col, row);
            if (CGPointEqualToPoint(tileOriginalPosition, _blankTilePosition)) {
                //do not add the blank tile
                continue;
            }
            tile.originalTilePosition = tileOriginalPosition;
            tile.currentTilePosition = tileOriginalPosition;
            tile.delegate = self;
            [tiles addObject:[tile autorelease]];
        }
    }
    return tiles;
}

- (NSArray *)createDefaultGameTiles 
{
    NSArray *gameTiles = [self createTilesFromImage:[UIImage loadImageWithName:self.puzzle.orignalImagePath]];
    for (SPPuzzleTile *tile in gameTiles) {
        tile.currentTilePosition = tile.originalTilePosition;
        
        //mark where the tile's finished position is don't need to do this if we just create the tiles from the original image
        //only doing this for the default puzzle because we are using the provided slider image instead of generating the tiles from original image
        if (CGPointEqualToPoint(tile.currentTilePosition, CGPointMake(0, 0))) {
            tile.originalTilePosition = CGPointMake(1, 1);
        }else if (CGPointEqualToPoint(tile.currentTilePosition, CGPointMake(1, 0))) {
            tile.originalTilePosition = CGPointMake(2, 0);
        }else if (CGPointEqualToPoint(tile.currentTilePosition, CGPointMake(2, 0))) {
            tile.originalTilePosition = CGPointMake(1, 2);
        }else if (CGPointEqualToPoint(tile.currentTilePosition, CGPointMake(3, 0))) {
            tile.originalTilePosition = CGPointMake(2, 3);
        }else if (CGPointEqualToPoint(tile.currentTilePosition, CGPointMake(1, 1))) {
            tile.originalTilePosition = CGPointMake(3, 1);
        }else if (CGPointEqualToPoint(tile.currentTilePosition, CGPointMake(2, 1))) {
            tile.originalTilePosition = CGPointMake(2, 1);
        }else if (CGPointEqualToPoint(tile.currentTilePosition, CGPointMake(3, 1))) {
            tile.originalTilePosition = CGPointMake(0, 3);
        }else if (CGPointEqualToPoint(tile.currentTilePosition, CGPointMake(0, 2))) {
            tile.originalTilePosition = CGPointMake(1, 3);
        }else if (CGPointEqualToPoint(tile.currentTilePosition, CGPointMake(1, 2))) {
            tile.originalTilePosition = CGPointMake(0, 1);
        }else if (CGPointEqualToPoint(tile.currentTilePosition, CGPointMake(2, 2))) {
            tile.originalTilePosition = CGPointMake(3, 2);
        }else if (CGPointEqualToPoint(tile.currentTilePosition, CGPointMake(3, 2))) {
            tile.originalTilePosition = CGPointMake(3, 0);
        }else if (CGPointEqualToPoint(tile.currentTilePosition, CGPointMake(0, 3))) {
            tile.originalTilePosition = CGPointMake(2, 2);
        }else if (CGPointEqualToPoint(tile.currentTilePosition, CGPointMake(1, 3))) {
            tile.originalTilePosition = CGPointMake(0, 2);
        }else if (CGPointEqualToPoint(tile.currentTilePosition, CGPointMake(2, 3))) {
            tile.originalTilePosition = CGPointMake(1, 0);
        }else if (CGPointEqualToPoint(tile.currentTilePosition, CGPointMake(3, 3))) {
            tile.originalTilePosition = CGPointMake(0, 0);
        }
    }
    return gameTiles;
}

- (void)loadingFinished 
{
    [self.loadingLabel removeFromSuperview];
    [self.loadingIndicator stopAnimating];
}

#pragma mark -
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex 
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if (alertView == _finishAlertView) {
        if([title isEqualToString:@"Okay"])
        {
            [alertView dismissWithClickedButtonIndex:0 animated:YES];
        }
    }else if(alertView == _puzzleShuffleAlertView) {
        if ([title isEqualToString:@"Okay"]) {
            [self resetMoveCount];
            [self shuffleGameTiles];
        }else 
        {
            [alertView dismissWithClickedButtonIndex:0 animated:YES];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView == _finishAlertView) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark -
#pragma mark - SPPuzzleTileDelegate
- (void)isDraggingOnTile:(SPPuzzleTile *)tile withFingerDisplacement:(CGPoint)fingerDisplacement 
{
    CGPoint validDisplacement = [self validDisplacementFromFingerDisplacement:fingerDisplacement forTile:tile];
    _accumulateDisplacement.x += validDisplacement.x;
    _accumulateDisplacement.y += validDisplacement.y;
    
    [self moveTile:tile withDisplacement:validDisplacement];
    
    NSArray *tilesBetweenBlankTile = [self tilesBetweenBlankTileAndTile:tile];
    for (SPPuzzleTile *neighborTile in tilesBetweenBlankTile) {
        //move the tiles between this tile and the blank tile 
        [self moveTile:neighborTile withDisplacement:validDisplacement];
    }
}

- (void)isTappingOnTile:(SPPuzzleTile *)tile 
{
    [self tryMoveTile:tile animated:YES];
}

- (void)didEndDraggingOnTile:(SPPuzzleTile *)tile {
    [self didEndTryingToMoveTile:tile];
}

- (void)didEndTryingToMoveTile:(SPPuzzleTile *)tile 
{
    _accumulateDisplacement = CGPointZero;
    
    SPPuzzleTileMovingDirection direction = [self validMovingDirectionForTile:tile];
    [self snapTile:tile toPositionAnimated:YES];
    NSArray *tilesBetweenBlankTile = [self tilesBetweenBlankTileAndTile:tile];
    for (SPPuzzleTile *neighborTile in tilesBetweenBlankTile) {
        [self snapTile:neighborTile toPositionAnimated:YES];
    }
    
    //test if the tile's move is completed or reverted
    CGPoint actualTilePosition = [tile currentPositionCalculatedFromOrigin];
    if (!CGPointEqualToPoint(actualTilePosition, tile.currentTilePosition)) 
    {
        if (!_isShuffling) {
            [self incrementMoveCount];
        }
        //moved, update the tile's position and the blank tile position
        tile.currentTilePosition = actualTilePosition;
        [self updateBlankTilePositionAfterMovingTile:tile withDirection:direction];
        
        //update the position of the tiles in between
        for (SPPuzzleTile *neighborTile in tilesBetweenBlankTile) {
            CGPoint newPosition = [neighborTile currentPositionCalculatedFromOrigin];
            neighborTile.currentTilePosition = newPosition;
        }
        
        //if puzzle is complete, then we give the notification here
        if ([self isPuzzleComplete] && !_isShuffling) {
            if (![self.puzzle hasCompletedBeforeValue]) 
            {
                //first time complete
                [self.puzzle setHasCompletedBeforeValue: YES];
                [self.puzzle setBestRecordValue:_moveCount];
                [[NSManagedObjectContext MR_contextForCurrentThread]MR_save];
                
                _finishAlertView = [[UIAlertView alloc]initWithTitle:@"Congratulations!" message:[NSString stringWithFormat:@"You completed the puzzle in %d moves!",_moveCount] delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
                [_finishAlertView show];
                [_finishAlertView release];
                
            }else {
                //see if the record is broken
                if ([self.puzzle bestRecordValue] > _moveCount) {
                    [self.puzzle setBestRecordValue:_moveCount];
                    [[NSManagedObjectContext MR_contextForCurrentThread]MR_save];
                    
                    _finishAlertView = [[UIAlertView alloc]initWithTitle:@"New Record!" message:[NSString stringWithFormat:@"You completed the puzzle in %d moves!",_moveCount] delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
                    [_finishAlertView show];
                    [_finishAlertView release];
                }else {
                    
                    _finishAlertView = [[UIAlertView alloc]initWithTitle:@"Congratulations!" message:[NSString stringWithFormat:@"You completed the puzzle in %d moves!",_moveCount] delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
                    [_finishAlertView show];
                    [_finishAlertView release];
                }
            }
            
        }
    }
}


#pragma mark -
#pragma mark - Tile movement
- (void)moveTile:(SPPuzzleTile *)tile withDisplacement:(CGPoint)displacement 
{
    CGPoint tileCenter = tile.center;
    tileCenter.x += displacement.x;
    tileCenter.y += displacement.y;
    tile.center = tileCenter;
    
}

- (void)tryMoveTile:(SPPuzzleTile *)tile animated:(BOOL)isAnimated {
    
    if (isAnimated) {
        [UIView beginAnimations:@"tileMovingAnimation" context:nil];
    }
    SPPuzzleTileMovingDirection direction = [self validMovingDirectionForTile:tile];
    
    switch (direction) {
        case SPPuzzleTileMovingDirectionLeft:
            [self isDraggingOnTile:tile withFingerDisplacement:CGPointMake(-1*tile.width, 0)];
            break;
        case SPPuzzleTileMovingDirectionRight:
            [self isDraggingOnTile:tile withFingerDisplacement:CGPointMake(1*tile.width, 0)];
            break;
        case SPPuzzleTileMovingDirectionUp:
            [self isDraggingOnTile:tile withFingerDisplacement:CGPointMake(0, -1*tile.height)];
            break;
        case SPPuzzleTileMovingDirectionDown:
            [self isDraggingOnTile:tile withFingerDisplacement:CGPointMake(0, 1*tile.height)];
            break;
        case SPPuzzleTileMovingDirectionNone:
        default:
            break;
    }
    if (isAnimated) {
        [UIView commitAnimations];
    }
    
    [self didEndTryingToMoveTile:tile];
}

- (void)snapTile:(SPPuzzleTile *)tile toPositionAnimated:(BOOL)isAnimated 
{
    
    CGRect frame = tile.frame;
    if (fmodf(tile.frame.origin.x, tile.width) > tile.width/2) {
        frame.origin.x += tile.width - fmodf(tile.frame.origin.x, tile.width);
    }else {
        frame.origin.x -= fmodf(tile.frame.origin.x, tile.width);
    }
    
    if (fmodf(tile.frame.origin.y, tile.height) > tile.height/2) {
        frame.origin.y += tile.height - fmodf(tile.frame.origin.y, tile.height);
    }else {
        frame.origin.y -= fmodf(tile.frame.origin.y, tile.height);
    }
    
    if (isAnimated) {
        [UIView beginAnimations:@"tileMovingAnimation" context:nil];
    }
    tile.frame = frame;
    if (isAnimated) {
        [UIView commitAnimations];
    }
}

- (void)updateBlankTilePositionAfterMovingTile:(SPPuzzleTile *)tile withDirection:(SPPuzzleTileMovingDirection)direction
{
    //new blank tile position will be next to the moved tile, depending on the direction of the movement
    switch (direction) {
        case SPPuzzleTileMovingDirectionLeft:
            _currentBlankTilePosition.x = tile.currentTilePosition.x + 1;
            break;
        case SPPuzzleTileMovingDirectionRight:
            _currentBlankTilePosition.x = tile.currentTilePosition.x - 1;
            break;
        case SPPuzzleTileMovingDirectionUp:
            _currentBlankTilePosition.y = tile.currentTilePosition.y + 1;
            break;
        case SPPuzzleTileMovingDirectionDown:
            _currentBlankTilePosition.y = tile.currentTilePosition.y - 1;
            break;
        case SPPuzzleTileMovingDirectionNone:
        default:
            break;
    }
}

- (CGPoint)validDisplacementFromFingerDisplacement:(CGPoint)fingerDisplacement forTile:(SPPuzzleTile *)tile
{
    CGPoint validDisplacement = fingerDisplacement;
    CGPoint maxDisplacement = CGPointZero;
    
    SPPuzzleTileMovingDirection validMovingDirection = [self validMovingDirectionForTile:tile];
    
    //get the maximum displacement depending on the direction
    switch (validMovingDirection) {
        case SPPuzzleTileMovingDirectionLeft:
            maxDisplacement.x = 0 - tile.width;
            validDisplacement.y = 0;
            break;
        case SPPuzzleTileMovingDirectionRight:
            maxDisplacement.x = tile.width;
            validDisplacement.y = 0;
            break;
        case SPPuzzleTileMovingDirectionUp:
            maxDisplacement.y = 0 - tile.height;
            validDisplacement.x = 0;
            break;
        case SPPuzzleTileMovingDirectionDown:
            maxDisplacement.y = tile.height;
            validDisplacement.x = 0;
            break;
        case SPPuzzleTileMovingDirectionNone:
        default:
            return CGPointZero;
            break;
    }
    
    //test if the finger displacement is over the limit
    if (fabsf(validDisplacement.x + _accumulateDisplacement.x) > fabsf(maxDisplacement.x)) {
        validDisplacement.x = maxDisplacement.x - _accumulateDisplacement.x;
    }
    else if (fabsf(validDisplacement.y + _accumulateDisplacement.y) > fabsf(maxDisplacement.y)) {
        validDisplacement.y = maxDisplacement.y - _accumulateDisplacement.y;
    }

    switch (validMovingDirection) {
        case SPPuzzleTileMovingDirectionLeft:
            if (validDisplacement.x + _accumulateDisplacement.x > 0) {
                validDisplacement.x = 0;
            }
            break;
        case SPPuzzleTileMovingDirectionRight:
            if (validDisplacement.x + _accumulateDisplacement.x < 0) {
                validDisplacement.x = 0;
            }
            break;
        case SPPuzzleTileMovingDirectionUp:
            if (validDisplacement.y + _accumulateDisplacement.y > 0) {
                validDisplacement.y = 0;
            }
            break;
        case SPPuzzleTileMovingDirectionDown:
            if (validDisplacement.y + _accumulateDisplacement.y < 0) {
                validDisplacement.y = 0;
            }
            break;
        default:
            break;
    }
    
    return validDisplacement;
}

- (SPPuzzleTileMovingDirection)validMovingDirectionForTile:(SPPuzzleTile *)tile {
    //test if the blank tile and the tile are in the same row or column
    if (_currentBlankTilePosition.x == tile.currentTilePosition.x) 
    {
        if ( _currentBlankTilePosition.y < tile.currentTilePosition.y) {
            //the blank tile is in an upper position to the tile
            return SPPuzzleTileMovingDirectionUp;
        }
        else if (_currentBlankTilePosition.y > tile.currentTilePosition.y) {
            //the blank tile is in an lower position to the tile
            return SPPuzzleTileMovingDirectionDown;
        }
    }
    else if (_currentBlankTilePosition.y == tile.currentTilePosition.y) {
        if (_currentBlankTilePosition.x < tile.currentTilePosition.x) {
            //the blank tile is left to the tile
            return SPPuzzleTileMovingDirectionLeft;
        }
        else if (_currentBlankTilePosition.x > tile.currentTilePosition.x) {
            //the blank tile is left to the tile
            return SPPuzzleTileMovingDirectionRight;
        }
    }
    //the tile cannot be moved
    return SPPuzzleTileMovingDirectionNone;
}

- (NSArray *)tilesBetweenBlankTileAndTile:(SPPuzzleTile *)tile 
{
    NSMutableArray *tilesInBetween = [NSMutableArray array];
    SPPuzzleTileMovingDirection direction = [self validMovingDirectionForTile:tile];
    if (direction == SPPuzzleTileMovingDirectionNone) {
        return nil;
    }else {
        //matrix is a 2D C array, used to map the tiles position on the matrix
        id matrix[NUM_TILES_VERTICAL][NUM_TILES_HORIZONTAL];
        for (SPPuzzleTile *gameTile in _gameTiles) {
            CGPoint currentPosition = gameTile.currentTilePosition;
            matrix[(int)currentPosition.y][(int)currentPosition.x] = gameTile;
        }
        matrix[(int)_currentBlankTilePosition.y][(int)_currentBlankTilePosition.x] = nil;
        CGFloat xPositionDifference = fabsf(_currentBlankTilePosition.x - tile.currentTilePosition.x);
        CGFloat yPositionDifference = fabsf(_currentBlankTilePosition.y - tile.currentTilePosition.y);
        
        //based on the direction of valid movement, get the tiles in between the blank tile and the subject tile
        switch (direction) {
            case SPPuzzleTileMovingDirectionLeft:
                for (int i=1; i<xPositionDifference; i++) {
                    int xPosition = (int)tile.currentTilePosition.x - i;
                    int yPosition = (int)tile.currentTilePosition.y;
                    [tilesInBetween addObject:matrix[yPosition][xPosition]];
                }
                break;
            case SPPuzzleTileMovingDirectionRight:
                for (int i=1; i<xPositionDifference; i++) {
                    int xPosition = (int)tile.currentTilePosition.x + i;
                    int yPosition = (int)tile.currentTilePosition.y;
                    [tilesInBetween addObject:matrix[yPosition][xPosition]];
                }
                break;
            case SPPuzzleTileMovingDirectionUp:
                for (int i=1; i<yPositionDifference; i++) {
                    int xPosition = (int)tile.currentTilePosition.x;
                    int yPosition = (int)tile.currentTilePosition.y - i;
                    [tilesInBetween addObject:matrix[yPosition][xPosition]];
                }
                break;
            case SPPuzzleTileMovingDirectionDown:
                for (int i=1; i<yPositionDifference; i++) {
                    int xPosition = (int)tile.currentTilePosition.x;
                    int yPosition = (int)tile.currentTilePosition.y + i;
                    [tilesInBetween addObject:matrix[yPosition][xPosition]];
                }
                break;
            default:
                break;
        }
    }
    
    return tilesInBetween;
}

- (BOOL)isPuzzleComplete {
    BOOL isCompleted = YES;
    
    //puzzle is complete when the all tile's current position is equal to original position
    for (SPPuzzleTile *tile in _gameTiles) {
        if (!CGPointEqualToPoint(tile.currentTilePosition, tile.originalTilePosition)) {
            isCompleted = NO;
            break;
        }
    }
    
    return isCompleted;;
}

@end
