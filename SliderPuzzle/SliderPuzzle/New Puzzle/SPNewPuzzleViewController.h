//
//  SPNewPuzzleViewController.h
//  SliderPuzzle
//
//  Created by 王 昊 on 6/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

//this view controller presents the interface for adding a new puzzle
@interface SPNewPuzzleViewController : UIViewController 
<UIAlertViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate>
{
    UIAlertView *_finishAlertView;
}

@property (retain, nonatomic) IBOutlet UIImageView *puzzleImageView;
@property (retain, nonatomic) IBOutlet UIButton *choosePuzzleImageButton;
@property (retain, nonatomic) IBOutlet UITextField *puzzleNameTextField;

- (IBAction)choosePuzzleImage:(id)sender;

@end
