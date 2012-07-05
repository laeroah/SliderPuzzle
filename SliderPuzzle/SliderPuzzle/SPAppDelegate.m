//
//  SPAppDelegate.m
//  SliderPuzzle
//
//  Created by 王 昊 on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPAppDelegate.h"

#import "SPListViewController.h"
#import "CoreData+MagicalRecord.h"
#import "Puzzle.h"
#import "UIImageHelper.h"

@interface SPAppDelegate() 

/**
 * setup the default puzzle
 */
- (void)initializeTheDefaultPuzzleInCoreData;

@end

@implementation SPAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //using a third party helper library for coredata
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"SPPuzzleModel.sqlite"];
    
    NSArray *puzzles = [Puzzle MR_findAll];
    if ([puzzles count] <= 0) {
        [self initializeTheDefaultPuzzleInCoreData];
    }
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.viewController = [[[SPListViewController alloc] initWithNibName:@"SPListViewController" bundle:nil] autorelease];
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:self.viewController];
    self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];
    [navController release];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [MagicalRecord cleanUp];
}

- (void)initializeTheDefaultPuzzleInCoreData {
    NSLog(@"initializing the default puzzle...");
    
    Puzzle *defaultPuzzle = [Puzzle puzzleWithName:@"Earth"];
    [defaultPuzzle setIsDefaultPuzzleValue:YES];
    [defaultPuzzle setCreateTime:[NSDate date]];
    
    //resize the original image to get the thumbnail image
    UIImage *puzzleImage = [UIImage imageNamedWithNoCach:@"UIE_Slider_Puzzle--globe.jpg"];
    puzzleImage = [puzzleImage scaleProportionalToSize:CGSizeMake(300, 300)];
    UIImage *thumbnailImage = [puzzleImage scaleProportionalToSize:CGSizeMake(90, 90)];
    //UIImage *thumbnailImage = puzzleImage;
    [UIImage saveImage:thumbnailImage withName:[NSString stringWithFormat:@"%@_thumbnail.png", defaultPuzzle.puzzleName]];
    
    //for the default puzzle we have a slider image provided
    UIImage *sliderImage = [UIImage imageNamedWithNoCach:@"UIE_Slider_Puzzle--slider.jpg"];
    //scale the image to smaller size for fast load, and save memory
    [UIImage saveImage:[sliderImage scaleProportionalToSize:SIZE_PUZZLE_VIEW]
              withName:[NSString stringWithFormat:@"%@_original.png", defaultPuzzle.puzzleName]];
    [defaultPuzzle setOrignalImagePath:[NSString stringWithFormat:@"%@_original.png", defaultPuzzle.puzzleName]];
    [defaultPuzzle setThumbnailImagePath:[NSString stringWithFormat:@"%@_thumbnail.png", defaultPuzzle.puzzleName]];
    [[NSManagedObjectContext MR_defaultContext]MR_save];
}

@end
