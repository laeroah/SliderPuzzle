//
//  SliderPuzzleTests.m
//  SliderPuzzleTests
//
//  Created by 王 昊 on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SliderPuzzleTests.h"
#import "UIImageHelper.h"

@implementation SliderPuzzleTests

- (void)setUp
{
    [super setUp];
    _tile = [[SPPuzzleTile alloc]initWithImage:[UIImage imageNamedWithNoCach:@"UIE_Slider_Puzzle--globe.jpg"]];
}

- (void)tearDown
{
    [_tile release];
    [super tearDown];
}

- (void)testSPPuzzleTile
{
    if (_tile.tileImage == nil) {
        STFail(@"tile image is not set properly");
    }
}

@end
