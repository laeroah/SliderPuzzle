//
//  SPPuzzleTile.m
//  SliderPuzzle
//
//  Created by 王 昊 on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPPuzzleTile.h"
#import "UIViewHelper.h"

@implementation SPPuzzleTile

@synthesize currentTilePosition = _currentTilePosition;
@synthesize originalTilePosition = _originalTilePosition;
@synthesize delegate = _delegate;
@synthesize tileImage = _tileImage;

- (void)dealloc {
    [_tileImage release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (id)initWithImage:(UIImage *)image andFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //add a pan gesture recognizer so we can drag and move the tiles
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(tryMoveTileByDragging:)];
        //use one finger to move the tile
        [panGestureRecognizer setMinimumNumberOfTouches:1];
        [panGestureRecognizer setMaximumNumberOfTouches:1];
        panGestureRecognizer.cancelsTouchesInView = NO;
        [self addGestureRecognizer:panGestureRecognizer];
        [panGestureRecognizer release];
        
        //add a tap gesutre recognizer so we can tap and move the tiles
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tryMoveTileByTapping:)];
        [tapGestureRecognizer setNumberOfTapsRequired:1];
        panGestureRecognizer.cancelsTouchesInView = NO;
        [self addGestureRecognizer:tapGestureRecognizer];
        [tapGestureRecognizer release];
        
        self.userInteractionEnabled = YES;
        
        self.tileImage = image;
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    //draw a border around the tile, so they don't bleed into each other
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.tileImage drawInRect:rect];
    [[UIColor whiteColor]set];
    CGContextSetLineWidth(context, 2.0);
    CGContextStrokeRect(context, rect);
}
                                                        
                                                        
- (void)tryMoveTileByTapping:(UIPanGestureRecognizer *)panGestureRecoginzer 
{
    [self.delegate isTappingOnTile:self];
}

- (void)tryMoveTileByDragging:(UIPanGestureRecognizer *)panGestureRecoginzer
{
    //find out the displacement to the current center of the tile
    CGPoint currentFingerPosition = [panGestureRecoginzer locationInView:self.superview];
    CGPoint displacement = CGPointMake(currentFingerPosition.x - _fingerStartPosition.x, currentFingerPosition.y - _fingerStartPosition.y);
    _fingerStartPosition = currentFingerPosition;
    
    switch (panGestureRecoginzer.state) {
        case UIGestureRecognizerStateBegan:
            break;
        case UIGestureRecognizerStateChanged:
            [self.delegate isDraggingOnTile:self withFingerDisplacement:displacement];
            break;
        case UIGestureRecognizerStateEnded:
            [self.delegate didEndDraggingOnTile:self];
            break;
        case UIGestureRecognizerStateCancelled:
            break;
        default:
            break;
    }
}

- (CGPoint) currentPositionCalculatedFromOrigin {
    CGFloat xPosition = roundf(self.frame.origin.x / self.width);
    CGFloat yPosition = roundf(self.frame.origin.y / self.height);
    return CGPointMake(xPosition, yPosition);
}

@end
