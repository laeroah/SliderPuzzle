//
//  SPViewController.m
//  SliderPuzzle
//
//  Created by 王 昊 on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPListViewController.h"
#import "CoreData+MagicalRecord.h"
#import "Puzzle.h"
#import "UIImageHelper.h"
#import "UIAlertViewHelper.h"

@interface SPListViewController ()

@end

@implementation SPListViewController

@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize puzzleListTable = _puzzleListTable;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPuzzle:)] autorelease];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editTable:)] autorelease];
                                              
    self.title = @"Puzzle List";
    [self loadPuzzles];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setPuzzleListTable:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) || (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)startDefaultPuzzle:(id)sender {
    SPGameViewController *gameViewController = [[SPGameViewController alloc]init];
    [self.navigationController pushViewController:gameViewController animated:YES];
    [gameViewController release];
}

- (void)dealloc {
    [_fetchedResultsController release];
    [_puzzleListTable release];
    [super dealloc];
}

#pragma mark - action
- (void)addPuzzle:(id)sender 
{
    //add a new puzzle;
    SPNewPuzzleViewController *newPuzzleController = [[SPNewPuzzleViewController alloc]initWithNibName:@"SPNewPuzzleViewController" bundle:nil];
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:newPuzzleController];
    [self presentModalViewController:navController animated:YES];
    [newPuzzleController release];
    [navController release];
}

- (void)editTable:(id)sender
{
    [_puzzleListTable setEditing: YES animated: YES];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneEditTable:)] autorelease];
}

- (void)doneEditTable:(id)sender
{
    [_puzzleListTable setEditing: NO animated: YES];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editTable:)] autorelease];
}

#pragma mark - public
- (void)loadPuzzles {
    
	NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Core Data Error %@, %@", error, [error userInfo]);
        exit(0);
    }
}

#pragma mark - UITableViewDelegate and UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier]autorelease];
    }
	
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	Puzzle *puzzle = (Puzzle *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    SPGameViewController *gameViewController = [[SPGameViewController alloc]initWithNibName:@"SPGameViewController" andPuzzle:puzzle];
    [self.navigationController pushViewController:gameViewController animated:YES];
    [gameViewController release];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath 
{
    
	Puzzle *puzzle = (Puzzle *)[self.fetchedResultsController objectAtIndexPath:indexPath];
	UIImage *puzzleThumbnail = [UIImage loadImageWithName:puzzle.thumbnailImagePath];
    [cell.imageView setImage:puzzleThumbnail];
    cell.textLabel.text = puzzle.puzzleName;
    if (![puzzle hasCompletedBeforeValue]) {
        cell.detailTextLabel.text = @"Puzzle not complete.";
    }else {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Best Record:%@", [puzzle.bestRecord stringValue]];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    
	Puzzle *puzzle = (Puzzle *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UIAlertView *alert = [[UIAlertView alloc] 
                              initWithTitle: @"Delete" 
                              message: [NSString stringWithFormat:@"Do you really want to delete %@",puzzle.puzzleName]
                              delegate: self
                              cancelButtonTitle: @"Cancel"
                              otherButtonTitles: @"Yes", nil];
        alert.userInfo = [NSDictionary dictionaryWithObject:puzzle forKey:@"puzzle"];
        [alert show];
        [alert release];
    }
}

#pragma mark -
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex 
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:@"Yes"])
    {
        [alertView dismissWithClickedButtonIndex:1 animated:YES];
        
        NSDictionary *userInfo = alertView.userInfo;
        Puzzle *puzzle = (Puzzle *)[userInfo objectForKey:@"puzzle"];
        [puzzle MR_deleteEntity];
        [[NSManagedObjectContext MR_defaultContext]MR_save];
    }
}


#pragma mark -
#pragma mark NSFetchResultsController and its Delegate
- (NSFetchedResultsController *)fetchedResultsController 
{
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
 	NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"createTime" 
                                                         ascending:YES 
                                                          selector:@selector(compare:)];
    NSFetchRequest *request = [Puzzle MR_requestAll];
    [request setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    [sort release];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[NSManagedObjectContext MR_contextForCurrentThread] sectionNameKeyPath:nil cacheName:nil];

    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}  


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.puzzleListTable beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.puzzleListTable endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath 
{
    
	UITableView *tableView = self.puzzleListTable;
	
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeUpdate:
			[self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
			break;
			
		case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
	}
}



@end
