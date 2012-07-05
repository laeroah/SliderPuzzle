//
//  UIImageHelper.h
//  SliderPuzzle
//
//  Created by 王 昊 on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage (helper)

/**
 * use this method to avoid memory lost with the native imageNamed method
 */
+ (UIImage *)imageNamedWithNoCach:(NSString *)fileName;

/**
 * use this method to scale to image proportionally to a certain size
 */
- (UIImage *) scaleProportionalToSize: (CGSize)size;

/**
 * save and load image
 */
+ (void)saveImage: (UIImage*)image withName:(NSString *)imageNameWithExtension;
+ (UIImage*)loadImageWithName:(NSString *)imageNameWithExtension;

@end
