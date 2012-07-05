//
//  SPPuzzleScrollView.h
//  SliderPuzzle
//
//  Created by 王 昊 on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SPPuzzleTile;
@interface SPPuzzleView : UIView
{
    UIView *_loadingView;
}

- (void)layoutTiles:(NSArray *)tiles withBlankTilePosition:(CGPoint)blankTilePosition andHorizontalTileNum:(NSInteger)hTileNum andVerticalTileNum:(NSInteger)vTileNum;


@end
