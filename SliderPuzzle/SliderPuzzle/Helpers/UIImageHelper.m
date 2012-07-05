//
//  UIImageHelper.m
//  SliderPuzzle
//
//  Created by 王 昊 on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

@implementation UIImage (helper)

+ (UIImage *)imageNamedWithNoCach:(NSString *)fileName {
	NSString *thumbnailFile = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], fileName];
	UIImage *returnImg = [UIImage imageWithContentsOfFile:thumbnailFile];
	return returnImg;
}


- (UIImage *) scaleProportionalToSize: (CGSize)size
{

    if(self.size.width>self.size.height)
    {
        size=CGSizeMake((self.size.width/self.size.height)*size.height,size.height);
    }
    else
    {
        size=CGSizeMake(size.width,(self.size.height/self.size.width)*size.width);
    }
    
    
    CGFloat scale = self.size.width / size.width;
    UIImage *scaledImage = [UIImage imageWithCGImage:[self CGImage] 
                                               scale:scale orientation:UIImageOrientationUp];
    
    return scaledImage;
}

+ (void)saveImage: (UIImage*)image withName:(NSString *)imageNameWithExtension
{
    if (image != nil)
    {
        NSString* path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat: @"/Documents/%@", imageNameWithExtension]];
        NSData* data = UIImagePNGRepresentation(image);
        
        [data writeToFile:path atomically:YES];
    }
}

+ (UIImage*)loadImageWithName:(NSString *)imageNameWithExtension
{
    NSString* path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat: @"/Documents/%@", imageNameWithExtension]];
    
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    
    return image;
}

@end
