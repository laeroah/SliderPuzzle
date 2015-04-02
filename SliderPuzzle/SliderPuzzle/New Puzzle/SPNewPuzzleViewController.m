//
//  SPNewPuzzleViewController.m
//  SliderPuzzle
//
//  Created by 王 昊 on 6/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPNewPuzzleViewController.h"
#import "Puzzle.h"
#import "UIImageHelper.h"
#import "CoreData+MagicalRecord.h"

typedef enum {
    SPPuzzleInfoCheckResultPass,
    SPPuzzleInfoCheckResultErrorNoPuzzleName,
    SPPuzzleInfoCheckResultErrorNoPuzzleImage
}SPPuzzleInfoCheckResult;

//the maximum character the user can put in a puzzle's name
#define MAXLENGTH 25 

@interface SPNewPuzzleViewController ()

/**
 * check if all the required info is filled for the puzzle
 */
- (SPPuzzleInfoCheckResult)isRequiredFieldsFilled;

/**
 * allow the user to select image for the puzzle from camera or photo album using native image picker
 */
- (void)selectPicturesFromCamera;
- (void)selectPicturesFromAlbum;

- (void)savePuzzleWithCurrentInfo;

@end

@implementation SPNewPuzzleViewController
@synthesize puzzleImageView;
@synthesize choosePuzzleImageButton;
@synthesize puzzleNameTextField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"New Puzzle";
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(addPuzzle:)] autorelease];
    
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)] autorelease];
    
    self.puzzleNameTextField.delegate = self;
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)viewDidUnload
{
    [self setPuzzleImageView:nil];
    [self setChoosePuzzleImageButton:nil];
    [self setPuzzleNameTextField:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) || (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)dealloc {
    [puzzleImageView release];
    [choosePuzzleImageButton release];
    [puzzleNameTextField release];
    [super dealloc];
}

#pragma mark -
#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string 
{
    //limit the maximum character the user can put in a puzzle's name
    if ([textField.text length] > MAXLENGTH) {
        textField.text = [textField.text substringToIndex:MAXLENGTH-1];
        return NO;
    }
    return YES;
}


#pragma mark -
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex 
{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}

#pragma mark -
#pragma mark - private
- (SPPuzzleInfoCheckResult)isRequiredFieldsFilled 
{
    if ([self.puzzleNameTextField.text isEqualToString:@""] || self.puzzleNameTextField.text == nil) 
    {
        return SPPuzzleInfoCheckResultErrorNoPuzzleName;
    }
    else if(self.puzzleImageView.image == nil) 
    {
        return SPPuzzleInfoCheckResultErrorNoPuzzleImage;
    }
    return SPPuzzleInfoCheckResultPass;
}

- (void)savePuzzleWithCurrentInfo 
{
    Puzzle *puzzle = [Puzzle puzzleWithName:self.puzzleNameTextField.text];
    [puzzle setIsDefaultPuzzleValue:NO];
    [puzzle setCreateTime:[NSDate date]];
    
    //resize the original image to get the thumbnail image, then save both to file
    UIImage *puzzleImage = self.puzzleImageView.image;
    UIImage *thumbnailImage = [puzzleImage scaleProportionalToSize:CGSizeMake(90, 90)];
    NSString *puzzleNameNoSpace = [puzzle.puzzleName stringByReplacingOccurrencesOfString:@" " withString:@""];
    [UIImage saveImage:thumbnailImage withName:[NSString stringWithFormat:@"%@_thumbnail.png", puzzleNameNoSpace]];
    [UIImage saveImage:[puzzleImage scaleProportionalToSize:SIZE_PUZZLE_VIEW] 
              withName:[NSString stringWithFormat:@"%@_original.png", puzzleNameNoSpace]];
    [puzzle setOrignalImagePath:[NSString stringWithFormat:@"%@_original.png", puzzleNameNoSpace]];
    [puzzle setThumbnailImagePath:[NSString stringWithFormat:@"%@_thumbnail.png", puzzleNameNoSpace]];
    
    //commit the change
    [[NSManagedObjectContext MR_contextForCurrentThread]MR_save];
}


#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissModalViewControllerAnimated:YES];
    UIImage *editedImage = [info objectForKey:UIImagePickerControllerEditedImage];
    self.puzzleImageView.image = editedImage;
    self.choosePuzzleImageButton.selected = YES;
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"Camera"]) {
        [self selectPicturesFromCamera];
    }else if ([buttonTitle isEqualToString:@"Photo Album"]) {
        [self selectPicturesFromAlbum];
    }
}

#pragma mark - 
#pragma mark - actions
- (void)addPuzzle:(id)sender 
{
    SPPuzzleInfoCheckResult result = [self isRequiredFieldsFilled];
    switch (result) {
        case SPPuzzleInfoCheckResultPass:
            [self savePuzzleWithCurrentInfo];
            [self.parentViewController dismissModalViewControllerAnimated:YES];
            break;
        case SPPuzzleInfoCheckResultErrorNoPuzzleName:
            _finishAlertView = [[UIAlertView alloc]initWithTitle:@"Need A Name!" message:@"Please fill in the puzzle name." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
            [_finishAlertView show];
            [_finishAlertView release];
            break;
        case SPPuzzleInfoCheckResultErrorNoPuzzleImage:
            _finishAlertView = [[UIAlertView alloc]initWithTitle:@"Need An Image!" message:@"Please choose an image for the puzzle" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
            [_finishAlertView show];
            [_finishAlertView release];
            break;
            
        default:
            [self.parentViewController dismissModalViewControllerAnimated:YES];
            break;
    }
}

- (void)cancel:(id)sender 
{
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}


- (IBAction)choosePuzzleImage:(id)sender 
{
    [self.view endEditing:YES]; //dismiss the keyboard if it's showing
    
    UIActionSheet *imageSourceQuerySheet = nil;
    //check if camera is available on the current device
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) 
    {
        imageSourceQuerySheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Photo Album", @"Camera", nil];
    }else 
    {
        imageSourceQuerySheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Photo Album", nil];
    }
    imageSourceQuerySheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    
    [imageSourceQuerySheet showInView:self.view];
    
    [imageSourceQuerySheet release];
}

- (void)selectPicturesFromCamera 
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        return;
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.allowsEditing = YES;
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentModalViewController:picker animated:YES];
    [picker release];
}

- (void)selectPicturesFromAlbum 
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.allowsEditing = YES;
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentModalViewController:picker animated:YES];
    [picker release];
}

@end
