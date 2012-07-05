//
//  SPViewController.h
//  SliderPuzzle
//
//  Created by 王 昊 on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPGameViewController.h"
#import "SPNewPuzzleViewController.h"

@interface SPListViewController : UIViewController 
<NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>{
    
	NSFetchedResultsController *_fetchedResultsController;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (retain, nonatomic) IBOutlet UITableView *puzzleListTable;

- (IBAction)startDefaultPuzzle:(id)sender;

- (void)loadPuzzles;

@end
