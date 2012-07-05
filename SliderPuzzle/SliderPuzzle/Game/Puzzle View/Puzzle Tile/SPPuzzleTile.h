//
//  SPPuzzleTile.h
//  SliderPuzzle
//
//  Created by 王 昊 on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SPPuzzleTile;
@protocol SPPuzzleTileDelegate <NSObject>

@required
- (void)didEndDraggingOnTile:(SPPuzzleTile *)tile;
- (void)isDraggingOnTile:(SPPuzzleTile *)tile withFingerDisplacement:(CGPoint)fingerDisplacement;
- (void)isTappingOnTile:(SPPuzzleTile *)tile;

@end

@interface SPPuzzleTile : UIView {
    CGPoint _originalTilePosition;
    CGPoint _currentTilePosition; 
    CGPoint _fingerStartPosition;
    id<SPPuzzleTileDelegate> _delegate;
    UIImage *_tileImage;
}

/**
 *hold the current position of tile in the 4x4 matrix.
 */
@property (nonatomic, assign) CGPoint currentTilePosition;

/**
 *hold the position where the tile is suppose to be when the puzzle is complete
 */
@property (nonatomic, assign) CGPoint originalTilePosition;


@property (nonatomic, assign) id<SPPuzzleTileDelegate> delegate;

@property (nonatomic, retain) UIImage *tileImage;


- (CGPoint) currentPositionCalculatedFromOrigin;
- (id)initWithImage:(UIImage *)image andFrame:(CGRect)frame;

@end
