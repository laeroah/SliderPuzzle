//
//  SPPuzzleScrollView.m
//  SliderPuzzle
//
//  Created by 王 昊 on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPPuzzleView.h"
#import "SPPuzzleTile.h"
#import "UIViewHelper.h"

@interface SPPuzzleView()

/**
 * put the tile to the position on the puzzle slider matrix. The position holds the destination with x value being the column and y value being the row. 
 */
- (void)putTile:(SPPuzzleTile*)tile ToPosition:(CGPoint)position animated:(BOOL)isAnimated;

@end

@implementation SPPuzzleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor grayColor];
    }
    return self;
}

#pragma mark -
#pragma mark - layout tiles
- (void)layoutTiles:(NSArray *)tiles withBlankTilePosition:(CGPoint)blankTilePosition andHorizontalTileNum:(NSInteger)hTileNum andVerticalTileNum:(NSInteger)vTileNum
{
    NSMutableArray *tilesToBePlaced = [NSMutableArray arrayWithArray:tiles];
    
    for (int row = 0; row < vTileNum; row++) {
        for (int col = 0; col <hTileNum; col++) 
        {
            if ([tilesToBePlaced count] <= 0) {
                //this shouldn't happen
                break;
            }
            
            CGPoint currentMatrixPosition = CGPointMake(col, row);
            if (CGPointEqualToPoint(currentMatrixPosition, blankTilePosition)) {
                //we have dealt with blank tile already, so skip it here.
                continue;
            }
            SPPuzzleTile *tile = nil;
            tile = [tilesToBePlaced objectAtIndex:0]; 
            [self addSubview:tile];
            [tile setNeedsDisplay];
            [self putTile:tile ToPosition:tile.currentTilePosition animated:NO];
            [tilesToBePlaced removeObject:tile];
        }
    }
}


#pragma mark - 
#pragma mark tile moving
- (void)putTile:(SPPuzzleTile*)tile ToPosition:(CGPoint)position animated:(BOOL)isAnimated
{
    CGFloat xOffset = position.x * tile.width;
    CGFloat yOffset = position.y * tile.height;
    tile.frame = CGRectMake(xOffset,yOffset,tile.width,tile.height);
}

@end
